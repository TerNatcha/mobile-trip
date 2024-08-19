<?php
include_once 'db.php';

class User {
    private $conn;
    private $table_name = "users";

    public function __construct($db) {
        $this->conn = $db;
    }

    public function register($username, $email, $password) {
        $query = "INSERT INTO " . $this->table_name . " (username, email, password) VALUES (:username, :email, :password)";
        $stmt = $this->conn->prepare($query);
        
        // Hash the password
        $password_hash = password_hash($password, PASSWORD_BCRYPT);

        // Bind parameters
        $stmt->bindParam(':username', $username);
        $stmt->bindParam(':email', $email);
        $stmt->bindParam(':password', $password_hash);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function login($username, $password) {
        $query = "SELECT id, username, password FROM " . $this->table_name . " WHERE username = :username";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':username', $username);
        $stmt->execute();

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row && password_verify($password, $row['password'])) {
            return $row['id']; // Return user ID
        }
        return false;
    }

    // Update User Profile Information
    public function updateProfile($user_id, $username, $email) {
        $query = "UPDATE " . $this->table_name . " 
                  SET username = :username, email = :email 
                  WHERE id = :user_id";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':username', $username);
        $stmt->bindParam(':email', $email);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    // Update User Profile Image
    public function updateProfileImage($user_id, $image_path) {
        $query = "UPDATE " . $this->table_name . " 
                  SET profile_image = :image_path 
                  WHERE id = :user_id";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':image_path', $image_path);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }
}
?>
