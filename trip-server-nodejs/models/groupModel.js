const pool = require('../config/db');

class Group {
  static async createGroup(owner_id, name, description) {
    const query = 'INSERT INTO groups (owner_id, name, description) VALUES (?, ?, ?)';
    try {
      const [result] = await pool.query(query, [owner_id, name, description]);
      const group_id = result.insertId;
      await Group.inviteUserToGroup(group_id, owner_id);
      return true;
    } catch (err) {
      console.error('Error creating group:', err);
      return false;
    }
  }

  static async inviteUserToGroup(group_id, user_id) {
    const query = 'INSERT INTO group_members (group_id, user_id) VALUES (?, ?)';
    try {
      await pool.query(query, [group_id, user_id]);
      return true;
    } catch (err) {
      console.error('Error inviting user to group:', err);
      return false;
    }
  }

  static async removeUserFromGroup(group_id, user_id) {
    const query = 'DELETE FROM group_members WHERE group_id = ? AND user_id = ?';
    try {
      const [result] = await pool.query(query, [group_id, user_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error removing user from group:', err);
      return false;
    }
  }

  static async getGroups(user_id) {
    const query = `
      SELECT DISTINCT g.*
      FROM groups g
      INNER JOIN group_members gm ON gm.group_id = g.id
      WHERE g.owner_id = ? OR gm.user_id = ?
    `;
    try {
      const [rows] = await pool.query(query, [user_id, user_id]);
      return rows;
    } catch (err) {
      console.error('Error fetching groups:', err);
      return [];
    }
  }

  static async searchUsers(query) {
    const sqlQuery = `SELECT id, username, email FROM users WHERE username LIKE ?`;
    try {
      const [rows] = await pool.query(sqlQuery, [`%${query}%`]);
      return rows;
    } catch (err) {
      console.error('Error searching users:', err);
      return [];
    }
  }
}

module.exports = Group;