import express from "express";
import {
  getUserByUsername,
  Register,
  updateUser,
  deleteUser,
  loginhandler,
  initialEnpoint,
  logout,
} from "../controller/userController.js";

import {
  getCars,
  updateCar,
  createCar,
  deleteCar,
  getCarById,
} from "../controller/dataMobilController.js";

import {
  getRentals,
  updateRental,
  createRental,
  deleteRental,
  getRentalById,
} from "../controller/dataOrderController.js";
import { verifyToken } from "../middleware/VerifyToken.js";
import { refreshToken } from "../controller/refreshToken.js";

const router = express.Router();

router.get("/", initialEnpoint);

//endpoint akses token
router.get("/token", refreshToken);

//endpoint table user
router.post("/login", loginhandler);
router.post("/register", Register);
router.get("/profile/:username", getUserByUsername);
router.put("/profile/update/:username", updateUser);
router.delete("/profile/delete/:username", deleteUser);
router.delete("/logout",verifyToken, logout);

//endpoint tabel cars
router.get("/cars", getCars);
router.post("/cars/create", createCar);
router.get("/cars/detail/:car_id", getCarById);
router.put("/cars/update/:car_id", updateCar);
router.delete("/cars/delete/:car_id", deleteCar);

//endpoint tabel rentals
router.get("/rentals", getRentals);
router.post("/rentals/create", createRental);
router.get("/rentals/detail/:rental_id", getRentalById);
router.put("/rentals/update/:rental_id", updateRental);
router.delete("/rentals/delete/:rental_id", deleteRental);

export default router;
