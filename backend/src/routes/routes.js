import residueRoutes from './residue.route.js'
import trashRoutes from './trash.route.js'
import userRoutes from './user.route.js'
import { Router } from 'express'

const routes = Router()

routes.get("/", (req, res) => {
    res.send("Olá!")
})

export default (app) => {
    app.use("/residues", residueRoutes)
    app.use("/trashes", trashRoutes)
    app.use("/users", userRoutes)
    app.use(routes)
}