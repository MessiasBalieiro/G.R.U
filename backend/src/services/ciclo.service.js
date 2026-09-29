import { buscarConhecimento, tokenizar } from "./ciclo.rag.service.js";
import {
  executarFerramenta,
  graficoDaFerramenta,
  schemasDasFerramentas,
} from "./ciclo.tools.js";

/**
 * Agente Ciclo.
 *
 * Fluxo de cada pergunta (padrão "ReAct" com function calling):
 *
 *   1. RAG: recupera da base de conhecimento os trechos mais parecidos com a
 *      pergunta e coloca nas instruções do modelo (contexto "aumentado").
 *   2. Chama o LLM com a pergunta, o histórico da conversa e a lista de
 *      ferramentas disponíveis.
 *   3. Se o LLM pedir ferramentas, o código executa cada uma sobre o
 *      snapshot do dashboard e devolve os resultados ao LLM.
 *   4. Repete 2–3 até o LLM responder em texto (máx. MAX_PASSOS voltas).
 *
 * Provedores (variável CICLO_PROVIDER no .env):
 *   - "gemini" (padrão): API NATIVA do Google Gemini (generateContent).
 *     Aceita as chaves novas do AI Studio, que começam com "AQ.".
 *   - "openai": qualquer API no formato Chat Completions da OpenAI
 *     (OpenAI, Groq, OpenRouter...), usando CICLO_BASE_URL.
 *
 *   CICLO_API_KEY=...        (obrigatória para usar o LLM)
 *   CICLO_MODEL=gemini-2.5-flash
 *
 * Sem CICLO_API_KEY — ou se o LLM falhar — o Ciclo responde em "modo
 * offline": mesmas ferramentas e mesmo RAG, mas escolhe a ferramenta por
 * palavra-chave e monta o texto no código.
 */

const MAX_PASSOS = 4;

function config() {
  const provider = (process.env.CICLO_PROVIDER || "gemini").toLowerCase();
  return {
    provider,
    apiKey: (process.env.CICLO_API_KEY || "").trim(),
    // Pode ser uma lista separada por vírgula: o primeiro é o principal e os
    // demais são reservas, usados se o anterior estiver sobrecarregado.
    // Ex.: CICLO_MODEL=gemini-2.5-flash,gemini-2.5-flash-lite
    modelos: (process.env.CICLO_MODEL || "gemini-2.5-flash")
      .split(",")
      .map(limparNomeDoModelo)
      .filter(Boolean),
    baseUrl: baseUrl(provider),
  };
}

/**
 * Aceita o nome do modelo mesmo com "sujeira" comum de copiar e colar:
 * aspas, espaços, caracteres invisíveis e o prefixo "models/" do AI Studio.
 *   '"models/gemini-2.5-flash" ' → 'gemini-2.5-flash'
 */
function limparNomeDoModelo(nome) {
  return nome
    .replace(/[\u200B-\u200D\uFEFF]/g, "") // caracteres invisíveis
    .replace(/["'`]/g, "")                   // aspas
    .trim()
    .replace(/^models\//, "");               // prefixo do AI Studio
}

function baseUrl(provider) {
  let url = (
    process.env.CICLO_BASE_URL ||
    (provider === "gemini"
      ? "https://generativelanguage.googleapis.com/v1beta"
      : "https://api.openai.com/v1")
  ).replace(/\/+$/, "");
  // .env antigo apontava para a rota compatível ".../v1beta/openai"; a API
  // nativa do Gemini fica em ".../v1beta".
  if (provider === "gemini") url = url.replace(/\/openai$/, "");
  return url;
}

function promptDeSistema(snapshot, trechos) {
  const contexto = trechos.length
    ? trechos.map((t, i) => `[${i + 1}] (${t.fonte})\n${t.texto}`).join("\n\n")
    : "(nenhum trecho relevante encontrado)";

  return `Você é o Ciclo, assistente virtual do G.R.U (Gerenciador de Resíduos Urbanos).
Você ajuda o Administrador de "${snapshot.instituicao ?? "sua instituição"}" a entender o Dashboard, gerar insights, fazer previsões e decidir ações.

Regras:
- Responda em português do Brasil, de forma curta e direta (até ~6 frases ou uma lista curta).
- Use as FERRAMENTAS para qualquer número sobre lixeiras, coletores, material ou previsões. Nunca invente dados.
- Previsões são estimativas lineares (supõem ritmo constante): deixe isso claro quando der uma data.
- Quando fizer sentido, termine com uma ação recomendada.
- Se o dado pedido não existir no dashboard, diga que não tem essa informação.

Base de conhecimento recuperada (RAG):
${contexto}`;
}

/** Erros temporários do provedor: vale esperar e tentar de novo. */
const STATUS_TEMPORARIOS = new Set([429, 500, 502, 503, 504]);
const ESPERAS_MS = [1000, 3000]; // esperas antes da 2ª e da 3ª tentativa

const esperar = (ms) => new Promise((r) => setTimeout(r, ms));

async function postJson(url, headers, corpo) {
  for (let tentativa = 0; ; tentativa++) {
    const resp = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json", ...headers },
      body: JSON.stringify(corpo),
    });
    if (resp.ok) return resp.json();

    const detalhe = await resp.text();
    const erro = new Error(`LLM respondeu ${resp.status}: ${detalhe.slice(0, 400)}`);
    erro.status = resp.status;

    // Sobrecarga/limite: espera um pouco e tenta de novo (até 2 vezes).
    if (STATUS_TEMPORARIOS.has(resp.status) && tentativa < ESPERAS_MS.length) {
      console.warn(`[Ciclo] ${resp.status} do provedor; tentando de novo em ${ESPERAS_MS[tentativa] / 1000}s...`);
      await esperar(ESPERAS_MS[tentativa]);
      continue;
    }
    throw erro;
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ADAPTADORES DE PROVEDOR
// Cada adaptador sabe: montar a conversa inicial, chamar a API e anexar os
// resultados das ferramentas no formato daquele provedor. O loop do agente
// (perguntarAoLLM) é o mesmo para os dois.
// ═════════════════════════════════════════════════════════════════════════════

/** API nativa do Google Gemini (generateContent). */
const gemini = {
  iniciar(sistema, historico, pergunta) {
    return {
      sistema,
      contents: [
        ...historico.map((m) => ({
          role: m.papel === "ciclo" ? "model" : "user",
          parts: [{ text: m.texto }],
        })),
        { role: "user", parts: [{ text: pergunta }] },
      ],
    };
  },

  async chamar(cfg, estado, { comFerramentas = true } = {}) {
    // O Gemini recusa ferramentas sem parâmetros declaradas com "properties"
    // vazio, então nesses casos o campo "parameters" é omitido.
    const declaracoes = schemasDasFerramentas().map(({ function: f }) => ({
      name: f.name,
      description: f.description,
      ...(Object.keys(f.parameters?.properties ?? {}).length
        ? { parameters: f.parameters }
        : {}),
    }));

    const json = await postJson(
      `${cfg.baseUrl}/models/${encodeURIComponent(cfg.model)}:generateContent`,
      { "x-goog-api-key": cfg.apiKey },
      {
        systemInstruction: { parts: [{ text: estado.sistema }] },
        contents: estado.contents,
        ...(comFerramentas ? { tools: [{ functionDeclarations: declaracoes }] } : {}),
        generationConfig: { temperature: 0.3 },
      },
    );

    const conteudo = json.candidates?.[0]?.content;
    if (!conteudo) {
      const motivo = json.promptFeedback?.blockReason || json.candidates?.[0]?.finishReason;
      throw new Error(`Resposta vazia do Gemini${motivo ? ` (${motivo})` : ""}.`);
    }
    const partes = conteudo.parts ?? [];
    return {
      bruto: conteudo, // devolvido inteiro ao modelo (preserva thoughtSignature)
      texto: partes.filter((p) => p.text && !p.thought).map((p) => p.text).join(""),
      chamadas: partes
        .filter((p) => p.functionCall)
        .map((p) => ({ nome: p.functionCall.name, args: p.functionCall.args ?? {} })),
    };
  },

  anexar(estado, resposta, resultados) {
    estado.contents.push(resposta.bruto);
    estado.contents.push({
      role: "user",
      parts: resultados.map(({ nome, resultado }) => ({
        // "response" precisa ser um objeto; listas vão dentro de "resultado".
        functionResponse: { name: nome, response: { resultado } },
      })),
    });
  },

  pedirFinal(estado) {
    estado.contents.push({
      role: "user",
      parts: [{ text: "Responda agora com o que já tem, sem chamar ferramentas." }],
    });
  },
};

/** APIs no formato Chat Completions da OpenAI. */
const openai = {
  iniciar(sistema, historico, pergunta) {
    return {
      mensagens: [
        { role: "system", content: sistema },
        ...historico.map((m) => ({
          role: m.papel === "ciclo" ? "assistant" : "user",
          content: m.texto,
        })),
        { role: "user", content: pergunta },
      ],
    };
  },

  async chamar(cfg, estado, { comFerramentas = true } = {}) {
    const json = await postJson(
      `${cfg.baseUrl}/chat/completions`,
      { Authorization: `Bearer ${cfg.apiKey}` },
      {
        model: cfg.model,
        messages: estado.mensagens,
        ...(comFerramentas ? { tools: schemasDasFerramentas(), tool_choice: "auto" } : {}),
        temperature: 0.3,
      },
    );
    const msg = json.choices?.[0]?.message;
    if (!msg) throw new Error("Resposta vazia do LLM.");
    return {
      bruto: msg,
      texto: msg.content ?? "",
      chamadas: (msg.tool_calls ?? []).map((c) => {
        let args = {};
        try {
          args = JSON.parse(c.function.arguments || "{}");
        } catch {
          args = {};
        }
        return { id: c.id, nome: c.function.name, args };
      }),
    };
  },

  anexar(estado, resposta, resultados) {
    estado.mensagens.push(resposta.bruto);
    for (const { id, resultado } of resultados) {
      estado.mensagens.push({ role: "tool", tool_call_id: id, content: JSON.stringify(resultado) });
    }
  },

  pedirFinal(estado) {
    estado.mensagens.push({
      role: "user",
      content: "Responda agora com o que já tem, sem chamar ferramentas.",
    });
  },
};

const PROVEDORES = { gemini, openai };

// ═════════════════════════════════════════════════════════════════════════════
// AGENTE
// ═════════════════════════════════════════════════════════════════════════════

/**
 * Responde uma pergunta.
 * @param {string} pergunta
 * @param {object} snapshot  dados atuais do dashboard (ver ciclo.tools.js)
 * @param {Array<{papel:'usuario'|'ciclo', texto:string}>} historico
 * @returns {Promise<{resposta:string, graficos:string[], ferramentas:string[], fontes:string[], modo:string}>}
 */
export async function perguntarAoCiclo(pergunta, snapshot, historico = []) {
  const trechos = buscarConhecimento(pergunta, 3);
  const cfg = config();

  if (!cfg.apiKey) return modoOffline(pergunta, snapshot, trechos);

  for (let i = 0; i < cfg.modelos.length; i++) {
    const model = cfg.modelos[i];
    try {
      return await perguntarAoLLM(pergunta, snapshot, historico, trechos, { ...cfg, model });
    } catch (e) {
      const temReserva = i < cfg.modelos.length - 1;
      // Modelo sobrecarregado ou indisponível: passa para o modelo reserva.
      if (temReserva && (STATUS_TEMPORARIOS.has(e.status) || e.status === 404)) {
        console.warn(`[Ciclo] Modelo ${model} indisponível (${e.status}); usando ${cfg.modelos[i + 1]}.`);
        continue;
      }
      // Sem reserva (ou erro de chave, formato...): não deixa o usuário sem
      // resposta. Registra o motivo e responde no modo offline.
      console.error("[Ciclo] Falha no LLM, usando modo offline:", e.message);
      return modoOffline(pergunta, snapshot, trechos);
    }
  }
  return modoOffline(pergunta, snapshot, trechos);
}

async function perguntarAoLLM(pergunta, snapshot, historico, trechos, cfg) {
  const p = PROVEDORES[cfg.provider];
  if (!p) throw new Error(`CICLO_PROVIDER inválido: "${cfg.provider}" (use gemini ou openai).`);

  console.log(`[Ciclo] Perguntando ao modelo "${cfg.model}" (${cfg.provider}).`);
  const estado = p.iniciar(promptDeSistema(snapshot, trechos), historico.slice(-8), pergunta);
  const usadas = [];

  for (let passo = 0; passo < MAX_PASSOS; passo++) {
    const resposta = await p.chamar(cfg, estado);

    if (resposta.chamadas.length === 0) {
      return montarRetorno(resposta.texto, usadas, trechos, "llm");
    }

    const resultados = resposta.chamadas.map((c) => {
      usadas.push(c.nome);
      return { ...c, resultado: executarFerramenta(c.nome, c.args, snapshot) };
    });
    p.anexar(estado, resposta, resultados);
  }

  // Estourou o limite de passos: pede uma resposta final sem ferramentas.
  p.pedirFinal(estado);
  const final = await p.chamar(cfg, estado, { comFerramentas: false });
  return montarRetorno(final.texto, usadas, trechos, "llm");
}

function montarRetorno(texto, ferramentas, trechos, modo) {
  const graficos = [...new Set(ferramentas.map(graficoDaFerramenta).filter(Boolean))];
  return {
    resposta: texto.trim() || "Não consegui formular uma resposta agora.",
    graficos,
    ferramentas: [...new Set(ferramentas)],
    fontes: [...new Set(trechos.map((t) => t.fonte))],
    modo,
  };
}

// ═════════════════════════════════════════════════════════════════════════════
// MODO OFFLINE (sem chave de API)
// ═════════════════════════════════════════════════════════════════════════════
/**
 * O trecho mais parecido responde MESMO à pergunta? Exige 2 palavras
 * importantes em comum (ou 1, se a pergunta só tiver uma). Ex.: "Quanto custa
 * uma lixeira nova?" só divide "lixeira" com a base, então não serve.
 */
function trechoRelevante(pergunta, trechos) {
  if (!trechos.length) return false;
  const daPergunta = new Set(tokenizar(pergunta));
  const doTrecho = new Set(tokenizar(trechos[0].texto));
  const emComum = [...daPergunta].filter((t) => doTrecho.has(t)).length;
  const exigido = Math.min(2, daPergunta.size);
  return exigido > 0 && emComum >= exigido;
}

const norm = (s) => s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

function modoOffline(pergunta, snapshot, trechos) {
  const p = norm(pergunta);
  const tem = (...palavras) => palavras.some((w) => p.includes(w));
  let ferramenta;
  let texto;

  const lixeiraCitada = snapshot.lixeiras.find((l) =>
    p.includes(norm(l.nome.replace(/^Lixeira\s+/i, ""))),
  );

  const conceitual = tem("o que e ", "o que sao", "o que significa", "como ler", "por que", "para que");

  if (conceitual && trechoRelevante(pergunta, trechos)) {
    ferramenta = "buscar_conhecimento";
    texto = trechos[0].texto.split("\n").slice(1).join("\n").replace(/^##\s*/, "").trim();
  } else if (tem("prev", "quando", "encher", "enche", "futuro", "semana", "amanha")) {
    ferramenta = "prever_enchimento";
    const r = executarFerramenta(ferramenta, lixeiraCitada ? { nome: lixeiraCitada.nome } : {}, snapshot);
    const lista = Array.isArray(r) ? r.filter((x) => x.diasParaEncher !== null).slice(0, 4) : [r];
    texto = lista.length
      ? "Previsão de enchimento (estimativa linear, supondo o ritmo atual):\n" +
        lista
          .map((x) =>
            x.diasParaEncher === 0
              ? `• ${x.nome}: já está cheia (${x.ocupacao}%), coletar hoje.`
              : x.diasParaEncher == null
                ? `• ${x.nome}: ${x.previsao}`
                : `• ${x.nome}: ${x.ocupacao}% hoje, deve encher em ${x.emTexto} (${x.dataEstimada}).`,
          )
          .join("\n")
      : "Ainda não há histórico suficiente para prever o enchimento.";
  } else if (lixeiraCitada) {
    ferramenta = "detalhes_lixeira";
    const l = lixeiraCitada;
    const mat = Object.entries(l.composicao ?? {}).sort((a, b) => b[1] - a[1])[0];
    texto = `${l.nome} está com ${l.ocupacao}% de ocupação (${l.status})` +
      (mat ? `, com predominância de ${mat[0]} (${mat[1]}%)` : "") + ".";
  } else if (tem("coletor", "equipe", "ranking", "desempenho")) {
    ferramenta = "desempenho_coletores";
    const r = executarFerramenta(ferramenta, {}, snapshot);
    const baixos = r.ranking.filter((c) => c.abaixoDaMedia).map((c) => c.nome);
    texto = `A equipe faz em média ${r.media} coletas por coletor. ` +
      (r.ranking[0] ? `${r.ranking[0].nome} lidera com ${r.ranking[0].coletas}. ` : "") +
      (baixos.length ? `Abaixo da média: ${baixos.join(", ")}; vale revisar a rota dessas pessoas.` : "A carga está bem distribuída.");
  } else if (tem("material", "residuo", "plastico", "vidro", "metal", "papel", "composi", "rosca")) {
    ferramenta = "composicao_residuos";
    const r = executarFerramenta(ferramenta, {}, snapshot);
    if (!r.predominante) {
      texto = "O dashboard ainda não tem dados de composição de material para analisar.";
    } else texto = "Composição geral: " +
      Object.entries(r.composicao).map(([k, v]) => `${k} ${v}%`).join(", ") +
      (r.predominante ? `. ${r.predominante} é o material predominante; vale avaliar coleta seletiva ou parceria de reciclagem para ele.` : ".");
  } else if (tem("rota", "prioridad", "coletar", "cheia", "urgente", "primeiro")) {
    ferramenta = "lixeiras_prioritarias";
    const r = executarFerramenta(ferramenta, { minimo: 70 }, snapshot);
    texto = r.length
      ? "Prioridade de coleta hoje:\n" + r.map((l, i) => `${i + 1}. ${l.nome}: ${l.ocupacao}%`).join("\n")
      : "Nenhuma lixeira está acima de 70% agora.";
  } else if (tem("atividade", "ultimas", "recente", "aconteceu", "historico")) {
    ferramenta = "atividades_recentes";
    const r = executarFerramenta(ferramenta, { limite: 5 }, snapshot);
    texto = r.length
      ? "Últimas atividades:\n" +
        r.map((a) =>
          a.descricao
            ? `• ${a.descricao} (${a.quando})`
            : `• ${a.coletor} coletou ${a.lixeira} (${a.ocupacao}% cheia)`,
        ).join("\n")
      : "Nenhuma atividade registrada ainda.";
  } else if (tem("resumo", "geral", "como esta", "situacao", "insight", "visao")) {
    ferramenta = "resumo_dashboard";
    const k = snapshot.kpis ?? {};
    const coletas = k.coletas30d != null
      ? ` e ${k.coletas30d} coletas nos últimos 30 dias`
      : k.coletasSemana != null ? ` e ${k.coletasSemana} coletas nesta semana` : "";
    texto = `${snapshot.instituicao}: ${k.lixeiras} lixeiras, ocupação média de ${k.ocupacaoMedia}%, ` +
      `${k.paraColetar ?? 0} para coletar${coletas}.` +
      (k.ocupacaoMedia >= 70 ? " A média está alta: a frequência de coleta parece abaixo da geração de lixo." : "");
  } else if (trechoRelevante(pergunta, trechos)) {
    ferramenta = "buscar_conhecimento";
    texto = trechos[0].texto.split("\n").slice(1).join("\n").replace(/^##\s*/, "").trim();
  } else {
    texto = "Não tenho essa informação no Dashboard. Posso ajudar com: resumo do dashboard, prioridade de coleta, previsão de enchimento, composição de material, coletores e atividades.";
  }

  const r = montarRetorno(texto, ferramenta ? [ferramenta] : [], trechos, "offline");
  return r;
}
