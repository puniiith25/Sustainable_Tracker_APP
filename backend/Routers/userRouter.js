import express from "express";
import { signup, login, logout, getMe } from "../Controllers/userController.js";
import { body } from "express-validator";
import requireAuth from "../MiddleWare/authMeddleware.js"; // ensure path correct

const router = express.Router();

// Signup route (existing)...
router.post(
    "/signup",
    [
        body("name").notEmpty().withMessage("Name required"),
        body("email").isEmail().withMessage("Valid email required"),
        body("password").isLength({ min: 6 }).withMessage("Min 6 characters"),
    ],
    signup
);

// Login route (existing)...
router.post(
    "/login",
    [
        body("email").isEmail().withMessage("Valid email required"),
        body("password").notEmpty().withMessage("Password required"),
    ],
    login
);

// Logout (existing)
router.post("/logout", logout);

// NEW: protected route to get current user
router.get("/me", requireAuth, getMe);

export default router;
