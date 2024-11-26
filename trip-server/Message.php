<?php

class Message
{
    private $conn;

    public function __construct($db)
    {
        $this->conn = $db;
    }

    // Method to send a new message
    // 0:message text normal
    // 1:message text trip_id
    public function sendMessage($groupId, $userId, $message)
    {
        try {
            $sql = "INSERT INTO messages (group_id, user_id, message) VALUES (:group_id, :user_id, :message)";
            $stmt = $this->conn->prepare($sql);
            //echo $sql;
            $stmt->bindParam(':group_id', $groupId);
            $stmt->bindParam(':user_id', $userId);
            $stmt->bindParam(':message', $message);
            $stmt->execute();

            return true;
        } catch (PDOException $e) {
            // Log the error message
            // error_log("Error sending message: " . $e->getMessage());

            return false;
        }
    }

    // Method to get messages in a group
    public function getMessagesByGroup($groupId)
    {
        try {
            $sql = "SELECT m.id, m.user_id, u.name AS user_name, m.message, m.created_at
                    FROM messages m
                    JOIN users u ON m.user_id = u.id
                    WHERE m.group_id = :group_id
                    ORDER BY m.created_at ASC";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':group_id', $groupId);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            // Log the error
            // error_log("Error fetching messages: " . $e->getMessage());

            return [];
        }
    }

    // Method to get messages by user in a group
    public function getMessagesByUser($groupId, $userId)
    {
        try {
            $sql = "SELECT m.id, m.message, m.created_at
                    FROM messages m
                    WHERE m.group_id = :group_id AND m.user_id = :user_id
                    ORDER BY m.created_at ASC";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':group_id', $groupId);
            $stmt->bindParam(':user_id', $userId);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            // Log the error
            // error_log("Error fetching user messages: " . $e->getMessage());

            return [];
        }
    }

    // Method to delete a message
    public function deleteMessage($messageId, $userId)
    {
        try {
            $sql = "DELETE FROM messages WHERE id = :message_id AND user_id = :user_id";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':message_id', $messageId);
            $stmt->bindParam(':user_id', $userId);
            $stmt->execute();

            return true;
        } catch (PDOException $e) {
            // Log the error
            //error_log("Error deleting message: " . $e->getMessage());

            return false;
        }
    }

    // Method to search messages in a group by content
    public function searchMessagesInGroup($groupId, $query)
    {
        try {
            $query = "%{$query}%";
            $sql = "SELECT m.id, m.user_id, u.name AS user_name, m.message, m.created_at
                    FROM messages m
                    JOIN users u ON m.user_id = u.id
                    WHERE m.group_id = :group_id AND m.message LIKE :query
                    ORDER BY m.created_at ASC";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':group_id', $groupId);
            $stmt->bindParam(':query', $query);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            // Log the error
            error_log("Error searching messages: " . $e->getMessage());

            return [];
        }
    }
}
