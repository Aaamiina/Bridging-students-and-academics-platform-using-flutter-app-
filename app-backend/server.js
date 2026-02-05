require('dotenv').config();
const express = require('express');
const connectDB = require('./src/config/db');
const cors = require('cors');
const adminUserRoutes = require('./src/routes/adminRoutes/userRoute');


const app = express();
connectDB();

app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Logger Middleware
app.use((req, res, next) => {
    console.log(`${req.method} request to ${req.originalUrl}`);
    next();
});

// Routes
app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/supervisor', require('./src/routes/supervisorRoutes'));
app.use('/api/student', require('./src/routes/studentRoutes'));

// admin
// admin
app.use('/api/admin/users', adminUserRoutes);
app.use('/api/admin/groups', require('./src/routes/adminRoutes/groupRoute'));
app.use('/api/admin/stats', require('./src/routes/adminRoutes/statsRoute'));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));