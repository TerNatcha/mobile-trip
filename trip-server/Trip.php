<?php
include_once 'db.php';

class Trip
{
    private $conn;
    private $table_name = "trips";

    private $expenses_table = "trip_expenses"; // Table for trip expenses

    private $events_table = "trip_events"; // Table for trip events

    private $trip_participants = "trip_participants";

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function createTrip($user_id, $name, $destination, $start_date, $end_date, $latitude, $longitude)
    {
        $query = "INSERT INTO " . $this->table_name . " (user_id, name, destination, start_date, end_date,latitude ,longitude) VALUES (:user_id, :name, :destination, :start_date, :end_date, :latitude , :longitude)";
        $stmt = $this->conn->prepare($query);

        // Bind parameters
        $stmt->bindParam(':user_id', $user_id);
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':destination', $destination);
        $stmt->bindParam(':start_date', $start_date);
        $stmt->bindParam(':end_date', $end_date);
        $stmt->bindParam(':latitude', $latitude);
        $stmt->bindParam(':longitude', $longitude);

        if ($stmt->execute()) {
            $trip_id = $this->getLastInsertId();
            $this->ownerToTrip($trip_id, $user_id);

            return true;
        }
        return false;
    }

    public function getLastInsertId()
    {
        try {
            return $this->conn->lastInsertId();
        } catch (PDOException $e) {
            // Log the error message
            error_log("Error retrieving last insert ID: " . $e->getMessage());
            return false;
        }
    }

    // Method to invite a user to a group
    public function ownerToTrip($tripId, $userId)
    {
        try {
            $sql = "INSERT INTO trip_participants (trip_id, user_id) VALUES (:trip_id, :user_id)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':trip_id', $tripId);
            $stmt->bindParam(':user_id', $userId);
            $stmt->execute();

            return true;
        } catch (PDOException $e) {
            // Log the error
            error_log("Error inviting user to group: " . $e->getMessage());

            return false;
        }
    }

    public function getTrips($user_id)
    {

        $query = "SELECT * FROM " . $this->table_name;

        $stmt = $this->conn->prepare($query);

        if ($user_id != "") {
            //$query = "SELECT * FROM " . $this->table_name . " WHERE user_id = :user_id";
            $query = "SELECT distinct t.* FROM ((`trips` t inner join trip_participants tp on t.user_id = tp.user_id) inner join users u on u.id = tp.user_id) WHERE tp.user_id = :user_id;";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':user_id', $user_id);
        }

        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getTrip($trip_id)
    {
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = :trip_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':trip_id', $trip_id);
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC)[0];
    }

    public function editTrip($trip_id, $name, $destination, $start_date, $end_date, $latitude, $longitude)
    {
        $query = "UPDATE " . $this->table_name . " 
                  SET name = :name, destination = :destination, start_date = :start_date, end_date = :end_date, latitude = :latitude, longitude = :longitude 
                  WHERE id = :trip_id";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':trip_id', $trip_id);
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':destination', $destination);
        $stmt->bindParam(':start_date', $start_date);
        $stmt->bindParam(':end_date', $end_date);
        $stmt->bindParam(':latitude', $latitude);
        $stmt->bindParam(':longitude', $longitude);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function joinTrip($trip_id, $user_id, $start_date, $end_date)
    {

        // Check if a record already exists
        $checkQuery = "SELECT COUNT(*) as count FROM " . $this->trip_participants . " 
                   WHERE trip_id = :trip_id AND user_id = :user_id";
        $checkStmt = $this->conn->prepare($checkQuery);

        $checkStmt->bindParam(':trip_id', $trip_id);
        $checkStmt->bindParam(':user_id', $user_id);
        $checkStmt->execute();
        $row = $checkStmt->fetch(PDO::FETCH_ASSOC);

        if ($row['count'] > 0) {
            // Update the existing record
            $updateQuery = "UPDATE " . $this->trip_participants . " 
                        SET start_date = :start_date, end_date = :end_date 
                        WHERE trip_id = :trip_id AND user_id = :user_id";
            $updateStmt = $this->conn->prepare($updateQuery);

            $updateStmt->bindParam(':trip_id', $trip_id);
            $updateStmt->bindParam(':user_id', $user_id);
            $updateStmt->bindParam(':start_date', $start_date);
            $updateStmt->bindParam(':end_date', $end_date);

            if ($updateStmt->execute()) {
                return true; // Record updated successfully
            }
        } else {
            // Insert a new record
            $insertQuery = "INSERT INTO " . $this->trip_participants . " 
                        (trip_id, user_id, start_date, end_date) 
                        VALUES (:trip_id, :user_id, :start_date, :end_date)";
            $insertStmt = $this->conn->prepare($insertQuery);

            $insertStmt->bindParam(':trip_id', $trip_id);
            $insertStmt->bindParam(':user_id', $user_id);
            $insertStmt->bindParam(':start_date', $start_date);
            $insertStmt->bindParam(':end_date', $end_date);

            if ($insertStmt->execute()) {
                return true; // Record inserted successfully
            }
        }

        return false; // If both operations fail
    }

    public function joinedTripUsers($trip_id)
    {
        // Check if a record already exists
        $checkQuery = "SELECT u.username, tp.id,tp.user_id,tp.trip_id,tp.start_date,tp.end_date FROM (" . $this->trip_participants . " tp INNER JOIN users u ON tp.user_id = u.id) INNER JOIN trips t ON tp.trip_id = t.id  WHERE tp.trip_id = :trip_id ";
        $checkStmt = $this->conn->prepare($checkQuery);

        $checkStmt->bindParam(':trip_id', $trip_id);

        $checkStmt->execute();
        return $checkStmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function unjoinTrip($trip_id, $user_id)
    {
        // Prepare the DELETE query
        $query = "DELETE FROM " . $this->trip_participants . " WHERE trip_id = :trip_id AND user_id = :user_id";
        $stmt = $this->conn->prepare($query);

        // Bind parameters
        $stmt->bindParam(':trip_id', $trip_id);
        $stmt->bindParam(':user_id', $user_id);

        // Execute the query
        if ($stmt->execute()) {
            return true; // Successfully removed the user from the trip
        }

        return false; // Failed to remove the user
    }

    public function deleteTrip($trip_id)
    {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = :trip_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':trip_id', $trip_id);

        if ($stmt->execute()) {
            return true;
        }

        return false;
    }

    public function closeTrip($trip_id)
    {
        $query = "UPDATE " . $this->table_name . " SET status = 'closed' WHERE id = :trip_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':trip_id', $trip_id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    // Trip Event Management
    public function createEvent($trip_id, $event_name, $description, $event_date)
    {
        $query = "INSERT INTO " . $this->events_table . " (trip_id, event_name, description, event_date) VALUES (:trip_id, :event_name, :description, :event_date)";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':trip_id', $trip_id);
        $stmt->bindParam(':event_name', $event_name);
        $stmt->bindParam(':description', $description);
        $stmt->bindParam(':event_date', $event_date);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function updateEvent($event_id, $event_name, $description, $event_date)
    {
        $query = "UPDATE " . $this->events_table . " 
                  SET event_name = :event_name, description = :description, event_date = :event_date 
                  WHERE id = :event_id";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':event_id', $event_id);
        $stmt->bindParam(':event_name', $event_name);
        $stmt->bindParam(':description', $description);
        $stmt->bindParam(':event_date', $event_date);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function deleteEvent($event_id)
    {
        $query = "DELETE FROM " . $this->events_table . " WHERE id = :event_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':event_id', $event_id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    // Update Expense for a Trip
    public function updateExpense($trip_id, $expense_id, $amount, $description)
    {
        $query = "UPDATE " . $this->expenses_table . " 
                  SET amount = :amount, description = :description 
                  WHERE id = :expense_id AND trip_id = :trip_id";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(':trip_id', $trip_id);
        $stmt->bindParam(':expense_id', $expense_id);
        $stmt->bindParam(':amount', $amount);
        $stmt->bindParam(':description', $description);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }
}
