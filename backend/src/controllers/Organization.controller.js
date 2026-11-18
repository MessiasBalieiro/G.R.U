import organizationService from '../Services/organization.service.js';

class OrganizationController {
    static async getAllOrganizations(req, res) {
        try {
            const allOrganizations = await organizationService.getAllOrganizations();
            res.status(200).json(allOrganizations);
        }
        catch (error) {
            console.error(error);
            res.status(500).send('Erro ao buscar organizações');
        }
    }

    static async createOrganization(req, res) {
        try {
            const newOrganization = await organizationService.createOrganization(req.body);
            res.status(201).json(newOrganization);
        }
        catch (error) {
            console.error(error);
            res.status(500).send('Erro ao criar organização');
        }
    }

    static async getThisOrganization(req, res) {
        try {
            const thisOrganization = await organizationService.getThisOrganization(req.query.idCon);
            res.status(200).json(thisOrganization);
        }
        catch (error) {
            console.error(error);
            res.status(500).send('Erro ao buscar organização.');
        }
    }

    static async getThisOrganizationById(req, res) {
        try {
            const thisOrganization = await organizationService.getThisOrganizationById(req.query.idOrg);
            res.status(200).json(thisOrganization);
        }
        catch (error) {
            console.error(error);
            res.status(500).send('Erro ao buscar organização.');
        }
    }

    static async addTrashToOrganization(req, res) {
        try {
            res.status(200).json(await organizationService.addTrashToOrganization(req.body, req.body.idOrg));
        }
        catch (error) {
            console.error(error);
            res.status(500).send('Erro ao adicionar lixeira à organização');
        }
    }

    static async removeTrashFromOrganization(req, res) {
        try {
            await organizationService.removeTrashFromOrganization(req.body.id_trs, req.body.idOrg)
            res.status(200).send('Lixeira removida da organização com sucesso')
        }
        catch (error) {
            console.log(error)
            res.status(500).send('Erro ao deletar lixeira da organização')
        }
    }

    static async addColectorToOrganization(req, res) {
        try {
            await organizationService.addColectorToOrganization(req.body.cltCpf, req.body.idOrg);
            res.status(200).send('Coletor adicionado à organização com sucesso!');
        } catch (error) {
            console.log(error)
            res.status(500).send('Erro ao adicionar coletor à organização')
        }
    }

    static async removeColectorFromOrganization(req, res) {
        try {
            await organizationService.removeColectorFromOrganization(req.body.cltId, req.body.idOrg);
            res.status(200).send('Coletor removido da organização com sucesso');
        } catch (error) {
            console.log(error)
            res.status(500).send('Erro ao deletar coletor da organização')
        }
    }
}

export default OrganizationController;