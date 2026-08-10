import mongoose from 'mongoose';

const trashSchema = new mongoose.Schema({
    codigo_dono_lixeira: {
        type: mongoose.Types.ObjectId,
        required: true
    },
    endereco_lixeira: {
        type: {String, String},
        required: true
    },
    coordenada: {
        type: {String, String},
        required: true
    },
    status_lixeira: {
        type: Number,
        required: true,
        enum: [0, 1, 2, 3, 4]
    }
})

const trashModel = mongoose.model('Lixeiras', trashSchema);

export default trashModel;