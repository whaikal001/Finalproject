<?php
header("Access-Control-Allow-Origin: *"); // Allows requests from any origin. For production, specify your client's origin (e.g., "http://localhost:50000").
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers
header("Access-Control-Max-Age: 86400"); // Cache preflight requests for 24 hours

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // For preflight, just send headers and exit
}
// register_worker.php
// Handles worker registration, inserts data into tbl_users.

include 'db_connect.php';

// Get the POST data
$data = json_decode(file_get_contents("php://input"));

$full_name = $data->full_name ?? '';
$email = $data->email ?? '';
$password = $data->password ?? ''; // Raw password
$phone = $data->phone ?? '';
$address = $data->address ?? '';

// Basic validation
if (empty($full_name) || empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(array("message" => "Please fill all required fields (Full Name, Email, Password)."));
    exit();
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(array("message" => "Invalid email format."));
    exit();
}

if (strlen($password) < 6) {
    http_response_code(400);
    echo json_encode(array("message" => "Password must be at least 6 characters long."));
    exit();
}

// Hash the password using SHA1
$hashed_password = sha1($password);

// Prepare and bind
$stmt = $conn->prepare("INSERT INTO tbl_users (full_name, email, password, phone, address) VALUES (?, ?, ?, ?, ?)");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(array("message" => "Failed to prepare statement: " . $conn->error));
    exit();
}
$stmt->bind_param("sssss", $full_name, $email, $hashed_password, $phone, $address);

// Execute the statement
if ($stmt->execute()) {
    http_response_code(201); // Created
    echo json_encode(array("message" => "Worker registered successfully!"));
} else {
    // Check for duplicate email error
    if ($conn->errno == 1062) { // MySQL error code for duplicate entry
        http_response_code(409); // Conflict
        echo json_encode(array("message" => "Email already registered. Please use a different email."));
    } else {
        http_response_code(500); // Internal Server Error
        echo json_encode(array("message" => "Failed to register worker: " . $stmt->error));
    }
}

$stmt->close();
$conn->close();
?>