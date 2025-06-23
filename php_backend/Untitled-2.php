<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Max-Age: 86400");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

include 'db_connect.php';

// Ensure the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(["message" => "Method Not Allowed. Only POST requests are accepted."]);
    exit();
}

// Get the POST data
$data = json_decode(file_get_contents("php://input"));

$title = $data->title ?? '';
$description = $data->description ?? '';
$due_date = $data->due_date ?? ''; // Expected format: YYYY-MM-DD
$assigned_to_worker_id = $data->worker_id ?? null; // The specific worker ID

// Basic validation for required fields
if (empty($title) || empty($description) || empty($due_date) || $assigned_to_worker_id === null) {
    http_response_code(400);
    echo json_encode(["message" => "Title, description, due date, and worker ID are required."]);
    exit();
}

// Validate due_date format
if (!preg_match("/^\d{4}-\d{2}-\d{2}$/", $due_date)) {
    http_response_code(400);
    echo json_encode(["message" => "Due date format must be YYYY-MM-DD."]);
    exit();
}

// Validate worker_id is an integer
if (!is_numeric($assigned_to_worker_id) || $assigned_to_worker_id <= 0) {
    http_response_code(400);
    echo json_encode(["message" => "Invalid worker ID. Must be a positive integer."]);
    exit();
}

// Optional: Verify if the worker ID exists in tbl_users
// This is a good practice to prevent assigning tasks to non-existent workers.
$stmt_check_worker = $conn->prepare("SELECT id FROM tbl_users WHERE id = ?");
if ($stmt_check_worker === false) {
    http_response_code(500);
    echo json_encode(["message" => "Failed to prepare worker check statement: " . $conn->error]);
    exit();
}
$stmt_check_worker->bind_param("i", $assigned_to_worker_id);
$stmt_check_worker->execute();
$result_check_worker = $stmt_check_worker->get_result();

if ($result_check_worker->num_rows === 0) {
    http_response_code(404);
    echo json_encode(["message" => "Worker with ID " . $assigned_to_worker_id . " not found."]);
    exit();
}
$stmt_check_worker->close();


// --- Insert the new task ---
$date_assigned = date('Y-m-d H:i:s'); // Current timestamp for assignment
$status = 'pending'; // Default status for a new task

$stmt_task = $conn->prepare("INSERT INTO tbl_works (title, description, date_assigned, due_date, status, assigned_to) VALUES (?, ?, ?, ?, ?, ?)");

if ($stmt_task === false) {
    http_response_code(500);
    echo json_encode(["message" => "Failed to prepare task insertion statement: " . $conn->error]);
    exit();
}

$stmt_task->bind_param("sssssi", $title, $description, $date_assigned, $due_date, $status, $assigned_to_worker_id);

if ($stmt_task->execute()) {
    http_response_code(201); // Created
    echo json_encode([
        "message" => "Task assigned successfully to worker ID: " . $assigned_to_worker_id,
        "task_id" => $conn->insert_id,
        "assigned_worker_id" => $assigned_to_worker_id
    ]);
} else {
    http_response_code(500);
    echo json_encode(["message" => "Failed to assign task: " . $stmt_task->error]);
}

$stmt_task->close();
$conn->close();

?>