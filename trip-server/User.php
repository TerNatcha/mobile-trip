<?php
include_once 'db.php';

class User
{
    private $conn;
    private $table_name = "users";
    private $profile_table = "user_profiles";

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function register($username, $email, $password)
    {
        try {
            // Begin transaction
            $this->conn->beginTransaction();

            // Insert into users table
            $query = "INSERT INTO " . $this->table_name . " (username, email, password) VALUES (:username, :email, :password)";
            $stmt = $this->conn->prepare($query);

            // Hash the password
            $password_hash = password_hash($password, PASSWORD_BCRYPT);

            // Bind parameters
            $stmt->bindParam(':username', $username);
            $stmt->bindParam(':email', $email);
            $stmt->bindParam(':password', $password_hash);

            // Execute the statement
            if (!$stmt->execute()) {
                throw new Exception("Failed to register user.");
            }

            // Get the last inserted user ID
            $user_id = $this->conn->lastInsertId();

            // Insert into user_profile table
            $profile_query = "INSERT INTO " . $this->profile_table . " (user_id) VALUES (:user_id)";
            $profile_stmt = $this->conn->prepare($profile_query);

            // Bind parameters
            $profile_stmt->bindParam(':user_id', $user_id);

            // Execute the statement
            if (!$profile_stmt->execute()) {
                throw new Exception("Failed to create user profile.");
            }

            // Commit transaction
            $this->conn->commit();
            return true;
        } catch (Exception $e) {
            // Rollback transaction

            $this->conn->rollBack();
            return false;
        }
    }


    public function login($username, $password)
    {
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

    // Get User Information by ID
    public function getUserInfo($user_id)
    {
        $query = "SELECT id, username, email, profile_image, created_at FROM " . $this->table_name . " WHERE id = :user_id LIMIT 0,1";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            return $stmt->fetch(PDO::FETCH_ASSOC);
        } else {
            return null;
        }
    }

    // Update User Profile Information
    public function updateUser($user_id, $username, $email)
    {
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

    // Update user profile image
    public function updateProfileImage($user_id, $profile_picture)
    {
        $query = "UPDATE " . $this->profile_table . " 
                  SET profile_picture = :profile_picture 
                  WHERE user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':profile_picture', $profile_picture);
        return $stmt->execute();
    }

    // Update user profile information
    public function updateProfileInfo($user_id, $first_name, $last_name,   $phone,   $address)
    {
        $query = "UPDATE " . $this->profile_table . " 
                  SET first_name = :first_name, last_name = :last_name,   phone = :phone ,   address = :address 
                  WHERE user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':first_name', $first_name);
        $stmt->bindParam(':last_name', $last_name);
        $stmt->bindParam(':phone', $phone);
        $stmt->bindParam(':address', $address);
        return $stmt->execute();
    }
}
