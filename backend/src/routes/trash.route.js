import trashController from '../controllers/trash.controller.js'
import { Router } from 'express'

const trashRoutes = Router()

trashRoutes.get("/all-trashes", trashController.getAllTrashes)

export default trashRoutes;