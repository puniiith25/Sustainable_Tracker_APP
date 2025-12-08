export const cookieOptions = (clear = false) => ({
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: process.env.NODE_ENV === "production" ? "none" : "lax",
    maxAge: clear ? 0 : 1000 * 60 * 60 * 24 * 7,
});
