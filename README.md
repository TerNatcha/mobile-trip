"# mobile-trip"  


curl -X POST "https://www.yasupada.com/mobiletrip/api.php?action=register" -d "username=testuser" -d "email=testuser@example.com" -d "password=password123"

curl -X POST "https://www.yasupada.com/mobiletrip/api.php?action=update_profile" -d "user_id=1" -d "username=updateduser" -d "email=updateduser@example.com"



curl -X POST "https://www.yasupada.com/mobiletrip/api.php?action=login" -d "username=testuser" -d "password=password123"

curl -X POST "https://www.yasupada.com/mobiletrip/api.php?action=create_trip" -d "user_id=1" -d "name=Trip to Paris" -d "destination=Paris" -d "start_date=2024-09-01" -d "end_date=2024-09-10"
