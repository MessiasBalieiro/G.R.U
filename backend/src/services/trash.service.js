import trashModel from '../Models/trash.model.js';
import userService from './user.service.js';
import organizationService from './organization.service.js';
import userModel from '../Models/user.model.js';

class TrashService {
    static async getAllTrashes() {
        try {
            const allTrashes = await trashModel.find({});
            return allTrashes;
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async getAllTrashesByUser(userId) {
        try {
            const allTrashesByUser = await trashModel.find({ codigo_dono_lixeira: userId });
            return allTrashesByUser;
        } catch (error) {
            throw new Error(error.message);
        }
    }

    static async newTrash(trashData) {
        try {
            const thisUser = await userService.getThisUser(trashData.cpf_contratante, "CONTRATANTE");

            if(thisUser) {
                const newTrash = await trashModel.create({ nome_lixeira: trashData.nome_lixeira, codigo_dono_lixeira: thisUser._id, endereco_lixeira: trashData.endereco_lixeira, coordenada: trashData.coordenada, status_lixeira: 0 });
                return newTrash;
            }
            else {
                return { message: "Usuário não encontrado ou não é um contratante" };
            }

            console.log("Lixeira cadastrada com sucesso!");
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async deleteTrash(trashId) {
        try {
            const deletedTrash = await trashModel.findByIdAndDelete(trashId, { returnDocument: 'after' });
            return deletedTrash;
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async colectTrash(trashId, residuos, idColector, nameColector, organizationId, tipoResiduo) {
        try {
            const updatedTrash = await this.updateTrashStatus(trashId, residuos, idColector, nameColector, organizationId, tipoResiduo);
            const ownerTrash = await userModel.findOne({_id: updatedTrash.codigo_dono_lixeira});
            await userService.addHistory(idColector, trashId, updatedTrash.nome_lixeira, `Você recolheu os resíduos da Lixeira "${updatedTrash.nome_lixeira}" pertencente à "${ownerTrash.nome_usuario}"`, new Date().toLocaleString('pt-BR', {day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'America/Sao_Paulo'}));
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static async updateTrashStatus(trashId, residuos, idColector, nameColector, organizationId, tipoResiduo) {
        try {
            const trash = await trashModel.findById(trashId);
            var updatedTrash

            if(residuos == -1) {
                updatedTrash = await trashModel.findByIdAndUpdate(trashId, { $set: { quantidade_residuo: 0, status_lixeira: this.updateStatus(0), 'composicao.quantPlastico': 0, 'composicao.quantVidro': 0, 'composicao.quantMetal': 0, 'composicao.quantPapel': 0 } }, { returnDocument: 'after' });
                
                await organizationService.addHistoryToOrganization(organizationId, {
                    type_object: 'Lixeiras',
                    id_object: trashId,
                    action_object: `O Coletor "${nameColector}" mudou o status da Lixeira "${trash.nome_lixeira}" para "Vazia", coletando seus resíduos`,
                    time_action_object: new Date().toLocaleString('pt-BR', {day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'America/Sao_Paulo'}),
                    user_action_object: idColector,
                    username_action_object: nameColector
                });
            }
            else {
                if(tipoResiduo == "Plástico") {
                    updatedTrash = await trashModel.findByIdAndUpdate(trashId, { $set: { quantidade_residuo: trash.quantidade_residuo + residuos, status_lixeira: this.updateStatus(trash.quantidade_residuo + residuos), 'composicao.quantPlastico': residuos } }, { returnDocument: 'after' });
                }
                else if(tipoResiduo == "Vidro") {
                    updatedTrash = await trashModel.findByIdAndUpdate(trashId, { $set: { quantidade_residuo: trash.quantidade_residuo + residuos, status_lixeira: this.updateStatus(trash.quantidade_residuo + residuos), 'composicao.quantVidro': residuos } }, { returnDocument: 'after' });
                }
                else if(tipoResiduo == "Metal") {
                    updatedTrash = await trashModel.findByIdAndUpdate(trashId, { $set: { quantidade_residuo: trash.quantidade_residuo + residuos, status_lixeira: this.updateStatus(trash.quantidade_residuo + residuos), 'composicao.quantMetal': residuos } }, { returnDocument: 'after' });
                }
                else {
                    updatedTrash = await trashModel.findByIdAndUpdate(trashId, { $set: { quantidade_residuo: trash.quantidade_residuo + residuos, status_lixeira: this.updateStatus(trash.quantidade_residuo + residuos), 'composicao.quantPapel': residuos } }, { returnDocument: 'after' });
                }

                if(trash.status_lixeira != updatedTrash.status_lixeira) {
                    await organizationService.addHistoryToOrganization(organizationId, {
                        type_object: 'Lixeiras',
                        id_object: trashId,
                        action_object: `Lixeira "${trash.nome_lixeira}" mudou de status para "${updatedTrash.status_lixeira === 1 ? "Ocupação baixa" : updatedTrash.status_lixeira === 2 ? "Ocupação média" : updatedTrash.status_lixeira === 3 ? "Ocupação alta" : "Cheia"}"`,
                        time_action_object: new Date().toLocaleString('pt-BR', {day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'America/Sao_Paulo'}),
                        user_action_object: null,
                        username_action_object: ''
                    });
                }

            }

            return updatedTrash;
        }
        catch (error) {
            throw new Error(error.message);
        }
    }

    static updateStatus(quantidade_residuo) {
        if(quantidade_residuo > 0 && quantidade_residuo < 45) {
            return 1
        }
        else if(quantidade_residuo > 45 && quantidade_residuo < 90) {
            return 2
        }
        else if(quantidade_residuo > 90 && quantidade_residuo < 120) {
            return 3
        }
        else if(quantidade_residuo > 120) {
            return 4
        }
        else {
            return 0
        }
    }
}

export default TrashService;