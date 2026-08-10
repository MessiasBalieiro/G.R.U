import mongoose from "mongoose";

const residueSchema = new mongoose.Schema({
    id_lixeira: {
        type: mongoose.Types.ObjectId,
        required: true
    },
    tipo_residuo: {
        type: String,
        required: true,
        enum: ["Plástico", "Vidro", "Metal", "Papel"]
    },
    data_residuo: {
        type: String,
        match: "/^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}$/",
        required: true
    },
    dia_semana_residuo: {
        type: String,
        trim: true,
        required: true
    },
    horario_residuo: {
        type: String,
        match: "/^([01][0-9]|2[0-3]):([0-5][0-9])$/",
        required: true
    }
})

const residueModel = mongoose.model("Residuos", residueSchema)

export default residueModel