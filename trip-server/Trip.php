<?php
include_once 'db.php';

class Trip {
    private $conn;
    private $table_name = "trips";

    public function __construct($db) {
        $this->conn = $db;
    }

    public function createTrip($user_id, $name, $destination, $start_date, $end_date) {
        $query = "INSERT INTO " . $this->table_name . " (user_id, name, destination, start_date, end_date) VALUES (:user_id, :name, :destination, :start_date, :end_date)";
        $stmt = $this->conn->prepare($query);

        // Bind parameters
        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':destination', $destination);
        $stmt->bindParam(':start_date', $start_date);
        $stmt->bindParam(':end_date', $end_date);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function getTrips($user_id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $user_id);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Add more methods for updating and deleting trips as needed
}
?>
