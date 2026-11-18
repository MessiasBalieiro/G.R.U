import { Router } from "express";
import residueController from "../Controllers/residue.controller.js";

const router = Router();

router.get("/all-residues", residueController.getAllResidues);
router.post("/new-residue", residueController.newResidue);

export default router;