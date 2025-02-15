const Trip = require('../models/tripModel');

exports.createTrip = async (req, res) => {
  const { user_id, name, destination, start_date, end_date, latitude, longitude } = req.body;
  const success = await Trip.createTrip(user_id, name, destination, start_date, end_date, latitude, longitude);
  if (success) {
    res.json({ message: 'Trip created successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to create trip.' });
  }
};

exports.getTrips = async (req, res) => {
  const user_id = req.query.user_id;
  const trips = await Trip.getTrips(user_id);
  res.json(trips);
};

exports.getTrip = async (req, res) => {
  const trip_id = req.query.trip_id;
  const trip = await Trip.getTrip(trip_id);
  res.json(trip);
};

exports.editTrip = async (req, res) => {
  const { trip_id, name, destination, start_date, end_date, latitude, longitude } = req.body;
  const success = await Trip.editTrip(trip_id, name, destination, start_date, end_date, latitude, longitude);
  if (success) {
    res.json({ message: 'Trip updated successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to update trip.' });
  }
};

exports.deleteTrip = async (req, res) => {
  const { trip_id } = req.body;
  const success = await Trip.deleteTrip(trip_id);
  if (success) {
    res.json({ message: 'Trip deleted successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to delete trip.' });
  }
};

exports.closeTrip = async (req, res) => {
  const { trip_id } = req.body;
  const success = await Trip.closeTrip(trip_id);
  if (success) {
    res.json({ message: 'Trip closed successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to close trip.' });
  }
};

exports.joinTrip = async (req, res) => {
  const { trip_id, user_id, start_date, end_date } = req.body;
  const success = await Trip.joinTrip(trip_id, user_id, start_date, end_date);
  if (success) {
    res.json({ message: 'Join Trip successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to join trip.' });
  }
};

exports.joinedTripUsers = async (req, res) => {
  const { trip_id } = req.body;
  const users = await Trip.joinedTripUsers(trip_id);
  res.json(users);
};

exports.unjoinTrip = async (req, res) => {
  const { trip_id, user_id } = req.query;
  const success = await Trip.unjoinTrip(trip_id, user_id);
  if (success) {
    res.json({ message: 'Un-Join Trip successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to un-join trip.' });
  }
};