// MiddleWare/authMeddleware.js
import jwt from "jsonwebtoken";
import User from "../Models/UserModel.js";

const JWT_SECRET = process.env.JWT_SECRET;
const COOKIE_NAME = process.env.COOKIE_NAME || "token";

export default async function requireAuth(req, res, next) {
    try {
        let token = null;

        // 1) Check Authorization header: "Bearer <token>"
        const authHeader = req.headers.authorization || req.headers.Authorization;
        if (authHeader && typeof authHeader === "string" && authHeader.startsWith("Bearer ")) {
            token = authHeader.split(" ")[1];
        }

        // 2) Fallback: check cookie (for web/browser clients)
        if (!token && req.cookies && req.cookies[COOKIE_NAME]) {
            token = req.cookies[COOKIE_NAME];
        }

        if (!token) {
            return res.status(401).json({ message: "Authentication token missing" });
        }

        if (!JWT_SECRET) {
            console.error("Missing JWT_SECRET in env");
            return res.status(500).json({ message: "Server misconfiguration" });
        }

        // verify token
        const payload = jwt.verify(token, JWT_SECRET);

        // payload should contain user id (as we signed { id: user._id })
        if (!payload || !payload.id) {
            return res.status(401).json({ message: "Invalid token payload" });
        }

        // fetch user from DB and attach to req
        const user = await User.findById(payload.id);
        if (!user) return res.status(401).json({ message: "User not found" });

        req.user = user;
        next();
    } catch (err) {
        console.error("requireAuth error:", err);
        // If token expired or invalid, send 401
        return res.status(401).json({ message: "Invalid or expired token" });
    }
}
