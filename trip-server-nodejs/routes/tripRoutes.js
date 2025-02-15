const express = require('express');
const router = express.Router();
const tripController = require('../controllers/tripController');

router.post('/create_trip', tripController.createTrip);
router.get('/get_trips', tripController.getTrips);
router.get('/get_trip', tripController.getTrip);
router.put('/edit_trip', tripController.editTrip);
router.delete('/delete_trip', tripController.deleteTrip);
router.put('/close_trip', tripController.closeTrip);
router.put('/join_trip', tripController.joinTrip);
router.post('/joined_trip_users', tripController.joinedTripUsers);
router.delete('/unjoin_trip', tripController.unjoinTrip);

module.exports = router;