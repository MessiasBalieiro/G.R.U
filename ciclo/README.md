# Ciclo — chatbot com RAG do Dashboard do G.R.U

O **Ciclo** é o assistente do Dashboard do Administrador, no **app Android** e no **site**. Gera insights, faz previsões de enchimento das lixeiras e ajuda a decidir ações, sempre com base nos dados dos gráficos.

- **Modelo:** Google Gemini (`gemini-2.5-flash`) pela API REST nativa (`generateContent`), que aceita as chaves novas do AI Studio (`AQ.`). Também dá para usar qualquer API no formato da OpenAI com `CICLO_PROVIDER=openai`.
- **RAG:** base de conhecimento em Markdown + TF-IDF + similaridade de cosseno.
- **Agente:** function calling com 8 ferramentas sobre os dados do Dashboard (padrão ReAct).
- **Gradio:** interface do chatbot no notebook [`ciclo_rag.ipynb`](ciclo_rag.ipynb), que também documenta os 4 tópicos pedidos.

## Arquitetura

```
App Android / Site ──POST /ciclo/chat { pergunta, snapshot, historico }──► Backend Node
   (snapshot = dados atuais dos gráficos)                                   ├─ RAG (TF-IDF)
                                                                            ├─ Agente + ferramentas
                                                                            └─ Gemini API
                   ◄── { resposta, graficos, ferramentas, fontes, modo } ──┘
```

A chave da API fica **só no servidor**. Nunca coloque a chave no app ou no site: qualquer pessoa conseguiria extraí-la do APK ou do JavaScript do navegador.

## Correlação com os gráficos

- Cada gráfico do Dashboard tem um botão ✨ **Perguntar ao Ciclo**, que abre o chat já com uma pergunta sobre ele.
- Cada resposta informa quais gráficos o Ciclo usou (campo `graficos`). O gráfico ganha um contorno verde pulsante, e o chip **"Ver gráfico"** leva até ele. No site, o chip também troca a seção da barra lateral.

| Ferramenta | Gráfico |
|---|---|
| `resumo_dashboard` | KPIs |
| `lixeiras_prioritarias`, `detalhes_lixeira`, `prever_enchimento` | Ocupação por lixeira |
| `composicao_residuos` | Tipos de resíduo / Status das lixeiras |
| `desempenho_coletores` | Ranking / Gráficos dos coletores |
| `atividades_recentes` | Atividades recentes |
| `buscar_conhecimento` | (base do RAG) |

## Como rodar

### 1. Chave da API (grátis)
Gere em <https://aistudio.google.com/apikey>. Sem chave, o Ciclo roda em **modo offline**: mesmas ferramentas e mesmo RAG, mas escolhendo a ferramenta por palavra-chave e com respostas mais simples.

### 2. Backend
```bash
cd backend
cp .env.example .env        # e preencha CICLO_API_KEY no .env (nunca no .env.example)
npm install
npm run reload              # sobe em http://localhost:3000
```

Teste rápido:
```bash
curl -X POST localhost:3000/ciclo/chat -H "Content-Type: application/json" \
  -d '{"pergunta":"resumo geral","snapshot":{"instituicao":"Teste","kpis":{"lixeiras":1,"ocupacaoMedia":80,"paraColetar":1},"lixeiras":[]}}'
```

### 3. Site
```bash
cd frontend/gru
flutter pub get
flutter run -d chrome --dart-define=GRU_API_URL=http://localhost:3000
```

### 4. App Android
```bash
cd frontend/gru_app
flutter pub get
# Emulador (10.0.2.2 = localhost do PC):
flutter run
# Celular físico: use o IP do PC na rede Wi-Fi (mesma rede do celular)
flutter run --dart-define=GRU_API_URL=http://192.168.0.10:3000
```
No Windows, o IP do PC aparece com `ipconfig` (campo "Endereço IPv4"). Se o celular não conectar, libere a porta 3000 no Firewall do Windows.

### 5. Notebook (Gradio)
Abra `ciclo/ciclo_rag.ipynb` no Jupyter, VS Code ou Google Colab, defina `CICLO_API_KEY` e execute as células em ordem. A última abre a interface do Gradio.

## Arquivos

| Arquivo | Conteúdo |
|---|---|
| `ciclo/ciclo_rag.ipynb` | Notebook comentado + chatbot em Gradio |
| `backend/src/data/ciclo-knowledge/*.md` | Base de conhecimento do RAG (edite para ensinar coisas novas ao Ciclo) |
| `backend/src/services/ciclo.rag.service.js` | Chunking, TF-IDF e recuperação |
| `backend/src/services/ciclo.tools.js` | Ferramentas e previsão de enchimento |
| `backend/src/services/ciclo.service.js` | Loop do agente, chamada ao LLM e modo offline |
| `backend/src/routes/ciclo.route.js` | Rota `POST /ciclo/chat` |
| `frontend/*/lib/**/ciclo/` | Chat, botão flutuante e destaque dos gráficos (app e site) |
| `frontend/*/lib/data/services/ciclo_service.dart` | Chamada à API e montagem do snapshot |

## Limitações conhecidas
- A previsão é **linear** (supõe ritmo constante desde a última coleta).
- O site ainda não tem histórico de coletas nem composição no backend; esses dados vêm de um mock (`MockDataService.sensores`), assim como os dados do app.
- A camada gratuita do Gemini tem limite de requisições por minuto.
