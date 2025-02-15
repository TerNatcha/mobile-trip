const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const upload = require('../middleware/upload');

router.post('/register', userController.register);
router.post('/login', userController.login);
router.put('/update_user', userController.updateUser);
router.put('/update_profile_image', upload.single('image'), userController.updateProfileImage);
router.put('/update_profile_info', userController.updateProfileInfo);

module.exports = router;