import { readdirSync, readFileSync } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

/**
 * RAG (Retrieval-Augmented Generation) do Ciclo — busca por palavra-chave
 * (TF-IDF + similaridade de cosseno), sem depender de nenhuma API externa
 * de embeddings. Isso mantém a recuperação rápida, offline e gratuita.
 * É a mesma técnica explicada passo a passo no notebook
 * `ciclo/ciclo_rag.ipynb` (lá feita com scikit-learn).
 *
 * Pipeline:
 *   1. Carrega os arquivos .md de `data/ciclo-knowledge/` (a "base de
 *      conhecimento" do Ciclo).
 *   2. Parte (chunk) cada arquivo em pedaços menores, por seção (##).
 *   3. Monta um índice TF-IDF desses pedaços.
 *   4. Em cada pergunta, calcula a similaridade da pergunta com cada pedaço
 *      e devolve os `topK` mais parecidos — esse é o "R" (Retrieval) do RAG.
 */

const __dirname = dirname(fileURLToPath(import.meta.url));
const KNOWLEDGE_DIR = join(__dirname, "..", "data", "ciclo-knowledge");

// ── Tokenização e utilidades de texto ───────────────────────────────────────
const STOPWORDS = new Set([
  "a", "o", "as", "os", "de", "da", "do", "das", "dos", "e", "ou", "que",
  "com", "em", "no", "na", "nos", "nas", "um", "uma", "uns", "umas", "é",
  "ao", "aos", "à", "às", "se", "por", "para", "como", "mais", "menos",
  "seu", "sua", "seus", "suas", "ele", "ela", "eles", "elas", "ser", "está",
  "estão", "foi", "são", "isso", "esse", "essa", "este", "esta", "num",
  "numa", "quando", "cada", "já", "não", "sim",
]);

function normalizar(texto) {
  return texto
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, ""); // remove acentos
}

export function tokenizar(texto) {
  return normalizar(texto)
    .replace(/[^a-z0-9\s]/g, " ")
    .split(/\s+/)
    .filter((t) => t.length > 2 && !STOPWORDS.has(t));
}

// ── Carregamento e chunking dos documentos ──────────────────────────────────
function carregarDocumentos() {
  const arquivos = readdirSync(KNOWLEDGE_DIR).filter((f) => f.endsWith(".md"));
  const chunks = [];

  for (const arquivo of arquivos) {
    const conteudo = readFileSync(join(KNOWLEDGE_DIR, arquivo), "utf-8");
    // Cada "## Seção" vira um chunk; o título do arquivo (# Título) é
    // prefixado em todos os chunks para dar contexto a quem só vê o pedaço.
    const tituloDoc = (conteudo.match(/^#\s+(.+)$/m) || [, arquivo])[1];
    const secoes = conteudo.split(/\n(?=##\s)/g);

    for (const secao of secoes) {
      let texto = secao.trim();
      // O 1º pedaço começa com o título do documento ("# ..."): tira só a
      // linha do título e mantém o texto que vem depois (documentos sem "##",
      // como 04-ciclo.md, são inteiros esse 1º pedaço).
      if (texto.startsWith("# ")) texto = texto.split("\n").slice(1).join("\n").trim();
      if (!texto) continue;
      chunks.push({
        fonte: arquivo,
        titulo: tituloDoc,
        texto: `${tituloDoc}\n${texto}`,
      });
    }
  }
  return chunks;
}

// ── Índice TF-IDF ────────────────────────────────────────────────────────────
class IndiceTfIdf {
  constructor(chunks) {
    this.chunks = chunks;
    this.docFreq = new Map(); // termo -> em quantos chunks aparece
    this.vetores = chunks.map((c) => this._contagens(c.texto));

    for (const vetor of this.vetores) {
      for (const termo of vetor.keys()) {
        this.docFreq.set(termo, (this.docFreq.get(termo) ?? 0) + 1);
      }
    }
    this.n = chunks.length;
    this.pesos = this.vetores.map((v) => this._tfIdf(v));
  }

  _contagens(texto) {
    const contagens = new Map();
    for (const termo of tokenizar(texto)) {
      contagens.set(termo, (contagens.get(termo) ?? 0) + 1);
    }
    return contagens;
  }

  _tfIdf(contagens) {
    const pesos = new Map();
    for (const [termo, freq] of contagens) {
      const idf = Math.log((this.n + 1) / ((this.docFreq.get(termo) ?? 0) + 1)) + 1;
      pesos.set(termo, freq * idf);
    }
    return pesos;
  }

  _similaridade(a, b) {
    let produto = 0;
    let normaA = 0;
    let normaB = 0;
    for (const [termo, peso] of a) {
      normaA += peso * peso;
      if (b.has(termo)) produto += peso * b.get(termo);
    }
    for (const peso of b.values()) normaB += peso * peso;
    if (normaA === 0 || normaB === 0) return 0;
    return produto / (Math.sqrt(normaA) * Math.sqrt(normaB));
  }

  /** Devolve os `topK` chunks mais similares à `pergunta`. */
  buscar(pergunta, topK = 3) {
    const consulta = this._tfIdf(this._contagens(pergunta));
    return this.pesos
      .map((pesoChunk, i) => ({
        chunk: this.chunks[i],
        score: this._similaridade(consulta, pesoChunk),
      }))
      .filter((r) => r.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, topK);
  }
}

let _indice = null;

function indice() {
  if (!_indice) _indice = new IndiceTfIdf(carregarDocumentos());
  return _indice;
}

/**
 * Recupera os trechos da base de conhecimento mais relevantes para a
 * pergunta do usuário. É a etapa "Retrieval" chamada pelo `ciclo.service.js`
 * antes de montar o prompt do modelo ("Augmented Generation").
 */
export function buscarConhecimento(pergunta, topK = 3) {
  return indice()
    .buscar(pergunta, topK)
    .map((r) => ({ fonte: r.chunk.fonte, texto: r.chunk.texto, score: r.score }));
}
