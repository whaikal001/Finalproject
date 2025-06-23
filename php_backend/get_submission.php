<?php
header("Access-Control-Allow-Origin: *"); // Allows requests from any origin. For production, specify your client's origin (e.g., "http://localhost:50000").
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers
header("Access-Control-Max-Age: 86400"); // Cache preflight requests for 24 hours

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // For preflight, just send headers and exit
}
// get_submissions.php
// Retrieves submission history for a specific worker, joined with task title.

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
$stmt = $conn->prepare("
    SELECT
        ts.id AS submission_id,
        ts.work_id,
        tw.title AS task_title,
        ts.submission_text,
        ts.submitted_at
    FROM
        tbl_submissions ts
    JOIN
        tbl_works tw ON ts.work_id = tw.id
    WHERE
        ts.worker_id = ?
    ORDER BY
        ts.submitted_at DESC
");
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(array("message" => "Failed to prepare statement: " . $conn->error));
    exit();
}
$stmt->bind_param("i", $worker_id);

// Execute the statement
$stmt->execute();
$result = $stmt->get_result();

$submissions = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $submissions[] = $row;
    }
    http_response_code(200);
    echo json_encode(array("message" => "Submissions retrieved successfully.", "submissions" => $submissions));
} else {
    http_response_code(200); // OK, but no content
    echo json_encode(array("message" => "No submissions found for this worker.", "submissions" => []));
}

$stmt->close();
$conn->close();
?>