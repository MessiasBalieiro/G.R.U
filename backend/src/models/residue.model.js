import mongoose from 'mongoose';

const residueSchema = new mongoose.Schema({
    id_usuario: {
        type: mongoose.Types.ObjectId,
        required: true,
        set: value => new mongoose.Types.ObjectId(value)
    },
    id_lixeira: {
        type: mongoose.Types.ObjectId,
        required: true,
        set: value => new mongoose.Types.ObjectId(value)
    },
    tipo_residuo: {
        type: String,
        required: true,
        enum: ["Plástico", "Vidro", "Metal", "Papel"]
    },
    data_residuo: {
        type: String,
        match: /^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}$/,
        required: true
    },
    dia_semana_residuo: {
        type: String,
        trim: true,
        required: true,
        enum: ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado", "Domingo"]
    },
    horario_residuo: {
        type: String,
        match: /^([01][0-9]|2[0-3]):([0-5][0-9])$/,
        required: true
    }
})

const residueModel = mongoose.model("Residuos", residueSchema);

export default residueModel;


// {
//   "id_usuario": "6af799e0b0cb2244311a30ec",
//   "id_lixeira": "6af7b720ed6c6d5087fe044a",
//   "tipo_residuo": "Plástico",
//   "data_residuo": "14/11/2026",
//   "dia_semana_residuo": "Sábado",
//   "horario_residuo": "05:40",
//   "quantidade": 10
// }