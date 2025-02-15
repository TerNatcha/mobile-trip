const Group = require('../models/groupModel');

exports.createGroup = async (req, res) => {
  const { user_id, group_name, description } = req.body;
  if (empty(user_id) || empty(group_name)) {
    return res.status(400).json({ status: 'error', message: 'Missing required fields' });
  }
  const success = await Group.createGroup(user_id, group_name, description);
  if (success) {
    res.json({ status: 'success', message: 'Group created successfully.' });
  } else {
    res.status(500).json({ status: 'error', message: 'Failed to create group.' });
  }
};

exports.getGroups = async (req, res) => {
  const user_id = req.query.user_id;
  if (user_id === null) {
    return res.status(400).json({ status: 'error', message: 'Missing user_id parameter' });
  }
  const results = await Group.getGroups(user_id);
  if (results) {
    res.json(results);
  } else {
    res.status(404).json({ status: 'error', message: 'No groups found' });
  }
};

exports.searchUsers = async (req, res) => {
  const query = req.query.query;
  if (empty(query)) {
    return res.status(400).json({ status: 'error', message: 'Query parameter is missing' });
  }
  const results = await Group.searchUsers(query);
  if (results) {
    res.json({ status: 'success', data: results });
  } else {
    res.status(404).json({ status: 'error', message: 'No users found' });
  }
};

exports.inviteUserToGroup = async (req, res) => {
  const { group_id, user_id } = req.body;
  const success = await Group.inviteUserToGroup(group_id, user_id);
  if (success) {
    res.json({ message: 'User invited successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to invite user.' });
  }
};

exports.removeUserFromGroup = async (req, res) => {
  const { group_id, user_id } = req.body;
  const success = await Group.removeUserFromGroup(group_id, user_id);
  if (success) {
    res.json({ message: 'User removed successfully.' });
  } else {
    res.status(500).json({ message: 'Failed to remove user.' });
  }
};