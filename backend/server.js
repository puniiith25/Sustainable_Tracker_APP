// server.js
// --- IMPORTANT: load env BEFORE other imports ---
import 'dotenv/config'; // <-- loads .env automatically

// defensive startup checks
if (!process.env.MONGO_URI) {
    console.error('FATAL: MONGO_URI is not set in .env (or env).');
    process.exit(1);
}
if (!process.env.JWT_SECRET) {
    console.error('FATAL: JWT_SECRET is not set in .env (or env).');
    process.exit(1);
}

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import cookieParser from 'cookie-parser';

import connectDB from './DataBase/DataBase.js';
import router from './Routers/userRouter.js';
import requireAuth from './MiddleWare/authMeddleware.js';

const app = express();
const PORT = process.env.PORT || 4000;

// Connect to DB
connectDB();

// Middlewares
app.use(helmet());
app.use(express.json());
app.use(cookieParser());
app.use(
    cors({
        origin: process.env.CLIENT_ORIGIN || true,
        credentials: true,
    })
);

// Routes
app.use('/api/auth', router);

// Protected 
app.get('/api/me', requireAuth, (req, res) => {
    res.json({ user: req.user.toJSON() });
});

// global error handler (helpful for debugging and returns stack in development)
app.use((err, req, res, next) => {
    console.error('GLOBAL ERROR:', err && err.stack ? err.stack : err);
    res.status(err.status || 500).json({
        message: err.message || 'Internal Server Error',
        ...(process.env.NODE_ENV !== 'production' ? { stack: err.stack } : {}),
    });
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
