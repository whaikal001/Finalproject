<?php
header("Access-Control-Allow-Origin: *"); // Allows requests from any origin. For production, specify your client's origin (e.g., "http://localhost:50000").
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers
header("Access-Control-Max-Age: 86400"); // Cache preflight requests for 24 hours

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // For preflight, just send headers and exit
}
// login_worker.php
// Authenticates worker credentials and returns worker details on success.

include 'db_connect.php';

// Get the POST data
$data = json_decode(file_get_contents("php://input"));

$email = $data->email ?? '';
$password = $data->password ?? ''; // Raw password

// Basic validation
if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(array("message" => "Please enter both email and password."));
    exit();
}

// Hash the input password for comparison
$hashed_password = sha1($password);

// Prepare and bind
$stmt = $conn->prepare("SELECT id, full_name, email, phone, address FROM tbl_users WHERE email = ? AND password = ?");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(array("message" => "Failed to prepare statement: " . $conn->error));
    exit();
}
$stmt->bind_param("ss", $email, $hashed_password);

// Execute the statement
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // User found, login successful
    $worker = $result->fetch_assoc();
    http_response_code(200);
    echo json_encode(array("message" => "Login successful!", "worker" => $worker));
} else {
    // No user found or incorrect credentials
    http_response_code(401); // Unauthorized
    echo json_encode(array("message" => "Invalid email or password."));
}

$stmt->close();
$conn->close();
?>