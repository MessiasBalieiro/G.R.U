import express from "express"
import dotenv from "dotenv"
import routes from "./routes/routes.js"

const app = express();

dotenv.config()
app.use(express.json())
routes(app)

export default app;