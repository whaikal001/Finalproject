<?php
header("Access-Control-Allow-Origin: *"); // Allows requests from any origin. For production, specify your client's origin (e.g., "http://localhost:50000").
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers
header("Access-Control-Max-Age: 86400"); // Cache preflight requests for 24 hours

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // For preflight, just send headers and exit
}
// get_profile.php
// Retrieves worker profile details for a given worker_id.

include 'db_connect.php';

// Get the POST data
$data = json_decode(file_get_contents("php://input"));

$worker_id = $data->worker_id ?? null;

if ($worker_id === null) {
    http_response_code(400);
    echo json_encode(array("message" => "Worker ID is required."));
    exit();
}

// Prepare and bind
$stmt = $conn->prepare("SELECT id, full_name, email, phone, address FROM tbl_users WHERE id = ?");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(array("message" => "Failed to prepare statement: " . $conn->error));
    exit();
}
$stmt->bind_param("i", $worker_id);

// Execute the statement
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $profile = $result->fetch_assoc();
    http_response_code(200);
    echo json_encode($profile); // Directly return the worker object
} else {
    http_response_code(404); // Not Found
    echo json_encode(array("message" => "Worker not found."));
}

$stmt->close();
$conn->close();
?>