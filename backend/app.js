const express = require('express');
const app = express();
const carsController = require('./controllers/carsController');
const rentalsController = require('./controllers/rentalsController');
const usersController = require('./controllers/usersController');
const verifyToken = require('./middleware/verifyToken');

app.use(express.json());

// Contoh penggunaan verifyToken pada beberapa route:
app.get('/cars', verifyToken, carsController.getAllCars);
app.get('/cars/detail/:id', verifyToken, carsController.getCarDetail);
app.post('/cars/create', verifyToken, carsController.createCar);
app.put('/cars/update/:id', verifyToken, carsController.updateCar);
app.delete('/cars/delete/:id', verifyToken, carsController.deleteCar);

app.get('/rentals', verifyToken, rentalsController.getAllRentals);
app.post('/rentals/create', verifyToken, rentalsController.createRental);
app.put('/rentals/update/:id', verifyToken, rentalsController.updateRental);
app.delete('/rentals/delete/:id', verifyToken, rentalsController.deleteRental);

app.get('/users', verifyToken, usersController.getAllUsers);

module.exports = app;