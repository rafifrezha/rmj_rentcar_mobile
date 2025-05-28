import { Sequelize } from "sequelize";
import db from "../config/database.js";

const User = db.define(
  "users", // Ganti dari "user" ke "users" agar sesuai dengan nama tabel di database
  {
    user_id: {
      type: Sequelize.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    username: {
      type: Sequelize.STRING,
      unique: true,
    },
    password: Sequelize.STRING,
    email: Sequelize.STRING,
    role: {
      type: Sequelize.ENUM("admin", "user"),
      defaultValue: "user",
    },
    created_at: {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW,
    },
    updated_at: {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW,
    },
    refreshToken: Sequelize.TEXT,
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

export default User;

(async () => {
  await db.sync();
})();
