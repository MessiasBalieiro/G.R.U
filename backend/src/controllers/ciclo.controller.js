import { perguntarAoCiclo } from "../services/ciclo.service.js";

/**
 * POST /ciclo/chat
 * Body: { pergunta: string, snapshot: {...dados do dashboard}, historico?: [...] }
 */
async function chat(req, res) {
  const { pergunta, snapshot, historico } = req.body ?? {};

  if (!pergunta || typeof pergunta !== "string" || !pergunta.trim()) {
    return res.status(400).json({ erro: "Envie o campo 'pergunta'." });
  }
  if (!snapshot || !Array.isArray(snapshot.lixeiras)) {
    return res.status(400).json({ erro: "Envie o 'snapshot' do dashboard." });
  }

  try {
    const resultado = await perguntarAoCiclo(
      pergunta.trim().slice(0, 1000),
      snapshot,
      Array.isArray(historico) ? historico : [],
    );
    return res.json(resultado);
  } catch (e) {
    console.error("[Ciclo]", e);
    return res.status(502).json({ erro: "O Ciclo não conseguiu responder agora. Tente de novo." });
  }
}

export default { chat };
