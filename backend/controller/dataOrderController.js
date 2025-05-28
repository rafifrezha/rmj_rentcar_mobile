import Rental from "../models/dataOrderModel.js";

// Get all rentals
export const getRentals = async (req, res) => {
  try {
    const response = await Rental.findAll();
    res.status(200).json(response);
  } catch (error) {
    console.log(error.message);
  }
};

export const getRentalById = async (req, res) => {
  try {
    const response = await Rental.findAll({
      where: {
        rental_id: req.params.rental_id,
      },
    });
    res.status(200).json(response);
  } catch (error) {
    console.log(error.message);
  }
};

// Update rental
export const updateRental = async (req, res) => {
  try {
    await Rental.update(req.body, {
      where: {
        rental_id: req.params.rental_id,
      },
    });
    res.status(200).json({ msg: "Rental Updated" });
  } catch (error) {
    console.log(error.message);
  }
};

// Create new rental
export const createRental = async (req, res) => {
  try {
    await Rental.create(req.body);
    res.status(201).json({ msg: "Rental created successfully" });
  } catch (error) {
    console.log(error.message);
  }
};

// Delete rental
export const deleteRental = async (req, res) => {
  try {
    await Rental.destroy({
      where: {
        rental_id: req.params.rental_id,
      },
    });
    res.status(200).json({ msg: "Rental Deleted" });
  } catch (error) {
    console.log(error.message);
  }
};
