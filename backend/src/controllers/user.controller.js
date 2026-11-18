import userService from "../Services/user.service.js";

class UserController {
    static async getAllUsers(req, res) {
        try {
            res.status(200).json(await userService.getAllUsers());
        }
        catch (error) {
            console.error(error);
            res.status(500).send('Erro ao buscar usuários');
        }
    }

    static async getThisUser(req, res) {
        try {
            res.status(200).json(await userService.getThisUser(req.body.cpf_usuario, req.body.cargo_usuario));
        } catch (error) {
            console.error(error);
            res.status(500).send('Erro ao buscar usuário');
        }
    }

    static async getThisColectos(req, res) {
        try {
            res.status(200).json(await userService.getThisColectos(req.body.ids));
        } catch (error) {
            console.error(error);
            res.status(500).send('Erro ao buscar coletors');
        }
    }

    static async login(req, res) {
        try {
            res.status(200).json(await userService.login(req.body.email_usuario, req.body.senha_usuario));
            console.log("Login realizado com sucesso!!");
        } catch (error) {
            console.error(error);
            res.status(500).send('Erro ao realizar login');
        }
    }

    static async createUser(req, res) {
        try {
            res.status(201).json(await userService.createUser(req.body));
            console.log("Usuário criado!!");
        } catch (error) {
            console.error(error);
            res.status(500).send('Erro ao criar usuário');
        }
    }
}

export default UserController;