import userModel from '../models/user.model.js';

export default class UserService {
    static async getAllUsers() {
        try {
            const allUsers = await userModel.find({});
            return allUsers;
        }
        catch (error) {
            console.error("Error: ", error);
            return "Something didn't happen as expected. Please, try again later."
        }
    }
}