import trashService from '../Services/trash.service.js';

class TrashController {
    static async getAllTrashes(req, res) {
        try {
            res.status(200).json(await trashService.getAllTrashes());
        }
        catch (error) {
            console.error(error)
            res.status(500).send('Erro ao buscar lixeiras');
        }
    }

    static async getAllTrashesByUser(req, res) {
        try {
            res.status(200).json(await trashService.getAllTrashesByUser(req.query.userId));
        }
        catch (error) {
            console.error(error)
            res.status(500).send('Erro ao buscar lixeiras do usuário');
        }
    }

    static async newTrash(req, res) {
        try {
            res.status(201).json(await trashService.newTrash(req.body));
        }
        catch (error) {
            console.error(error)
            res.status(500).send('Erro ao criar lixeira');
        }
    }

    static async deleteTrash(req, res) {
        try {
            res.status(200).json(await trashService.deleteTrash(req.query.trsId));
        }
        catch (error) {
            console.error(error)
            res.status(500).send('Erro ao excluir lixeira');
        }
    }

    static async colectTrash(req, res) {
        try {
            res.status(200).json(await trashService.colectTrash(req.body.trashId, req.body.residuos, req.body.idColector, req.body.nameColector, req.body.organizationId, req.body.tipoResiduo));
        }
        catch (error) {
            console.error(error)
            res.status(500).send('Erro ao coletar lixeira');
        }
    }
}


export default TrashController;