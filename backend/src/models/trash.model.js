import mongoose from 'mongoose';

const trashSchema = new mongoose.Schema({
    nome_lixeira: {
        type: String,
        required: true
    },
    codigo_dono_lixeira: {
        type: mongoose.Types.ObjectId,
        required: true,
        set: value => new mongoose.Types.ObjectId(value)
    },
    endereco_lixeira: {
        type: String,
        required: true
    },
    coordenada: {
        type: String,
        required: true
    },
    quantidade_residuo: {
        type: Number,
        required: true,
        default: 0,
    },
    composicao: {
        quantPlastico: {
            type: Number,
            default: 0
        },
        quantVidro: {
            type: Number,
            default: 0
        },
        quantMetal: {
            type: Number,
            default: 0
        },
        quantPapel: {
            type: Number,
            default: 0
        }
    },
    status_lixeira: {
        type: Number,
        required: true,
        enum: [0, 1, 2, 3, 4],
        default: 0,
        set: value => parseInt(value)
    }
})

const trashModel = mongoose.model("Lixeiras", trashSchema);

export default trashModel;