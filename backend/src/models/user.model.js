import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    nome_usuario: {
        type: String,
        required: true,
    },
    email_usuario: {
        type: String,
        required: true,
        match: /^\S+@\S+\.\S+$/
    },
    telefone_usuario: {
        type: String,
        required: true,
        match: /^\(\d{2}\) \d{4,5}-\d{4}$/
    },
    cpf_usuario: {
        type: String,
        required: true,
        unique: true,
        match: /^\d{3}\.\d{3}\.\d{3}-\d{2}$/
    },
    senha_usuario: {
        type: String,
        required: true,
    }
})

const userModel = mongoose.model("Usuarios", userSchema)

export default userModel