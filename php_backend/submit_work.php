<?php
header("Access-Control-Allow-Origin: *"); // Allows requests from any origin. For production, specify your client's origin (e.g., "http://localhost:50000").
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers
header("Access-Control-Max-Age: 86400"); // Cache preflight requests for 24 hours

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // For preflight, just send headers and exit
}
// submit_work.php
// Inserts a new work completion submission into tbl_submissions.

include 'db_connect.php';

// Get the POST data
$data = json_decode(file_get_contents("php://input"));

$work_id = $data->work_id ?? null;
$worker_id = $data->worker_id ?? null;
$submission_text = $data->submission_text ?? '';

if ($work_id === null || $worker_id === null || empty($submission_text)) {
    http_response_code(400);
    echo json_encode(array("message" => "Work ID, Worker ID, and Submission Text are required."));
    exit();
}

// Prepare and bind
$stmt = $conn->prepare("INSERT INTO tbl_submissions (work_id, worker_id, submission_text) VALUES (?, ?, ?)");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(array("message" => "Failed to prepare statement: " . $conn->error));
    exit();
}
$stmt->bind_param("iis", $work_id, $worker_id, $submission_text);

// Execute the statement
if ($stmt->execute()) {
    // Update the status of the related task in tbl_works to 'completed'
    $update_task_stmt = $conn->prepare("UPDATE tbl_works SET status = 'completed' WHERE id = ?");
    if ($update_task_stmt === false) {
        http_response_code(500);
        echo json_encode(array("message" => "Failed to prepare task status update statement: " . $conn->error));
        exit();
    }
    $update_task_stmt->bind_param("i", $work_id);
    $update_task_stmt->execute();
    $update_task_stmt->close();

    http_response_code(201); // Created
    echo json_encode(array("message" => "Work submitted successfully and task status updated to completed!"));
} else {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("message" => "Failed to submit work: " . $stmt->error));
}

$stmt->close();
$conn->close();
?>