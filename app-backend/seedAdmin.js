// seed.js
require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User'); 

const seedAdmin = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    
    // Remove any old incorrect admin entries first to start fresh
    await User.deleteMany({ email: 'admin@test.com' });

    const admin = new User({
      name: 'System Admin',
      email: 'asma@gmail.com',
      password: '1234', // This will be hashed automatically by your model
      role: 'Admin',
      status: true // Matches the 'status' check in your controller
    });

    await admin.save();
    console.log('✅ Admin created with status: true');
    process.exit();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
};

seedAdmin();