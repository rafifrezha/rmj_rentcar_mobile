import Car from "../models/carModel.js";

export const getCars = async (req, res) => {
  try {
    const response = await Car.findAll();
    res.status(200).json(response);
  } catch (error) {
    console.log(error.message);
  }
};

export const getCarById = async (req, res) => {
  try {
    const response = await Car.findAll({
      where: {
        car_id: req.params.car_id,
      }
    });
    res.status(200).json(response);
  } catch (error) {
    console.log(error.message);
  }
};

export const updateCar = async (req, res) => {
  try {
    await Car.update(req.body, {
      where: {
        car_id: req.params.car_id,
      },
    });
    res.status(200).json({ msg: "Car Updated" });
  } catch (error) {
    console.log(error.message);
  }
};

export const createCar = async (req, res) => {
  try {
    await Car.create(req.body);
    res.status(201).json({ msg: "Car created successfully" });
  } catch (error) {
    console.log(error.message);
  }
};

export const deleteCar = async (req, res) => {
  try {
    await Car.destroy({
      where: {
        car_id: req.params.car_id,
      },
    });
    res.status(200).json({ msg: "Car Deleted" });
  } catch (error) {
    console.log(error.message);
  }
};
