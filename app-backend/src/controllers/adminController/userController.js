const User = require('../../models/User');

// Create New User

exports.createUser = async (req, res) => {
  try {
    const { name, email, password, role, group, phone } = req.body;

    // 1. Check if user already exists
    let user = await User.findOne({ email });
    if (user) return res.status(400).json({ msg: 'User already exists' });

    // 2. Handle the Image File
    // If multer worked, the file path will be in req.file.path
    let profileImage = "";
    if (req.file) {
      // We replace backslashes with forward slashes for URL compatibility
      profileImage = req.file.path.replace(/\\/g, "/"); 
    }

    // 3. Create the user
    user = new User({ 
      name, 
      email, 
      password, 
      role, 
      group, 
      phone, 
      profileImage // Save the path to the DB
    });

    await user.save();

    res.status(201).json({ 
      msg: 'User created successfully', 
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        profileImage: user.profileImage
      } 
    });
  } catch (err) {
    console.error("Error in createUser:", err);
    res.status(500).send('Server Error');
  }
};

// Get All Users
exports.getUsers = async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.json(users);
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// Update User Details
exports.updateUser = async (req, res) => {
  try {
    const { name, email, role, phone, group, status, password, profileImage } = req.body;

    let user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ msg: 'User not found' });

    // Update fields if provided
    user.name = name || user.name;
    user.email = email || user.email;
    user.role = role || user.role;
    user.phone = phone || user.phone;
    user.group = group || user.group;
    user.profileImage = profileImage || user.profileImage;
    user.status = status !== undefined ? status : user.status;

    if (password) user.password = password; // Triggers pre-save hashing

    await user.save();
    res.json({ msg: 'User updated successfully', user });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// Toggle User Status (Active/Disabled)
exports.toggleUserStatus = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ msg: 'User not found' });

    user.status = !user.status;
    await user.save();
    res.json({ msg: `User ${user.status ? 'activated' : 'deactivated'}`, status: user.status });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};

// Delete User
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ msg: 'User not found' });

    await user.deleteOne();
    res.json({ msg: 'User removed successfully' });
  } catch (err) {
    res.status(500).send('Server Error');
  }
};