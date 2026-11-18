import mongoose from 'mongoose';

const organizationSchema = new mongoose.Schema({
    id_contratante: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Usuarios",
        required: true
    },
    trashes: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "Lixeiras",
        default: []
    },
    colectors: {
        type: [mongoose.Schema.Types.ObjectId],
        ref: "Usuarios",
        default: []
    },
    organization_name: {
        type: String,
        required: true
    },
    history: {
        type: [
            {
                type_object: {
                    type: String,
                    enum: ['Lixeiras', 'Usuarios'],
                    required: true
                },
                id_object: {
                    type: mongoose.Schema.Types.ObjectId,
                    refPath: 'history.type_object',
                    required: true
                },
                action_object: {
                    type: String,
                    required: true
                },
                time_action_object: {
                    type: String,
                    required: true
                },
                user_action_object: {
                    type: mongoose.Schema.Types.ObjectId,
                    ref: "Usuarios",
                    default: null
                },
                username_action_object: {
                    type: String,
                    default: ''
                }
            }
        ],
        default: [],
    }
})

const organizationModel = mongoose.model('Organizacao', organizationSchema);

export default organizationModel;
