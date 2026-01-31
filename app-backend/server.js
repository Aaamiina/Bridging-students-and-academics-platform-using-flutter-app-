require('dotenv').config();
const express = require('express');
const connectDB = require('./src/config/db');
const cors = require('cors');
const adminUserRoutes = require('./src/routes/adminRoutes/userRoute');


const app = express();
connectDB();

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./src/routes/authRoutes'));
app.use('/api/supervisor', require('./src/routes/supervisorRoutes'));
app.use('/api/student', require('./src/routes/studentRoutes'));

// admin
app.use('/api/admin/users', adminUserRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));