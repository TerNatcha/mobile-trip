const express = require('express');
const router = express.Router();
const messageController = require('../controllers/messageController');

router.post('/send_message', messageController.sendMessage);
router.post('/get_messages', messageController.getMessagesByGroup);

module.exports = router;