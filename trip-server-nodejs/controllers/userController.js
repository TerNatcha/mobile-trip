
const User = require('../models/userModel');

exports.register = async (req, res) => {
  const { username, email, password } = req.body;
  if (!username || !email || !password) {
    return res.status(400).json({ status: 'error', message: 'Missing required fields' });
  }
  const user_id = await User.register(username, email, password);
  if (user_id) {
    res.json({ message: 'User registered successfully.', user_id });
  } else {
    res.status(500).json({ message: 'User registration failed.' });
  }
};

exports.login = async (req, res) => {
  const { username, password } = req.body;
  const user = await User.login(username, password);
  if (user) {
    res.json({ message: 'Login successful.', user_id: user.id });
  } else {
    res.status(401).json({ message: 'Login failed.' });
  }
};

exports.updateUser = async (req, res) => {
  const { user_id, username, email } = req.body;
  const success = await User.updateUser(user_id, username, email);
  if (success) {
    res.json({ message: 'Profile updated successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to update profile.' });
  }
};

exports.updateProfileImage = async (req, res) => {
  const { user_id } = req.body;
  const imagePath = req.file.path;
  const success = await User.updateProfileImage(user_id, imagePath);
  if (success) {
    res.json({ message: 'Profile image updated successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to update profile image.' });
  }
};

exports.updateProfileInfo = async (req, res) => {
  const { user_id, first_name, last_name, phone, address } = req.body;
  const success = await User.updateProfileInfo(user_id, first_name, last_name, phone, address);
  if (success) {
    res.json({ message: 'Profile updated successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to update profile.' });
  }
};