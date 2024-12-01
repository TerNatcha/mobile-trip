<?php

class Group
{
    private $conn;

    public function __construct($db)
    {
        $this->conn = $db;
    }

    // Method to create a new group
    public function createGroup($ownerId, $groupName, $description = null)
    {
        try {
            $sql = "INSERT INTO groups (owner_id, name, description) VALUES (:owner_id, :name, :description)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':owner_id', $ownerId);
            $stmt->bindParam(':name', $groupName);
            $stmt->bindParam(':description', $description);
            $stmt->execute();

            return true;
        } catch (PDOException $e) {
            // Log the error message
            error_log("Error creating group: " . $e->getMessage());

            // Return false or a custom error message
            return false;
        }
    }


    // Method to invite a user to a group
    public function inviteUserToGroup($groupId, $userId)
    {
        try {
            $sql = "INSERT INTO group_users (group_id, user_id) VALUES (:group_id, :user_id)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':group_id', $groupId);
            $stmt->bindParam(':user_id', $userId);
            $stmt->execute();

            return true;
        } catch (PDOException $e) {
            // Log the error
            error_log("Error inviting user to group: " . $e->getMessage());

            return false;
        }
    }

    // Method to get a list of groups
    public function getGroups($userId)
    {
        try {
            $sql = "SELECT g.id, g.name,g.description FROM groups g
                    
                    WHERE g.owner_id = :user_id";

            $sql = "SELECT g.id, g.name,g.description FROM groups g ";

            $stmt = $this->conn->prepare($sql);
            // $stmt->bindParam(':user_id', $userId);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            // Log the error
            error_log("Error fetching groups: " . $e->getMessage());

            return [];
        }
    }

    // Method to get group details
    public function getGroupDetails($groupId)
    {
        try {
            $sql = "SELECT id, name FROM groups WHERE id = :group_id";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':group_id', $groupId);
            $stmt->execute();

            return $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            // Log the error
            error_log("Error fetching group details: " . $e->getMessage());

            return null;
        }
    }

    // Method to get users in a group
    public function getUsersInGroup($groupId)
    {
        try {
            $sql = "SELECT u.id, u.name, u.email FROM users u
                    JOIN group_users gu ON u.id = gu.user_id
                    WHERE gu.group_id = :group_id";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':group_id', $groupId);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            // Log the error
            error_log("Error fetching users in group: " . $e->getMessage());

            return [];
        }
    }

    // Method to search users by name
    public function searchUsers($query)
    {
        try {
            $query = "%{$query}%";
            $sql = "SELECT id, name, email FROM users WHERE name LIKE :query";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':query', $query);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            // Log the error
            error_log("Error searching users: " . $e->getMessage());

            return [];
        }
    }
}
