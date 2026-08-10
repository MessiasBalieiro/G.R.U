import residueService from '../services/residue.service.js';

export default class ResidueController {
    static async getAllResidues(req, res) {
        res.status(200).json(await residueService.getAllResidues());
    }
}