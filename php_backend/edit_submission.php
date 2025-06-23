<?php
header("Access-Control-Allow-Origin: *"); // Allows requests from any origin. For production, specify your client's origin (e.g., "http://localhost:50000").
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers
header("Access-Control-Max-Age: 86400"); // Cache preflight requests for 24 hours

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // For preflight, just send headers and exit
}
// edit_submission.php
// Updates the submission_text for a given submission_id.

include 'db_connect.php';

// Get the POST data
$data = json_decode(file_get_contents("php://input"));

$submission_id = $data->submission_id ?? null;
$updated_text = $data->updated_text ?? '';

if ($submission_id === null || empty($updated_text)) {
    http_response_code(400);
    echo json_encode(array("message" => "Submission ID and updated text are required."));
    exit();
}

// Prepare and bind
$stmt = $conn->prepare("UPDATE tbl_submissions SET submission_text = ? WHERE id = ?");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(array("message" => "Failed to prepare statement: " . $conn->error));
    exit();
}
$stmt->bind_param("si", $updated_text, $submission_id);

// Execute the statement
if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        http_response_code(200); // OK
        echo json_encode(array("message" => "Submission updated successfully!"));
    } else {
        http_response_code(200); // OK, but no changes made (data was identical or ID not found)
        echo json_encode(array("message" => "No changes made to submission or submission not found."));
    }
} else {
    http_response_code(500); // Internal Server Error
    echo json_encode(array("message" => "Failed to update submission: " . $stmt->error));
}

$stmt->close();
$conn->close();
?>