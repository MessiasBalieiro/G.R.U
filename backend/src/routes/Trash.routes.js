import { Router } from "express";
import trashController from "../Controllers/trash.controller.js"

const router = Router();

router.get("/all-trashes", trashController.getAllTrashes);

router.get("/all-trashes-by-user", trashController.getAllTrashesByUser);

router.post("/new-trash", trashController.newTrash);

router.delete("/delete-trash", trashController.deleteTrash);

router.post("/colect-trash", trashController.colectTrash);

export default router;