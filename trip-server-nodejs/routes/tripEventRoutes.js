const express = require('express');
const router = express.Router();
const tripEventController = require('../controllers/tripEventController');

router.post('/create_event', tripEventController.createEvent);
router.put('/update_event', tripEventController.updateEvent);
router.delete('/delete_event', tripEventController.deleteEvent);

module.exports = router;