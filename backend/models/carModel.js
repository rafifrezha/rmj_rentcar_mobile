import { Sequelize } from "sequelize";
import db from "../config/database.js";

const Car = db.define(
  "cars",
  {
    car_id: {
      type: Sequelize.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    brand: Sequelize.STRING, // ubah dari make ke brand
    model: Sequelize.STRING,
    year: Sequelize.INTEGER,
    license_plate: {
      type: Sequelize.STRING,
      unique: true,
    },
    availability: {
      type: Sequelize.BOOLEAN,
      defaultValue: true,
    },
    price_per_day: Sequelize.INTEGER,
    url_photo: Sequelize.STRING, // tambahkan field ini
    created_at: {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW,
    },
    updated_at: {
      type: Sequelize.DATE,
      defaultValue: Sequelize.NOW,
    },
  },
  {
    freezeTableName: true,
    timestamps: false,
  }
);

export default Car;

(async () => {
  await db.sync();
})();
