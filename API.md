
# API Documentation

## Base URL
`https://www.yasupada.com/mobiletrip/api.php`

## Headers
- `Content-Type: application/json; charset=UTF-8`

## Endpoints

### 1. **Register User**
- **Method:** `POST`
- **Action:** `register`
- **Parameters:**
  - `username` (string): User's username
  - `email` (string): User's email address
  - `password` (string): User's password
- **Response:**
  ```json
  {
    "message": "User registered successfully."
  }
  ```
  or
  ```json
  {
    "message": "User registration failed."
  }
  ```

### 2. **Login User**
- **Method:** `POST`
- **Action:** `login`
- **Parameters:**
  - `username` (string): User's username
  - `password` (string): User's password
- **Response:**
  ```json
  {
    "message": "Login successful.",
    "user_id": "USER_ID"
  }
  ```
  or
  ```json
  {
    "message": "Login failed."
  }
  ```

### 3. **Create Trip**
- **Method:** `POST`
- **Action:** `create_trip`
- **Parameters:**
  - `user_id` (int): User ID
  - `name` (string): Trip name
  - `destination` (string): Trip destination
  - `start_date` (string): Trip start date (YYYY-MM-DD)
  - `end_date` (string): Trip end date (YYYY-MM-DD)
- **Response:**
  ```json
  {
    "message": "Trip created successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to create trip."
  }
  ```

### 4. **Get Trips**
- **Method:** `GET`
- **Action:** `get_trips`
- **Parameters:**
  - `user_id` (int): User ID
- **Response:**
  ```json
  [
    {
      "trip_id": "TRIP_ID",
      "name": "Trip Name",
      "destination": "Destination",
      "start_date": "YYYY-MM-DD",
      "end_date": "YYYY-MM-DD"
    }
    // ... more trips
  ]
  ```

### 5. **Edit Trip**
- **Method:** `POST`
- **Action:** `edit_trip`
- **Parameters:**
  - `trip_id` (int): Trip ID
  - `name` (string): Trip name
  - `destination` (string): Trip destination
  - `start_date` (string): Trip start date (YYYY-MM-DD)
  - `end_date` (string): Trip end date (YYYY-MM-DD)
- **Response:**
  ```json
  {
    "message": "Trip updated successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to update trip."
  }
  ```

### 6. **Delete Trip**
- **Method:** `POST`
- **Action:** `delete_trip`
- **Parameters:**
  - `trip_id` (int): Trip ID
- **Response:**
  ```json
  {
    "message": "Trip deleted successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to delete trip."
  }
  ```

### 7. **Close Trip**
- **Method:** `POST`
- **Action:** `close_trip`
- **Parameters:**
  - `trip_id` (int): Trip ID
- **Response:**
  ```json
  {
    "message": "Trip closed successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to close trip."
  }
  ```

### 8. **Create Event**
- **Method:** `POST`
- **Action:** `create_event`
- **Parameters:**
  - `trip_id` (int): Trip ID
  - `event_name` (string): Event name
  - `description` (string): Event description
  - `event_date` (string): Event date (YYYY-MM-DD)
- **Response:**
  ```json
  {
    "message": "Event created successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to create event."
  }
  ```

### 9. **Update Event**
- **Method:** `POST`
- **Action:** `update_event`
- **Parameters:**
  - `event_id` (int): Event ID
  - `event_name` (string): Event name
  - `description` (string): Event description
  - `event_date` (string): Event date (YYYY-MM-DD)
- **Response:**
  ```json
  {
    "message": "Event updated successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to update event."
  }
  ```

### 10. **Delete Event**
- **Method:** `POST`
- **Action:** `delete_event`
- **Parameters:**
  - `event_id` (int): Event ID
- **Response:**
  ```json
  {
    "message": "Event deleted successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to delete event."
  }
  ```

### 11. **Update Expense**
- **Method:** `POST`
- **Action:** `update_expense`
- **Parameters:**
  - `trip_id` (int): Trip ID
  - `expense_id` (int): Expense ID
  - `amount` (float): Expense amount
  - `description` (string): Expense description
- **Response:**
  ```json
  {
    "message": "Expense updated successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to update expense."
  }
  ```

### 12. **Update User Profile Information**
- **Method:** `POST`
- **Action:** `update_user`
- **Parameters:**
  - `user_id` (int): User ID
  - `username` (string): New username
  - `email` (string): New email address
- **Response:**
  ```json
  {
    "message": "Profile updated successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to update profile."
  }
  ```

### 13. **Update User Profile Image**
- **Method:** `POST`
- **Action:** `update_profile_image`
- **Parameters:**
  - `user_id` (int): User ID
  - `image` (file): Profile image (PNG, JPEG, JPG only)
- **Response:**
  ```json
  {
    "message": "Profile image updated successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to update profile image."
  }
  ```

### 14. **Update User Profile Information (Detailed)**
- **Method:** `POST`
- **Action:** `update_profile_info`
- **Parameters:**
  - `user_id` (int): User ID
  - `first_name` (string): First name
  - `last_name` (string): Last name
  - `phone` (string): Phone number
  - `address` (string): Address
- **Response:**
  ```json
  {
    "message": "Profile updated successfully."
  }
  ```
  or
  ```json
  {
    "message": "Failed to update profile."
  }
  ```

## Testing with `curl`

### Register User
```bash
curl -X POST https://www.yasupada.com/mobiletrip/api.php?action=register \
     -d "username=testuser&email=testuser@example.com&password=securepassword"
```

### Login User
```bash
curl -X POST https://www.yasupada.com/mobiletrip/api.php?action=login \
     -d "username=testuser&password=securepassword"
```

### Create Trip
```bash
curl -X POST https://www.yasupada.com/mobiletrip/api.php?action=create_trip \
     -d "user_id=1&name=Vacation&destination=Paris&start_date=2024-01-01&end_date=2024-01-15"
```

### Get Trips
```bash
curl -X GET "https://www.yasupada.com/mobiletrip/api.php?action=get_trips&user_id=1"
```

### Update Profile Image
```bash
curl -X POST https://www.yasupada.com/mobiletrip/api.php?action=update_profile_image \
     -F "user_id=1" \
     -F "image=@path_to_your_image_file.png"
```

### Update Profile Info
```bash
curl -X POST https://www.yasupada.com/mobiletrip/api.php?action=update_profile_info \
     -d "user_id=1&first_name=John&last_name=Doe&phone=1234567890&address=123 Main St"
```

---
