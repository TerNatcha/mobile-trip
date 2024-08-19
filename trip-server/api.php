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

    default:
        echo json_encode(["message" => "Invalid action."]);
        break;
}
?>
