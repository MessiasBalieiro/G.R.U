import cicloController from "../Controllers/Ciclo.controller.js";
import { Router } from "express";

const cicloRoutes = Router();

cicloRoutes.post("/chat", cicloController.chat);

export default cicloRoutes;
