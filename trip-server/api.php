<?php

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once 'Functions.php';
include_once 'User.php';
include_once 'Trip.php';
include_once 'Group.php';
include_once 'db.php';

$database = new Database();
$db = $database->getConnection();

$action = $_GET['action'] ?? '';

switch ($action) {
  case 'register':
    $user = new User($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    // Retrieve 'username' and 'password' from the data
    $username = $data['username'];
    $email = $data['email'];
    $password = $data['password'];

    if ($user->register($username, $email, $password)) {
      echo json_encode(["message" => "User registered successfully."]);
    } else {
      echo json_encode(["message" => "User registration failed."]);
    }
    break;

  case 'login':
    $user = new User($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    // Retrieve 'username' and 'password' from the data
    $username = $data['username'];
    $password = $data['password'];

    $user_id = $user->login($username, $password);
    if ($user_id) {
      echo json_encode(["message" => "Login successful.", "user_id" => $user_id]);
    } else {
      echo json_encode(["message" => "Login failed."]);
    }
    break;

  case 'create_trip':
    $trip = new Trip($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    $user_id = $data['user_id'];
    $name = $data['name'];
    $destination = $data['destination'];
    $start_date = $data['start_date'];
    $end_date = $data['end_date'];

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

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    $trip_id = $data['trip_id'];
    $name = $data['name'];
    $destination = $data['destination'];
    $start_date = $data['start_date'];
    $end_date = $data['end_date'];

    if ($trip->editTrip($trip_id, $name, $destination, $start_date, $end_date)) {
      echo json_encode(["message" => "Trip updated successfully."]);
    } else {
      echo json_encode(["message" => "Failed to update trip."]);
    }
    break;

  case 'delete_trip':
    $trip = new Trip($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    $trip_id = $data['trip_id'];

    if ($trip->deleteTrip($trip_id)) {
      echo json_encode(["message" => "Trip deleted successfully."]);
    } else {
      echo json_encode(["message" => "Failed to delete trip."]);
    }
    break;

  case 'close_trip':
    $trip = new Trip($db);
    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    $trip_id = $data['trip_id'];

    if ($trip->closeTrip($trip_id)) {
      echo json_encode(["message" => "Trip closed successfully."]);
    } else {
      echo json_encode(["message" => "Failed to close trip."]);
    }
    break;

    // Trip Event Management
  case 'create_event':
    $trip = new Trip($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    $trip_id = $data['trip_id'];

    $event_name = $data['event_name'];
    $description = $data['description'];
    $event_date = $data['event_date'];

    if ($trip->createEvent($trip_id, $event_name, $description, $event_date)) {
      echo json_encode(["message" => "Event created successfully."]);
    } else {
      echo json_encode(["message" => "Failed to create event."]);
    }
    break;

  case 'update_event':
    $trip = new Trip($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }


    $event_id = $data['event_id'];
    $event_name = $data['event_name'];
    $description = $data['description'];
    $event_date = $data['event_date'];

    if ($trip->updateEvent($event_id, $event_name, $description, $event_date)) {
      echo json_encode(["message" => "Event updated successfully."]);
    } else {
      echo json_encode(["message" => "Failed to update event."]);
    }
    break;

  case 'delete_event':
    $trip = new Trip($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    $event_id = $data['event_id'];

    if ($trip->deleteEvent($event_id)) {
      echo json_encode(["message" => "Event deleted successfully."]);
    } else {
      echo json_encode(["message" => "Failed to delete event."]);
    }
    break;
    // Update Trip Expense
  case 'update_expense':
    $trip = new Trip($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    $trip_id = $data['trip_id'];
    $expense_id = $data['expense_id'];
    $amount = $data['amount'];
    $description = $data['description'];

    if ($trip->updateExpense($trip_id, $expense_id, $amount, $description)) {
      echo json_encode(["message" => "Expense updated successfully."]);
    } else {
      echo json_encode(["message" => "Failed to update expense."]);
    }
    break;

    // Update User Profile Information
  case 'update_user':
    $user = new User($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    $user_id = $data['user_id'];
    $username = $data['username'];
    $email = $data['email'];

    if ($user->updateUser($user_id, $username, $email)) {
      echo json_encode(["message" => "Profile updated successfully."]);
    } else {
      echo json_encode(["message" => "Failed to update profile."]);
    }
    break;

  case 'update_profile_image':
    // Directory where images will be stored
    $upload_dir = 'uploads/profile_images/';

    // Check if the directory exists, if not create it
    if (!is_dir($upload_dir)) {
      mkdir($upload_dir, 0755, true);
    }

    // Check if a file was uploaded
    if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
      $file_name = $_FILES['image']['name'];
      $file_tmp_name = $_FILES['image']['tmp_name'];
      $file_size = $_FILES['image']['size'];
      $file_error = $_FILES['image']['error'];
      $file_type = $_FILES['image']['type'];

      // Validate file type
      $allowed_types = ['image/png', 'image/jpeg', 'image/jpg'];
      if (!in_array($file_type, $allowed_types)) {
        echo json_encode(["message" => "Invalid file type. Only PNG, JPEG, and JPG are allowed."]);
        break;
      }

      // Validate file size (e.g., max 5MB)
      if ($file_size > 5 * 1024 * 1024) {
        echo json_encode(["message" => "File size exceeds the maximum limit of 5MB."]);
        break;
      }

      // Move the uploaded file to the desired directory
      $new_file_path = $upload_dir . basename($file_name);
      if (move_uploaded_file($file_tmp_name, $new_file_path)) {
        //print_r($_FILES);
        // Update the user profile with the new image path
        $user = new User($db);
        $user_id = $_POST['user_id'];
        $image_path = $new_file_path;


        if ($user->updateProfileImage($user_id, $file_name)) {
          echo json_encode(["message" => "Profile image updated successfully."]);
        } else {
          echo json_encode(["message" => "Failed to update profile image."]);
        }
      } else {
        echo json_encode(["message" => "Failed to move uploaded file."]);
      }
    } else {
      echo json_encode(["message" => "No file uploaded or file upload error."]);
    }
    break;


    // Update user profile information
  case 'update_profile_info':
    $user = new User($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    $user_id = $data['user_id'];
    $first_name = $data['first_name'];
    $last_name = $data['last_name'];
    $phone = $data['phone'];
    $address = $data['address'];

    if ($user->updateProfileInfo($user_id, $first_name, $last_name, $phone, $address)) {
      echo json_encode(["message" => "Profile updated successfully."]);
    } else {
      echo json_encode(["message" => "Failed to update profile."]);
    }
    break;

  case 'respond_invite':
    $user = new User($db);

    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    // Retrieve 'group_id', 'user_id', and 'accepted' from the data
    $group_id = $data['group_id'];
    $user_id = $data['user_id'];
    $accepted = $data['accepted'] === 'true' ? 1 : 0;

    // Prepare the query to update the invitation status
    $query = "UPDATE group_invitations SET accepted = :accepted WHERE group_id = :group_id AND user_id = :user_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(':accepted', $accepted, PDO::PARAM_INT);
    $stmt->bindParam(':group_id', $group_id, PDO::PARAM_INT);
    $stmt->bindParam(':user_id', $user_id, PDO::PARAM_INT);

    if ($stmt->execute()) {
      echo json_encode(["message" => "Invitation response updated successfully."]);
    } else {
      echo json_encode(["message" => "Failed to update invitation response."]);
    }
    break;

  case 'invite_user':
    $data = extractRawJSON();

    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    // Retrieve 'group_id' and 'user_id' from the data
    $group_id = $data['group_id'];
    $user_id = $data['user_id'];

    // Add logic to handle the user invitation
    // This may involve interacting with a database or sending notifications
    // For demonstration purposes, let's assume we're adding the user to the group
    $group = new Group($db);

    if ($group->inviteUserToGroup($group_id, $user_id)) {
      echo json_encode(["message" => "User invited successfully."]);
    } else {
      echo json_encode(["message" => "Failed to invite user."]);
    }
    break;

  case 'create_group':
    $data = extractRawJSON();
    // Check if the decoding was successful
    if ($data === null) {
      echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
      exit;
    }

    // Retrieve 'user_id' and 'name' from the data
    $user_id = $data['user_id'];
    $group_name = $data['group_name'];
    $description = $data['description'];

    // Validate inputs
    if (empty($user_id) || empty($group_name)) {
      echo json_encode(['status' => 'error', 'message' => 'Missing required fields']);
      exit;
    }

    // Add logic to create a new group
    $group = new Group($db);

    if ($group->createGroup($user_id, $group_name, $description)) {
      echo json_encode(['status' => 'success', 'message' => 'Group created successfully.']);
    } else {
      echo json_encode(['status' => 'error', 'message' => 'Failed to create group.']);
    }
    //print_r($data);
    break;

  case 'get_groups':
    $group = new Group($db);

    // Get parameters from the request
    $user_id = $_GET['user_id'] ?? null;

    // Validate parameters
    if ($user_id === null) {
      echo json_encode(['status' => 'error', 'message' => 'Missing user_id parameter']);
      exit;
    }

    $results = $group->getGroups($user_id);

    if ($results) {
      //echo json_encode(['status' => 'success', 'data' => $results]);
      echo json_encode($results);
    } else {
      echo json_encode(['status' => 'error', 'message' => 'No groups found']);
    }

    break;

  case 'search_users':
    // Get the query parameter
    $query = $_GET['query'] ?? '';

    // Validate the query
    if (empty($query)) {
      echo json_encode(['status' => 'error', 'message' => 'Query parameter is missing']);
      exit;
    }

    // Add logic to search users
    $group = new Group($db);
    $results = $group->searchUsers($query);

    if ($results) {
      echo json_encode(['status' => 'success', 'data' => $results]);
    } else {
      echo json_encode(['status' => 'error', 'message' => 'No users found']);
    }
    break;

  default:
    echo json_encode(["message" => "Invalid action."]);
    break;
}
