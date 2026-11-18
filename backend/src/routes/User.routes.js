import { Router } from 'express';
import userController from '../Controllers/user.controller.js';

const router = Router();

router.get('/all-users', userController.getAllUsers);

router.post("/this-user", userController.getThisUser);

router.post("/this-colectors", userController.getThisColectos);

router.post("/login", userController.login);

router.post("/social-login", userController.socialLogin);

router.post("/create-user", userController.createUser);

export default router;