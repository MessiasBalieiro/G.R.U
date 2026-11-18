import mongoose from 'mongoose';
import userModel from '../Models/user.model.js';
import OrganizationService from './organization.service.js';

class UserService {
    // REQUISITADOS
    
    static async getAllUsers() {
        try {
            const allUsers = await userModel.find({});
            return allUsers;
        }
        catch (error) {
            console.error("Erro: " + error);
            throw new Error('Erro ao buscar usuários');
        }
    }

    static async getThisUser(cpf, role) {
        try {
            const thisUser = await userModel.findOne({cpf_usuario: cpf, cargo_usuario: role});
            console.log("Usuário encontrado: ", thisUser);
            return thisUser;
        } catch (error) {
            throw new Error(error.message)
        }
    }

    static async getThisColectos(ids) {
        try {
            const thisColectors = await userModel.find({_id: {$in: ids}});
            console.log("Coletores encontrados: ", thisColectors);
            return thisColectors;
        } catch (error) {
            throw new Error(error.message)
        }
    }

    static async login(email, senha) {
        try {
            const thisUser = await userModel.findOne({email_usuario: email, senha_usuario: senha});
            return thisUser;
        } catch (error) {
            throw new Error(error.message)
        }
    }

    static async createUser(userData) {
        try {
            const newUser = await userModel.create(userData);
            return newUser;
        } catch (error) {
            throw new Error(error.message)
        }
    }

    static async addHistory(idColector, idTrash, nameTrash, action, actionTIme) {
        const formatedData = {
            action: action,
            time_action: actionTIme,
            trash_id: new mongoose.Types.ObjectId(idTrash),
            trash_name: nameTrash
        }

        const updatedColector = await userModel.findByIdAndUpdate(idColector, {$push: {history: formatedData}, $inc: {coletas_realizadas: 1}})
    }
}

export default UserService;