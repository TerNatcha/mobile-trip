<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'User.php';
include_once 'Trip.php';
include_once 'db.php';

$database = new Database();
$db = $database->getConnection();

$action = $_GET['action'] ?? '';

switch ($action) {
    case 'register':
        $user = new User($db);
        $username = $_POST['username'];
        $email = $_POST['email'];
        $password = $_POST['password'];

        if ($user->register($username, $email, $password)) {
            echo json_encode(["message" => "User registered successfully."]);
        } else {
            echo json_encode(["message" => "User registration failed."]);
        }
        break;

    case 'login':
        $user = new User($db);
        $username = $_POST['username'];
        $password = $_POST['password'];

        $user_id = $user->login($username, $password);
        if ($user_id) {
            echo json_encode(["message" => "Login successful.", "user_id" => $user_id]);
        } else {
            echo json_encode(["message" => "Login failed."]);
        }
        break;

    case 'create_trip':
        $trip = new Trip($db);
        $user_id = $_POST['user_id'];
        $name = $_POST['name'];
        $destination = $_POST['destination'];
        $start_date = $_POST['start_date'];
        $end_date = $_POST['end_date'];

        if ($trip->createTrip($user_id, $name, $destination, $start_date, $end_date)) {
            echo json_encode(["message" => "Trip created successfully."]);
        } else {
            echo json_encode(["message" => "Failed to create trip."]);
        }
        break;

    case 'get_trips':
        $trip = new Trip($db);
        $user_id = $_GET['user_id'];
        $trips = $trip->getTrips($user_id);
        echo json_encode($trips);
        break;

    case 'edit_trip':
        $trip = new Trip($db);
        $trip_id = $_POST['trip_id'];
        $name = $_POST['name'];
        $destination = $_POST['destination'];
        $start_date = $_POST['start_date'];
        $end_date = $_POST['end_date'];

        if ($trip->editTrip($trip_id, $name, $destination, $start_date, $end_date)) {
            echo json_encode(["message" => "Trip updated successfully."]);
        } else {
            echo json_encode(["message" => "Failed to update trip."]);
        }
        break;

    case 'delete_trip':
        $trip = new Trip($db);
        $trip_id = $_POST['trip_id'];

        if ($trip->deleteTrip($trip_id)) {
            echo json_encode(["message" => "Trip deleted successfully."]);
        } else {
            echo json_encode(["message" => "Failed to delete trip."]);
        }
        break;

    case 'close_trip':
        $trip = new Trip($db);
        $trip_id = $_POST['trip_id'];

        if ($trip->closeTrip($trip_id)) {
            echo json_encode(["message" => "Trip closed successfully."]);
        } else {
            echo json_encode(["message" => "Failed to close trip."]);
        }
        break;

    // Trip Event Management
    case 'create_event':
        $trip = new Trip($db);
        $trip_id = $_POST['trip_id'];
        $event_name = $_POST['event_name'];
        $description = $_POST['description'];
        $event_date = $_POST['event_date'];

        if ($trip->createEvent($trip_id, $event_name, $description, $event_date)) {
            echo json_encode(["message" => "Event created successfully."]);
        } else {
            echo json_encode(["message" => "Failed to create event."]);
        }
        break;

    case 'update_event':
        $trip = new Trip($db);
        $event_id = $_POST['event_id'];
        $event_name = $_POST['event_name'];
        $description = $_POST['description'];
        $event_date = $_POST['event_date'];

        if ($trip->updateEvent($event_id, $event_name, $description, $event_date)) {
            echo json_encode(["message" => "Event updated successfully."]);
        } else {
            echo json_encode(["message" => "Failed to update event."]);
        }
        break;

    case 'delete_event':
        $trip = new Trip($db);
        $event_id = $_POST['event_id'];

        if ($trip->deleteEvent($event_id)) {
            echo json_encode(["message" => "Event deleted successfully."]);
        } else {
            echo json_encode(["message" => "Failed to delete event."]);
        }
        break;
	// Update Trip Expense
    case 'update_expense':
        $trip = new Trip($db);
        $trip_id = $_POST['trip_id'];
        $expense_id = $_POST['expense_id'];
        $amount = $_POST['amount'];
        $description = $_POST['description'];

        if ($trip->updateExpense($trip_id, $expense_id, $amount, $description)) {
            echo json_encode(["message" => "Expense updated successfully."]);
        } else {
            echo json_encode(["message" => "Failed to update expense."]);
        }
        break;

    // Update User Profile Information
    case 'update_profile':
        $user = new User($db);
        $user_id = $_POST['user_id'];
        $username = $_POST['username'];
        $email = $_POST['email'];

        if ($user->updateProfile($user_id, $username, $email)) {
            echo json_encode(["message" => "Profile updated successfully."]);
        } else {
            echo json_encode(["message" => "Failed to update profile."]);
        }
        break;

    // Update User Profile Image
    case 'update_profile_image':
        $user = new User($db);
        $user_id = $_POST['user_id'];
        $image_path = $_POST['image_path'];

        if ($user->updateProfileImage($user_id, $image_path)) {
            echo json_encode(["message" => "Profile image updated successfully."]);
        } else {
            echo json_encode(["message" => "Failed to update profile image."]);
        }
        break;

    default:
        echo json_encode(["message" => "Invalid action."]);
        break;
}
?>
