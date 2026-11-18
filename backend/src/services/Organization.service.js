import organizationModel from '../Models/Organization.model.js';
import trashService from '../Services/trash.service.js'
import userService from '../Services/user.service.js'
import mongoose from 'mongoose';

class OrganizationService {
    static async getAllOrganizations() {
        try {
            const allOrganizations = await organizationModel.find();
            return allOrganizations;
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async createOrganization(body) {
        try {
            const newOrganization = await organizationModel.create(body);
            return newOrganization;
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async getThisOrganization(idContratante) {
        try {
            const thisOrganization = await organizationModel.findOne({id_contratante: idContratante});
            return thisOrganization;
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async getThisOrganizationById(idOrganization) {
        try {
            const thisOrganization = await organizationModel.findOne({_id: idOrganization});
            return thisOrganization;
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async addTrashToOrganization(body, organizationId) {
        try {
            const newTrash = await trashService.newTrash(body);
            await organizationModel.findByIdAndUpdate(organizationId, {$push: {trashes: newTrash._id}});
            await this.addHistoryToOrganization(organizationId, {
                type_object: 'Lixeiras',
                id_object: newTrash._id,
                action_object: `Lixeira "${newTrash.nome_lixeira}" adicionada à organização`,
                time_action_object: new Date().toLocaleString('pt-BR', {day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'America/Sao_Paulo'}),
                user_action_object: null,
                username_action_object: ''
            });

            return newTrash
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async removeTrashFromOrganization(trashId, organizationId) {
        try {
            const deletedTrash = await trashService.deleteTrash(trashId);
            await organizationModel.findByIdAndUpdate(organizationId, {$pop: {trashes: new mongoose.Types.ObjectId(trashId)}})
            await this.addHistoryToOrganization(organizationId, {
                type_object: 'Lixeiras',
                id_object: deletedTrash._id,
                action_object: `Lixeira "${deletedTrash.nome_lixeira}" removida da organização`,
                time_action_object: new Date().toLocaleString('pt-BR', {day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'America/Sao_Paulo'}),
                user_action_object: null,
                username_action_object: ''
            });
        }
        catch (error) {
            throw new Error(error.message)
        }
    }

    static async addColectorToOrganization(colectorCpf, organizationId) {
        try {
            const thisColector = await userService.getThisUser(colectorCpf, "COLETOR");
            await organizationModel.findByIdAndUpdate(organizationId, {$push: {colectors: thisColector._id}});
            await this.addHistoryToOrganization(organizationId, {
                type_object: 'Usuarios',
                id_object: thisColector._id,
                action_object: `Coletor "${thisColector.nome_usuario}" adicionado à organização`,
                time_action_object: new Date().toLocaleString('pt-BR', {day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'America/Sao_Paulo'}),
                user_action_object: null,
                username_action_object: ''
            });

            thisColector.instituicoes.push(new mongoose.Types.ObjectId(organizationId));
            await thisColector.save()
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async removeColectorFromOrganization(colectorCpf, organizationId) {
        try {
            const deletedColector = await userService.getThisUser(colectorCpf, "COLETOR");
            await organizationModel.findByIdAndUpdate(organizationId, {$pull: {colectors: new mongoose.Types.ObjectId(deletedColector._id)}});
            await this.addHistoryToOrganization(organizationId, {
                type_object: 'Usuarios',
                id_object: deletedColector._id,
                action_object: `Coletor "${deletedColector.nome_usuario}" removido da organização`,
                time_action_object: new Date().toLocaleString('pt-BR', {day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'America/Sao_Paulo'}),
                user_action_object: null,
                username_action_object: ''
            });

            deletedColector.instituicoes.pull(new mongoose.Types.ObjectId(organizationId));
            await deletedColector.save()
        } catch (error) {
            throw new Error(error.message);
        }
    }

    static async addHistoryToOrganization(organizationId, history) {
        try {
            const historyFormatted = {
                type_object: history.type_object,
                id_object: new mongoose.Types.ObjectId(history.id_object),
                action_object: history.action_object,
                time_action_object: history.time_action_object,
                user_action_object: history.user_action_object ? new mongoose.Types.ObjectId(history.user_action_object) : null,
                username_action_object: history.username_action_object
            }

            await organizationModel.findByIdAndUpdate(organizationId, {$push: {history: {$each: [historyFormatted], $position: 0}}});
        
        } catch (error) {
            throw new Error(error.message);
        }
    }
}

export default OrganizationService;