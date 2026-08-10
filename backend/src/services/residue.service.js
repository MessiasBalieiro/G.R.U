import residueModel from '../models/residue.model.js';

export default class ResidueService {
    static async getAllResidues() {
        try {
            const allResidues = await residueModel.find({});
            return allResidues;
        }
        catch (error) {
            console.error("Error: ", error);
            return "Something didn't happen as expected. Please, try again later."
        }
    }
}