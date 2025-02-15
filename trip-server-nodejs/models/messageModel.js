const pool = require('../config/db');

class Message {
  static async sendMessage(group_id, user_id, message) {
    const query = 'INSERT INTO messages (group_id, user_id, message) VALUES (?, ?, ?)';
    try {
      const [result] = await pool.query(query, [group_id, user_id, message]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error sending message:', err);
      return false;
    }
  }

  static async getMessagesByGroup(group_id) {
    const query = `
      SELECT m.id, m.user_id, u.username, m.message, m.created_at
      FROM messages m
      LEFT JOIN users u ON m.user_id = u.id
      WHERE m.group_id = ?
      ORDER BY m.created_at ASC
    `;
    try {
      const [rows] = await pool.query(query, [group_id]);
      return rows;
    } catch (err) {
      console.error('Error fetching messages:', err);
      return [];
    }
  }
}

module.exports = Message;