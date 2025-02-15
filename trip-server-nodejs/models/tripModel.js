const pool = require('../config/db');

class Trip {
  static async createTrip(user_id, name, destination, start_date, end_date, latitude, longitude) {
    const query = 'INSERT INTO trips (user_id, name, destination, start_date, end_date, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?)';
    try {
      const [result] = await pool.query(query, [user_id, name, destination, start_date, end_date, latitude, longitude]);
      const trip_id = result.insertId;
      await Trip.ownerToTrip(trip_id, user_id);
      return true;
    } catch (err) {
      console.error('Error creating trip:', err);
      return false;
    }
  }

  static async getLastInsertId() {
    try {
      const [result] = await pool.query('SELECT LAST_INSERT_ID()');
      return result[0]['LAST_INSERT_ID()'];
    } catch (err) {
      console.error('Error retrieving last insert ID:', err);
      return false;
    }
  }

  static async ownerToTrip(trip_id, user_id) {
    const query = 'INSERT INTO trip_participants (trip_id, user_id) VALUES (?, ?)';
    try {
      await pool.query(query, [trip_id, user_id]);
      return true;
    } catch (err) {
      console.error('Error inviting user to trip:', err);
      return false;
    }
  }

  static async getTrips(user_id) {
    const query = `
      SELECT DISTINCT t.*
      FROM trips t
      INNER JOIN trip_participants tp ON t.id = tp.trip_id
      WHERE tp.user_id = ?
    `;
    try {
      const [rows] = await pool.query(query, [user_id]);
      return rows;
    } catch (err) {
      console.error('Error fetching trips:', err);
      return [];
    }
  }

  static async getTrip(trip_id) {
    const query = 'SELECT * FROM trips WHERE id = ?';
    try {
      const [rows] = await pool.query(query, [trip_id]);
      return rows[0];
    } catch (err) {
      console.error('Error fetching trip:', err);
      return null;
    }
  }

  static async editTrip(trip_id, name, destination, start_date, end_date, latitude, longitude) {
    const query = 'UPDATE trips SET name = ?, destination = ?, start_date = ?, end_date = ?, latitude = ?, longitude = ? WHERE id = ?';
    try {
      const [result] = await pool.query(query, [name, destination, start_date, end_date, latitude, longitude, trip_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error updating trip:', err);
      return false;
    }
  }

  static async joinTrip(trip_id, user_id, start_date, end_date) {
    const checkQuery = 'SELECT COUNT(*) as count FROM trip_participants WHERE trip_id = ? AND user_id = ?';
    try {
      const [rows] = await pool.query(checkQuery, [trip_id, user_id]);
      if (rows[0].count > 0) {
        const updateQuery = 'UPDATE trip_participants SET start_date = ?, end_date = ? WHERE trip_id = ? AND user_id = ?';
        const [result] = await pool.query(updateQuery, [start_date, end_date, trip_id, user_id]);
        return result.affectedRows > 0;
      } else {
        const insertQuery = 'INSERT INTO trip_participants (trip_id, user_id, start_date, end_date) VALUES (?, ?, ?, ?)';
        const [result] = await pool.query(insertQuery, [trip_id, user_id, start_date, end_date]);
        return result.affectedRows > 0;
      }
    } catch (err) {
      console.error('Error joining trip:', err);
      return false;
    }
  }

  static async joinedTripUsers(trip_id) {
    const query = `
      SELECT u.username, tp.id, tp.user_id, tp.trip_id, tp.start_date, tp.end_date
      FROM trip_participants tp
      INNER JOIN users u ON tp.user_id = u.id
      INNER JOIN trips t ON tp.trip_id = t.id
      WHERE tp.trip_id = ?
    `;
    try {
      const [rows] = await pool.query(query, [trip_id]);
      return rows;
    } catch (err) {
      console.error('Error fetching joined trip users:', err);
      return [];
    }
  }

  static async unjoinTrip(trip_id, user_id) {
    const query = 'DELETE FROM trip_participants WHERE trip_id = ? AND user_id = ?';
    try {
      const [result] = await pool.query(query, [trip_id, user_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error unjoining trip:', err);
      return false;
    }
  }

  static async deleteTrip(trip_id) {
    const query = 'DELETE FROM trips WHERE id = ?';
    try {
      const [result] = await pool.query(query, [trip_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error deleting trip:', err);
      return false;
    }
  }

  static async closeTrip(trip_id) {
    const query = 'UPDATE trips SET status = "closed" WHERE id = ?';
    try {
      const [result] = await pool.query(query, [trip_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error closing trip:', err);
      return false;
    }
  }

  static async createEvent(trip_id, event_name, description, event_date) {
    const query = 'INSERT INTO trip_events (trip_id, event_name, description, event_date) VALUES (?, ?, ?, ?)';
    try {
      const [result] = await pool.query(query, [trip_id, event_name, description, event_date]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error creating event:', err);
      return false;
    }
  }

  static async updateEvent(event_id, event_name, description, event_date) {
    const query = 'UPDATE trip_events SET event_name = ?, description = ?, event_date = ? WHERE id = ?';
    try {
      const [result] = await pool.query(query, [event_name, description, event_date, event_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error updating event:', err);
      return false;
    }
  }

  static async deleteEvent(event_id) {
    const query = 'DELETE FROM trip_events WHERE id = ?';
    try {
      const [result] = await pool.query(query, [event_id]);
      return result.affectedRows > 0;
    } catch (err) {
      console.error('Error deleting event:', err);
      return false;
    }
  }

  static async updateOrAddExpense(trip_id, expense_id, amount, description) {
    if (expense_id) {
      const query = 'UPDATE trip_expenses SET amount = ?, description = ? WHERE id = ? AND trip_id = ?';
      try {
        const [result] = await pool.query(query, [amount, description, expense_id, trip_id]);
        return { status: true, message: 'Expense updated successfully' };
      } catch (err) {
        console.error('Error updating expense:', err);
        return { status: false, message: 'Failed to update expense' };
      }
    } else {
      const query = 'INSERT INTO trip_expenses (trip_id, amount, description) VALUES (?, ?, ?)';
      try {
        const [result] = await pool.query(query, [trip_id, amount, description]);
        return { status: true, message: 'Expense added successfully' };
      } catch (err) {
        console.error('Error adding expense:', err);
        return { status: false, message: 'Failed to add expense' };
      }
    }
  }
}

module.exports = Trip;