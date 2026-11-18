import residueService from '../Services/residue.service.js';

class ResidueController {
    static async getAllResidues(req, res) {
        try {
            const allResidues = await residueService.getAllResidues();
            res.status(200).json(allResidues);
        }
        catch (error) {
            console.error(error);
            res.status(500).send('Erro ao buscar resíduos');
        }
    }

    static async newResidue(req, res) {
        try {
            const newResidue = await residueService.newResidue(req.body);
            res.status(201).json(newResidue);
        }
        catch (error) {
            console.error(error);
            res.status(500).send('Erro ao criar resíduo');
        }
    }
}

export default ResidueController;