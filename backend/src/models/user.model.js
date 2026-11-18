import mongoose from 'mongoose';

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
    },
    instituicao_usuario: {
        type: String,
        default: ""
    },
    coletas_realizadas: {
        type: Number,
        default: 0
    },
    history: {
        type: [
            {
                action: {
                    type: String,
                    required: true
                },
                time_action: {
                    type: String,
                    required: true
                },
                trash_id: {
                    type: mongoose.Types.ObjectId,
                    required: true
                },
                trash_name: {
                    type: String,
                    required: true
                }
            }
        ]
    },
    instituicoes: {
        type: [mongoose.Types.ObjectId],
        default: []
    },
    cargo_usuario: {
        type: String,
        required: true,
        enum: ['ADMINISTRADOR', 'CONTRATANTE', 'COLETOR'],
        set: v => v.toUpperCase()
    }
})

const userModel = mongoose.model("Usuarios", userSchema);

export default userModel;


// {
//   "trashId": "6af7b720ed6c6d5087fe044a",
//   "residuos": -1,
//   "idColector": "6af276d8be5c4bfa0b7c9a1b",
//   "nameColector": "Bruno",
//   "organizationId": "6af799e1b0cb2244311a30ed"
// }