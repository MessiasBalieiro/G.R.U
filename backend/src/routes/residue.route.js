import residueController from '../controllers/residue.controller.js'
import { Router } from 'express'

const residueRoutes = Router()

residueRoutes.get("all-residues", residueController.getAllResidues)

export default residueRoutes;