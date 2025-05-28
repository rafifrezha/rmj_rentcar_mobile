import User from "../models/userModel.js";
import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";

//Initial endpoint
export const initialEnpoint = async (req, res) => {
  res.status(200).json({
    status: "success",
    message: "Connected to Data-book Backend!!",
  });
};

//Get User Data by username
export const getUserByUsername = async (req, res) => {
  try {
    const response = await User.findOne({
      where: {
        username: req.params.username,
      },
    });
    res.status(200).json(response);
  } catch (error) {
    console.log(error.message);
  }
};

//Buat tambah data user
export const Register = async (req, res) => {
  try {
    const { username, password, email } = req.body;
    const salt = await bcrypt.genSalt(10);
    const hashPassword = await bcrypt.hash(password, salt);
    await User.create({
      password: hashPassword,
      username: username,
      email: email,
    });
    res.status(201).json({ msg: "Register Berhasil" });
  } catch (error) {
    console.log(error.message);
  }
};

//Login Handler
export const loginhandler = async (req, res) => {
  try {
    const { username, password } = req.body;
    const user = await User.findOne({
      where: {
        username: username,
      },
    });

    if (user) {
      const match = await bcrypt.compare(password, user.password);
      if (match) {
        const userPayload = {
          username: user.username
        };
        const accessToken = jwt.sign(
          userPayload,
          process.env.ACCESS_TOKEN_SECRET,
          {
            expiresIn: "10s",
          }
        );
        const refreshToken = jwt.sign(userPayload, process.env.REFRESH_TOKEN_SECRET, {
          expiresIn: "1d",
        });
        await User.update(
          { refreshToken: refreshToken },
          {
            where: {
              username: user.username,
            },
          }
        );
        res.cookie("refreshToken", refreshToken, {
          httpOnly: true,
          maxAge: 24 * 60 * 60 * 1000,
          secure: true,
        });
        res.status(200).json({
          status: "Succes",
          message: "Login Berhasil",
          user,
          accessToken,
        });
      } else {
        res.status(400).json({
          status: "Failed",
          message: "Password atau email salah",
        });
      }
    } else {
      res.status(400).json({
        status: "Failed",
        message: "Password atau email salah",
      });
    }
  } catch (error) {
    res.status(error.statusCode || 500).json({
      status: "error",
      message: error.message,
    });
  }
};

export const logout = async (req, res) => {
  const refreshToken = req.cookies.refreshToken;
  if (!refreshToken) return res.sendStatus(204);
  const user = await User.findOne({
    where: {
      refreshToken: refreshToken,
    },
  });
  if (!user.refreshToken) return res.sendStatus(204);
  const username = user.username;
  await User.update(
    { refreshToken: null },
    {
      where: {
        username: username,
      },
    }
  );
  res.clearCookie("refreshToken");
  return res.sendStatus(200);
};

//Update user
export const updateUser = async (req, res) => {
  try {
    const { password, username } = req.body;
    let updatedData = {
      username: username,
    };

    if (password) {
      // Tidak perlu encrypt password
      updatedData.password = password;
    }

    const result = await User.update(updatedData, {
      where: {
        username: req.params.username,
      },
    });

    // Periksa apakah ada baris yang terpengaruh (diupdate)
    if (result[0] === 0) {
      return res.status(404).json({
        status: "failed",
        message: "User not found or no changes applied",
        updatedData: updatedData,
        result,
      });
    }

    res.status(200).json({ msg: "User Updated" });
  } catch (error) {
    console.log(error.message);
  }
};

//Delete user
export const deleteUser = async (req, res) => {
  try {
    await User.destroy({
      where: {
        username: req.params.username,
      },
    });
    res.status(200).json({ msg: "User Deleted" });
  } catch (error) {
    console.log(error.message);
  }
};
