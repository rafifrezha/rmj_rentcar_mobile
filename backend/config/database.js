import { Sequelize } from "sequelize";
import dotenv from "dotenv";
dotenv.config();

const db = new Sequelize("rmjrentcar", process.env.DB_USERNAME, process.env.DB_PASSWORD, {
  dialect: "mysql",
  dialectOptions: {
    socketPath: `${process.env.DB_SOCKET_PATH}/${process.env.INSTANCE_CONNECTION_NAME}`,
  },
  logging: false, // opsional: matikan log SQL
});

export default db;