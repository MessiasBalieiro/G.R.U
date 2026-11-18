import residueModel from '../Models/residue.model.js';
import trashService from './trash.service.js';

class ResidueService {
    static async getAllResidues() {
        try {
            const allResidues = await residueModel.find({});
            return allResidues;
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async newResidue(residueData) {
        try {
            const newResidue = await residueModel.create(residueData);
            await trashService.updateTrashStatus(residueData.id_lixeira, residueData.quantidade, "", "", residueData.organizationId, residueData.tipo_residuo);
            return newResidue;
        }
        catch (error) {
            throw new Error(error.message);
        }
    }
}

export default ResidueService;