"# mobile-trip"  


curl -X POST "https://www.yasupada.com/mobiletrip/api.php?action=register" -d "username=testuser" -d "email=testuser@example.com" -d "password=password123"

curl -X POST "http://www.yasupada.com/mobiletrip/api.php?action=update_profile_info" -H "Content-Type: application/x-www-form-urlencoded" -d "user_id=1" -d "first_name=John" -d "last_name=Doe" -d "date_of_birth=1990-01-01" -d "address=123 Main St, Anytown, USA"




curl -X POST "https://www.yasupada.com/mobiletrip/api.php?action=login" -d "username=testuser" -d "password=password123"

curl -X POST "https://www.yasupada.com/mobiletrip/api.php?action=create_trip" -d "user_id=1" -d "name=Trip to Paris" -d "destination=Paris" -d "start_date=2024-09-01" -d "end_date=2024-09-10"
