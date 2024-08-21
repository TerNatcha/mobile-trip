<?php

class Group
{
    private $conn;

    public function __construct($db)
    {
        $this->conn = $db;
    }

    // Method to create a new group
    public function createGroup($userId, $groupName)
    {
        $sql = "INSERT INTO groups (user_id, name) VALUES (:user_id, :name)";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->bindParam(':name', $groupName);
        return $stmt->execute();
    }

    // Method to invite a user to a group
    public function inviteUserToGroup($groupId, $userId)
    {
        $sql = "INSERT INTO group_users (group_id, user_id) VALUES (:group_id, :user_id)";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':group_id', $groupId);
        $stmt->bindParam(':user_id', $userId);
        return $stmt->execute();
    }

    // Method to get a list of groups
    public function getGroups($userId)
    {
        $sql = "SELECT g.id, g.name FROM groups g
                JOIN group_users gu ON g.id = gu.group_id
                WHERE gu.user_id = :user_id";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Method to get group details
    public function getGroupDetails($groupId)
    {
        $sql = "SELECT id, name FROM groups WHERE id = :group_id";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':group_id', $groupId);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Method to get users in a group
    public function getUsersInGroup($groupId)
    {
        $sql = "SELECT u.id, u.name, u.email FROM users u
                JOIN group_users gu ON u.id = gu.user_id
                WHERE gu.group_id = :group_id";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':group_id', $groupId);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Method to search users by name
    public function searchUsers($query)
    {
        $query = "%{$query}%";
        $sql = "SELECT id, name, email FROM users WHERE name LIKE :query";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':query', $query);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
