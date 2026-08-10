import trashService from '../services/trash.service.js';

class TrashController {
    static async getAllTrashes(req, res) {
        res.status(200).json(await trashService.getAllTrashes())
    }
}

export default TrashController