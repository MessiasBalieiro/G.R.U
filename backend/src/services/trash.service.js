import trashModel from "../models/trash.model.js";

export default class TrashService {
    static async getAllTrashes() {
        try {
            const allTrashes = await trashModel.find({});
            return allTrashes;
        }
        catch (error) {
            console.error("Error: ", error);
            return "Something didn't happen as expected. Please, try again later."
        }
    }
}