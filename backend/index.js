import express from "express";
import cors from "cors";
import UserRoute from "./routes/UserRoute.js";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";

dotenv.config();

const app = express();
app.use(cookieParser());
app.use(cors());
app.use(express.json());
app.use(UserRoute);

const port = process.env.PORT || 5000;

app.listen(port, () => {
  console.log(`Server up and running on port ${port}`);
});
