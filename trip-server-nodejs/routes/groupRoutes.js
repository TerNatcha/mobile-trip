const express = require('express');
const router = express.Router();
const groupController = require('../controllers/groupController');

router.post('/create_group', groupController.createGroup);
router.get('/get_groups', groupController.getGroups);
router.get('/search_users', groupController.searchUsers);
router.post('/invite_user', groupController.inviteUserToGroup);
router.delete('/remove_user_from_group', groupController.removeUserFromGroup);

module.exports = router;