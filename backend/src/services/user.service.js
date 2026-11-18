import mongoose from 'mongoose';
import userModel from '../Models/user.model.js';
import OrganizationService from './organization.service.js';
import { createRemoteJWKSet, jwtVerify } from 'jose';

// Chaves públicas que o Firebase usa para assinar os tokens de login.
const FIREBASE_JWKS = createRemoteJWKSet(
    new URL('https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com')
);

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

    // Login social (Google / Microsoft / Apple via Firebase).
    // Valida o token enviado pelo site e devolve o usuário com esse e-mail
    // (ou null se ainda não existe cadastro).
    static async socialLogin(idToken) {
        const projectId = process.env.FIREBASE_PROJECT_ID;
        if (!projectId) {
            throw new Error('FIREBASE_PROJECT_ID não configurado no servidor');
        }
        if (typeof idToken !== 'string' || idToken.length === 0) {
            const err = new Error('Token ausente');
            err.status = 401;
            throw err;
        }

        const { payload } = await jwtVerify(idToken, FIREBASE_JWKS, {
            issuer: `https://securetoken.google.com/${projectId}`,
            audience: projectId,
        });

        if (!payload.email || payload.email_verified !== true) {
            const err = new Error('E-mail da conta social não verificado');
            err.status = 401;
            throw err;
        }

        const emailSeguro = String(payload.email).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        return await userModel.findOne({ email_usuario: new RegExp(`^${emailSeguro}$`, 'i') });
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