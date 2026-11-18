import mongoose from "mongoose";

const summonSchema = new mongoose.Schema({
    senderId: {
        type: mongoose.Types.ObjectId,
        require: true,
        set: v => new mongoose.Types.ObjectId(v)
    },
    description: {
        type: String,
        require: true,
        trim: true
    },
    destination: {
        type: String,
        require: true
    },
    creationDate: {
        type: Date,
        default: Date.now,
        get: v => v.toLocaleString('pt-BR', {
            day: "2-digit",
            monthy: "2-digit",
            year: "numeric",
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit"
        })
    },
    finished: {
        type: Boolean,
        default: false
    }
})

const summonModel = mongoose.model("Chamados", summonSchema)

export default summonModel