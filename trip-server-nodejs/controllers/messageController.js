
const Message = require('../models/messageModel');

exports.sendMessage = async (req, res) => {
  const { group_id, user_id, message } = req.body;
  const success = await Message.sendMessage(group_id, user_id, message);
  if (success) {
    res.json({ message: 'Message sent successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to send message.' });
  }
};

exports.getMessagesByGroup = async (req, res) => {
  const { group_id } = req.body;
  if (group_id === null) {
    return res.status(400).json({ status: 'error', message: 'Missing group_id parameter' });
  }
  const messages = await Message.getMessagesByGroup(group_id);
  res.json(messages);
};