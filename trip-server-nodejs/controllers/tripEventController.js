const TripEvent = require('../models/tripEventModel');

exports.createEvent = async (req, res) => {
  const { trip_id, event_name, description, event_date } = req.body;
  const success = await TripEvent.createEvent(trip_id, event_name, description, event_date);
  if (success) {
    res.json({ message: 'Event created successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to create event.' });
  }
};

exports.updateEvent = async (req, res) => {
  const { event_id, event_name, description, event_date } = req.body;
  const success = await TripEvent.updateEvent(event_id, event_name, description, event_date);
  if (success) {
    res.json({ message: 'Event updated successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to update event.' });
  }
};

exports.deleteEvent = async (req, res) => {
  const { event_id } = req.body;
  const success = await TripEvent.deleteEvent(event_id);
  if (success) {
    res.json({ message: 'Event deleted successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to delete event.' });
  }
};