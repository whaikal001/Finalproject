<?php
header("Access-Control-Allow-Origin: *"); // WARNING: For production, replace '*' with your specific client origin
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers for your requests
header("Access-Control-Max-Age: 86400"); // Cache preflight requests for 24 hours
header("Content-Type: application/json"); // Ensure response is JSON

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'db_connect.php';

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(array("message" => "Database connection failed."));
    exit();
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405); // Method Not Allowed
    echo json_encode(array("message" => "Only POST requests are allowed."));
    exit();
}

// Check if Content-Type contains application/json (more flexible check)
$contentType = isset($_SERVER["CONTENT_TYPE"]) ? trim($_SERVER["CONTENT_TYPE"]) : '';
if (stripos($contentType, 'application/json') === false) {
    http_response_code(415); // Unsupported Media Type
    echo json_encode(array("message" => "Content-Type must be: application/json. Received: " . $contentType));
    exit();
}

$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Check for JSON decode errors
if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    echo json_encode(array("message" => "Invalid JSON data: " . json_last_error_msg()));
    exit();
}

$worker_id = $data['worker_id'] ?? null;

if (empty($worker_id) || !is_numeric($worker_id)) {
    http_response_code(400); // Bad Request
    echo json_encode(array("message" => "Worker ID is required and must be a number."));
    exit();
}

// Database Query Execution:
// Prepare the SQL statement to prevent SQL injection
$stmt = $conn->prepare("SELECT id, title, description, date_assigned, due_date, status FROM tbl_works WHERE assigned_to = ? ORDER BY due_date ASC");

if ($stmt === false) {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("message" => "Failed to prepare statement: " . $conn->error));
    $conn->close();
    exit();
}

// Bind parameters
$stmt->bind_param("i", $worker_id); // "i" for integer

// Execute the statement
if (!$stmt->execute()) {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("message" => "Failed to execute statement: " . $stmt->error));
    $stmt->close();
    $conn->close();
    exit();
}

$result = $stmt->get_result();

$tasks = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $tasks[] = $row;
    }
    http_response_code(200); // OK
    echo json_encode(array("message" => "Tasks retrieved successfully.", "tasks" => $tasks));
} else {
    http_response_code(200); // OK, but no content
    echo json_encode(array("message" => "No tasks found for this worker.", "tasks" => []));
}

$stmt->close();
$conn->close();
?>