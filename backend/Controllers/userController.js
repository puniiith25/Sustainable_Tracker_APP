import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { validationResult } from "express-validator";
import { cookieOptions } from "../utils/cookieOptions.js";
import User from "../Models/UserModel.js";

const JWT_SECRET = process.env.JWT_SECRET;
const COOKIE_NAME = process.env.COOKIE_NAME;

// Helper to ensure JWT_SECRET exists (optional but helpful)
function ensureSecret() {
    if (!JWT_SECRET) {
        console.error("Missing JWT_SECRET environment variable");
        throw new Error("Server misconfiguration");
    }
}

// SIGNUP
export const signup = async (req, res) => {
    try {
        ensureSecret();

        const errors = validationResult(req);
        if (!errors.isEmpty())
            return res.status(422).json({ errors: errors.array() });

        const { name, email, password } = req.body;

        const exists = await User.findOne({ email });
        if (exists)
            return res.status(409).json({ message: "Email already exists" });

        const hashed = await bcrypt.hash(password, 10);

        const user = await User.create({ name, email, password: hashed });

        const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: "7d" });

        // Set cookie for web clients (HTTP-only)
        res.cookie(COOKIE_NAME, token, cookieOptions());

        // ALSO return token in JSON so native/mobile clients can use it
        return res.status(201).json({
            user: user.toJSON(),
            token,
            message: "Account created",
        });
    } catch (err) {
        console.error("Signup error:", err);
        return res.status(500).json({ message: "Internal server error" });
    }
};

// LOGIN
export const login = async (req, res) => {
    try {
        ensureSecret();

        const errors = validationResult(req);
        if (!errors.isEmpty())
            return res.status(422).json({ errors: errors.array() });

        const { email, password } = req.body;

        const user = await User.findOne({ email });
        if (!user)
            return res.status(401).json({ message: "Invalid email" });

        const match = await bcrypt.compare(password, user.password);
        if (!match)
            return res.status(401).json({ message: "Wrong password" });

        const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: "7d" });

        // Set cookie for web clients (HTTP-only)
        res.cookie(COOKIE_NAME, token, cookieOptions());

        // ALSO return token in JSON for mobile/native clients
        return res.status(200).json({
            user: user.toJSON(),
            token,
            message: "Logged in",
        });
    } catch (err) {
        console.error("Login error:", err);
        return res.status(500).json({ message: "Internal server error" });
    }
};

// LOGOUT
export const logout = (req, res) => {
    try {
        res.clearCookie(COOKIE_NAME, cookieOptions(true));
        return res.json({ message: "Logged out" });
    } catch (err) {
        console.error("Logout error:", err);
        return res.status(500).json({ message: "Internal server error" });
    }
};

// controllers/userController.js (append to existing exports)
export const getMe = async (req, res) => {
    try {
        // requireAuth middleware should attach user document to req.user
        if (!req.user) return res.status(401).json({ message: 'Unauthorized' });

        // Send user data (avoid sending sensitive fields like password)
        return res.status(200).json({ user: req.user.toJSON() });
    } catch (err) {
        console.error('GetMe error:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
};
