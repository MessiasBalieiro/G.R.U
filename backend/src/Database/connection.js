import mongoose from "mongoose";

const connection = async() => {
    try {
        await mongoose.connect(String(process.env.DB_CONNECTION));
        console.log("Conexão com o DB realizada com sucesso!");
    }
    catch (error) {
        console.error("Erro ao conectar o DB: ", error);
    }
}

export default connection;