<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'db_config.php';

// Get POST data
$email = isset($_POST['email']) ? trim($_POST['email']) : '';
$password = isset($_POST['password']) ? trim($_POST['password']) : '';

// Log incoming request
error_log("LOGIN ATTEMPT: email=$email");

// Validate inputs
if (empty($email) || empty($password)) {
    error_log("LOGIN FAILED: Missing email or password");
    echo json_encode([
        'success' => false,
        'error' => 'Email and password are required'
    ]);
    exit;
}

// Query database for user
$stmt = $conn->prepare("SELECT user_id, full_name, email, password, role FROM users WHERE LOWER(email) = LOWER(?)");
if (!$stmt) {
    error_log("LOGIN FAILED: Database prepare error: " . $conn->error);
    echo json_encode([
        'success' => false,
        'error' => 'Database error: ' . $conn->error
    ]);
    exit;
}

$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    error_log("LOGIN FAILED: No user found with email: $email");
    echo json_encode([
        'success' => false,
        'error' => 'Invalid email or password'
    ]);
    exit;
}

$user = $result->fetch_assoc();
$stmt->close();

error_log("USER FOUND: user_id={$user['user_id']}, role={$user['role']}, email={$user['email']}");

// Validate password (plain text comparison for development)
if ($user['password'] !== $password) {
    error_log("LOGIN FAILED: Password mismatch for user {$user['email']}");
    echo json_encode([
        'success' => false,
        'error' => 'Invalid email or password'
    ]);
    exit;
}

// Successful login
error_log("LOGIN SUCCESS: user_id={$user['user_id']}, role={$user['role']}");
echo json_encode([
    'success' => true,
    'user_id' => intval($user['user_id']),
    'full_name' => $user['full_name'],
    'role' => $user['role'],
    '_debug' => [
        'message' => 'Login successful',
        'role_type' => gettype($user['role']),
        'role_value' => $user['role']
    ]
]);

$conn->close();
?>
