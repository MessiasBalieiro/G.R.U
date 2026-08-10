import userService from '../services/user.service.js'

export default class UserController {
    static async getAllUsers(req, res) {
        res.status(200).json(await userService.getAllUsers());
    }
}