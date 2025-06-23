<?php
header("Access-Control-Allow-Origin: *"); // Allows requests from any origin.
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers
header("Access-Control-Max-Age: 86400"); // Cache preflight requests for 24 hours

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // For preflight, just send headers and exit
}

include 'db_connect.php';

// Get the POST data
$data = json_decode(file_get_contents("php://input"));

$title = $data->title ?? '';
$description = $data->description ?? '';
$assigned_to_id = $data->assigned_to_id ?? null; // Specific worker ID
$due_date = $data->due_date ?? ''; // Expected format: YYYY-MM-DD

if (empty($title) || empty($description) || $assigned_to_id === null || empty($due_date)) {
    http_response_code(400);
    echo json_encode(array("message" => "Title, description, assigned worker ID, and due date are required."));
    exit();
}

// Validate due_date format (basic check)
if (!preg_match("/^\d{4}-\d{2}-\d{2}$/", $due_date)) {
    http_response_code(400);
    echo json_encode(array("message" => "Invalid due date format. Please use YYYY-MM-DD."));
    exit();
}

// Check if the assigned_to_id exists in tbl_users
$stmt_check_worker = $conn->prepare("SELECT id FROM tbl_users WHERE id = ?");
if ($stmt_check_worker === false) {
    http_response_code(500);
    echo json_encode(array("message" => "Failed to prepare worker check statement: " . $conn->error));
    exit();
}
$stmt_check_worker->bind_param("i", $assigned_to_id);
$stmt_check_worker->execute();
$result_check_worker = $stmt_check_worker->get_result();

if ($result_check_worker->num_rows === 0) {
    http_response_code(404);
    echo json_encode(array("message" => "Worker with ID $assigned_to_id not found."));
    exit();
}
$stmt_check_worker->close();


$date_assigned = date('Y-m-d'); // Current date

$stmt = $conn->prepare("INSERT INTO tbl_works (title, description, assigned_to, date_assigned, due_date, status) VALUES (?, ?, ?, ?, ?, 'pending')");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(array("message" => "Failed to prepare task insertion statement: " . $conn->error));
    exit();
}

$stmt->bind_param("ssiss", $title, $description, $assigned_to_id, $date_assigned, $due_date);

if ($stmt->execute()) {
    http_response_code(201); // Created
    echo json_encode(array("message" => "Task assigned to worker ID $assigned_to_id successfully!"));
} else {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("message" => "Failed to assign task: " . $stmt->error));
}

$stmt->close();
$conn->close();
?>