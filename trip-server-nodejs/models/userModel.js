const bcrypt = require('bcrypt');
const pool = require('../config/db');

class User {
  static async register(username, email, password) {
    const hashedPassword = await bcrypt.hash(password, 10);
    const query = 'INSERT INTO users (username, email, password) VALUES (?, ?, ?)';
    try {
      const [result] = await pool.query(query, [username, email, hashedPassword]);
      return result.insertId;
    } catch (err) {
      console.error('Error registering user:', err);
      return false;
    }
  }

  static async login(username, password) {
    const query = 'SELECT id, username, password FROM users WHERE username = ?';
    const [rows] = await pool.query(query, [username]);
    if (rows.length && await bcrypt.compare(password, rows[0].password)) {
      return rows[0];
    }
    return null;
  }

  static async updateUser(user_id, username, email) {
    const query = 'UPDATE users SET username = ?, email = ? WHERE id = ?';
    try {
      const [result] = await pool.query(query, [username, email, user_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error updating user:', err);
      return false;
    }
  }

  static async updateProfileImage(user_id, image_path) {
    const query = 'UPDATE user_profiles SET profile_picture = ? WHERE user_id = ?';
    try {
      const [result] = await pool.query(query, [image_path, user_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error updating profile image:', err);
      return false;
    }
  }

  static async updateProfileInfo(user_id, first_name, last_name, phone, address) {
    const query = 'UPDATE user_profiles SET first_name = ?, last_name = ?, phone = ?, address = ? WHERE user_id = ?';
    try {
      const [result] = await pool.query(query, [first_name, last_name, phone, address, user_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error updating profile info:', err);
      return false;
    }
  }
}

module.exports = User;