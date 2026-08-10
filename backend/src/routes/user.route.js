import userController from '../controllers/user.controller.js'
import { Router } from 'express'

const userRoutes = Router()

userRoutes.get("/all-users", userController.getAllUsers)

export default userRoutes;