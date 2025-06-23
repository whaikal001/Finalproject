<?php
header("Access-Control-Allow-Origin: *"); // Allows requests from any origin. For production, specify your client's origin (e.g., "http://localhost:50000").
header("Access-Control-Allow-Methods: GET, POST, OPTIONS"); // Allow necessary HTTP methods
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow necessary headers
header("Access-Control-Max-Age: 86400"); // Cache preflight requests for 24 hours

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // For preflight, just send headers and exit
}
// update_profile.php
// Updates worker profile information in tbl_users.

include 'db_connect.php';

// Get the POST data
$data = json_decode(file_get_contents("php://input"));

$worker_id = $data->id ?? null; // Use 'id' as per frontend Worker model
$full_name = $data->full_name ?? null;
$email = $data->email ?? null; // Email cannot be changed as per requirements, but included for completeness if needed in future
$phone = $data->phone ?? null;
$address = $data->address ?? null;

if ($worker_id === null) {
    http_response_code(400);
    echo json_encode(array("message" => "Worker ID is required."));
    exit();
}

// Build the UPDATE query dynamically based on provided fields
$updateFields = [];
$bindParams = '';
$bindValues = [];

if ($full_name !== null) {
    $updateFields[] = "full_name = ?";
    $bindParams .= 's';
    $bindValues[] = $full_name;
}
if ($phone !== null) {
    $updateFields[] = "phone = ?";
    $bindParams .= 's';
    $bindValues[] = $phone;
}
if ($address !== null) {
    $updateFields[] = "address = ?";
    $bindParams .= 's';
    $bindValues[] = $address;
}

if (empty($updateFields)) {
    http_response_code(400);
    echo json_encode(array("message" => "No fields provided for update."));
    exit();
}

$query = "UPDATE tbl_users SET " . implode(", ", $updateFields) . " WHERE id = ?";
$bindParams .= 'i'; // Add integer type for worker_id
$bindValues[] = $worker_id;

$stmt = $conn->prepare($query);
if ($stmt === false) {
    http_response_code(500);
    echo json_encode(array("message" => "Failed to prepare statement: " . $conn->error));
    exit();
}

// Dynamically bind parameters
$stmt->bind_param($bindParams, ...$bindValues);

// Execute the statement
if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        http_response_code(200); // OK
        echo json_encode(array("message" => "Profile updated successfully! deficiencies and challenges: this section should only contain relevant to the task"));
    } else {
        http_response_code(200); // OK, but no changes made (data was identical)
        echo json_encode(array("message" => "No changes made to the profile or worker not found."));
    }
} else {
    // Check for duplicate email error if email was included in update
    if ($conn->errno == 1062 && in_array('email = ?', $updateFields)) {
        http_response_code(409); // Conflict
        echo json_encode(array("message" => "Email already registered. Please use a different email."));
    } else {
        http_response_code(500); // Internal Server Error
        echo json_encode(array("message" => "Failed to update profile: " . $stmt->error));
    }
}

$stmt->close();
$conn->close();
?>