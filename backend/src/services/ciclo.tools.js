/**
 * Ferramentas (tools) do agente Ciclo.
 *
 * Cada ferramenta lê o "snapshot" do dashboard que o app/site envia junto
 * com a pergunta (os mesmos dados que alimentam os gráficos) e devolve um
 * resultado pequeno em JSON. O LLM decide QUAL ferramenta chamar e com
 * quais argumentos (function calling); o código executa e devolve o
 * resultado para o modelo redigir a resposta.
 *
 * Formato do snapshot:
 * {
 *   instituicao: "Prefeitura Municipal",
 *   geradoEm: "2026-09-29T12:00:00Z",
 *   kpis: { lixeiras, ocupacaoMedia, paraColetar, coletas30d },
 *   lixeiras: [{ id, nome, endereco, ocupacao, status,
 *                composicao: { Plástico: 45, ... }, ultimaColeta: ISO|null }],
 *   composicaoGeral: { Plástico: 38, Vidro: 22, ... },   // % (rosca)
 *   ranking: [{ nome, coletas }],
 *   atividades: [{ coletor, lixeira, dataHora: ISO, ocupacao }]
 * }
 */

import { buscarConhecimento } from "./ciclo.rag.service.js";

const LIMITE_CHEIA = 90; // % a partir do qual a lixeira é considerada cheia

// ── Previsão ─────────────────────────────────────────────────────────────────
/**
 * Previsão linear simples de enchimento. Depois de uma coleta a lixeira
 * volta a 0%; então a taxa média de enchimento é
 *     taxa (%/dia) = ocupação atual / dias desde a última coleta.
 * E o tempo até encher é
 *     dias restantes = (90% − ocupação atual) / taxa.
 * É uma estimativa (supõe ritmo constante), e o Ciclo deve dizer isso.
 */
function preverLixeira(l, agora) {
  if (l.ocupacao >= LIMITE_CHEIA) {
    return { ...resumo(l), diasParaEncher: 0, previsao: "Já está cheia: coletar hoje." };
  }
  if (!l.ultimaColeta) {
    return { ...resumo(l), diasParaEncher: null, previsao: "Sem histórico de coleta para estimar o ritmo." };
  }
  const dias = (agora - new Date(l.ultimaColeta)) / 86_400_000;
  if (dias < 0.25 || l.ocupacao <= 0) {
    return { ...resumo(l), diasParaEncher: null, previsao: "Coletada há pouco tempo; ainda não dá para estimar." };
  }
  const taxa = l.ocupacao / dias;
  const restantes = (LIMITE_CHEIA - l.ocupacao) / taxa;
  const data = new Date(agora.getTime() + restantes * 86_400_000);
  return {
    ...resumo(l),
    taxaPorDia: arred(taxa),
    diasParaEncher: arred(restantes),
    emTexto: prazoEmTexto(restantes),
    dataEstimada: data.toISOString().slice(0, 10),
  };
}

/** 0.4 → "~10 horas"; 2.3 → "~2 dias". */
function prazoEmTexto(dias) {
  if (dias < 1) {
    const h = Math.max(1, Math.round(dias * 24));
    return `~${h} ${h === 1 ? "hora" : "horas"}`;
  }
  const d = Math.round(dias);
  return `~${d} ${d === 1 ? "dia" : "dias"}`;
}

const arred = (n) => Math.round(n * 10) / 10;

function resumo(l) {
  return { nome: l.nome, endereco: l.endereco, ocupacao: l.ocupacao, status: l.status };
}

function acharLixeira(snap, nome) {
  const alvo = (nome || "").toLowerCase();
  return snap.lixeiras.find(
    (l) => l.nome.toLowerCase() === alvo || l.nome.toLowerCase().includes(alvo),
  );
}

// ── Definição das ferramentas ────────────────────────────────────────────────
// `schema` segue o formato de function calling compatível com a API da
// OpenAI (aceito também pelo Gemini, Groq etc. via endpoint compatível).
export const FERRAMENTAS = {
  buscar_conhecimento: {
    grafico: null,
    schema: {
      description:
        "Busca na base de conhecimento do G.R.U (conceitos, como ler os gráficos, boas práticas de coleta). Use para perguntas conceituais ou de recomendação.",
      parameters: {
        type: "object",
        properties: { consulta: { type: "string", description: "O que buscar." } },
        required: ["consulta"],
      },
    },
    executar: (_snap, { consulta }) => buscarConhecimento(consulta, 3),
  },

  resumo_dashboard: {
    grafico: "kpis",
    schema: {
      description: "Resumo geral: KPIs (lixeiras, ocupação média, para coletar, coletas em 30 dias).",
      parameters: { type: "object", properties: {} },
    },
    executar: (snap) => ({ instituicao: snap.instituicao, ...snap.kpis }),
  },

  lixeiras_prioritarias: {
    grafico: "ocupacao",
    schema: {
      description:
        "Lista as lixeiras ordenadas da mais cheia para a mais vazia (gráfico 'Ocupação por lixeira'). Use para planejar a rota de coleta.",
      parameters: {
        type: "object",
        properties: {
          minimo: { type: "number", description: "Ocupação mínima (%) para entrar na lista. Padrão 70." },
        },
      },
    },
    executar: (snap, { minimo = 70 } = {}) =>
      [...snap.lixeiras]
        .filter((l) => l.ocupacao >= minimo)
        .sort((a, b) => b.ocupacao - a.ocupacao)
        .map(resumo),
  },

  detalhes_lixeira: {
    grafico: "ocupacao",
    schema: {
      description: "Detalhes de uma lixeira específica: ocupação, composição de material e última coleta.",
      parameters: {
        type: "object",
        properties: { nome: { type: "string", description: "Nome (ou parte do nome) da lixeira." } },
        required: ["nome"],
      },
    },
    executar: (snap, { nome }) => acharLixeira(snap, nome) ?? { erro: `Lixeira '${nome}' não encontrada.` },
  },

  prever_enchimento: {
    grafico: "ocupacao",
    schema: {
      description:
        "Previsão de quando cada lixeira vai encher (≥90%), com base no ritmo desde a última coleta. Sem 'nome', devolve todas, das mais urgentes para as menos.",
      parameters: {
        type: "object",
        properties: { nome: { type: "string", description: "Opcional: prever só esta lixeira." } },
      },
    },
    executar: (snap, { nome } = {}) => {
      const agora = new Date(snap.geradoEm ?? Date.now());
      if (nome) {
        const l = acharLixeira(snap, nome);
        return l ? preverLixeira(l, agora) : { erro: `Lixeira '${nome}' não encontrada.` };
      }
      return snap.lixeiras
        .map((l) => preverLixeira(l, agora))
        .sort((a, b) => (a.diasParaEncher ?? 999) - (b.diasParaEncher ?? 999));
    },
  },

  composicao_residuos: {
    grafico: "residuos",
    schema: {
      description: "Composição geral por tipo de material (gráfico de rosca 'Tipos de resíduo').",
      parameters: { type: "object", properties: {} },
    },
    executar: (snap) => {
      const itens = Object.entries(snap.composicaoGeral ?? {}).sort((a, b) => b[1] - a[1]);
      return { composicao: Object.fromEntries(itens), predominante: itens[0]?.[0] ?? null };
    },
  },

  desempenho_coletores: {
    grafico: "ranking",
    schema: {
      description: "Ranking de coletores por número de coletas, com a média da equipe.",
      parameters: { type: "object", properties: {} },
    },
    executar: (snap) => {
      const r = snap.ranking ?? [];
      const media = r.length ? r.reduce((s, c) => s + c.coletas, 0) / r.length : 0;
      return {
        media: arred(media),
        ranking: r.map((c) => ({ ...c, abaixoDaMedia: c.coletas < media * 0.6 })),
      };
    },
  },

  atividades_recentes: {
    grafico: "atividades",
    schema: {
      description: "Últimas coletas registradas (quem, onde e quando).",
      parameters: {
        type: "object",
        properties: { limite: { type: "number", description: "Quantas trazer. Padrão 5." } },
      },
    },
    executar: (snap, { limite = 5 } = {}) => (snap.atividades ?? []).slice(0, limite),
  },
};

/** Ferramentas no formato `tools` da API (function calling). */
export function schemasDasFerramentas() {
  return Object.entries(FERRAMENTAS).map(([name, f]) => ({
    type: "function",
    function: { name, ...f.schema },
  }));
}

/** Executa uma ferramenta pelo nome, protegendo contra erros e nomes inválidos. */
export function executarFerramenta(nome, args, snapshot) {
  const f = FERRAMENTAS[nome];
  if (!f) return { erro: `Ferramenta desconhecida: ${nome}` };
  try {
    return f.executar(snapshot, args ?? {});
  } catch (e) {
    return { erro: `Falha ao executar ${nome}: ${e.message}` };
  }
}

/** Qual gráfico do dashboard uma ferramenta "toca" (para o app destacar). */
export function graficoDaFerramenta(nome) {
  return FERRAMENTAS[nome]?.grafico ?? null;
}
