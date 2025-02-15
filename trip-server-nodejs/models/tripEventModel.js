
const pool = require('../config/db');

class TripEvent {
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
}

module.exports = TripEvent;