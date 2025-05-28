import { Sequelize } from "sequelize";
import db from "../config/database.js";
import User from "./userModel.js";
import Car from "./carModel.js";

const Rental = db.define(
  "rentals",
  {
    rental_id: {
      type: Sequelize.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    user_id: {
      type: Sequelize.INTEGER,
      allowNull: false,
      references: {
        model: User,
        key: "user_id",
      },
      onDelete: "CASCADE",
      onUpdate: "CASCADE",
    },
    car_id: {
      type: Sequelize.INTEGER,
      allowNull: false,
      references: {
        model: Car,
        key: "car_id",
      },
      onDelete: "CASCADE",
      onUpdate: "CASCADE",
    },
    rental_start_date: Sequelize.DATEONLY,
    rental_end_date: Sequelize.DATEONLY,
    total_price: Sequelize.INTEGER,
    status: {
      type: Sequelize.ENUM("reserved", "ongoing", "completed"),
      defaultValue: "reserved",
    },
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

// Relasi: User 1 - N Rental
User.hasMany(Rental, { foreignKey: "user_id", onDelete: "CASCADE" });
Rental.belongsTo(User, { foreignKey: "user_id" });

// Relasi: Car 1 - N Rental
Car.hasMany(Rental, { foreignKey: "car_id", onDelete: "CASCADE" });
Rental.belongsTo(Car, { foreignKey: "car_id" });

export default Rental;

(async () => {
  await db.sync();
})();
