import cicloController from "../controllers/ciclo.controller.js";
import { Router } from "express";

const cicloRoutes = Router();

cicloRoutes.post("/chat", cicloController.chat);

export default cicloRoutes;
