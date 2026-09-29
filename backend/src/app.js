import express from "express"
import dotenv from "dotenv"
import routes from "./routes/routes.js"

const app = express();

dotenv.config()

// CORS: o site (Flutter Web) roda em outra origem/porta e precisa
// chamar a API pelo navegador. Em produção, troque "*" pelo domínio do site.
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", process.env.CORS_ORIGIN || "*")
    res.header("Access-Control-Allow-Headers", "Content-Type, Authorization")
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    if (req.method === "OPTIONS") return res.sendStatus(204)
    next()
})

app.use(express.json({ limit: "1mb" }))
routes(app)

export default app;