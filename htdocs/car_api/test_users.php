<?php
header("Content-Type: application/json");
include 'db_config.php';

$result = $conn->query("SELECT user_id, full_name, email, role FROM users");
$users = [];

if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
}

echo json_encode([
    'total_users' => count($users),
    'users' => $users
]);
?>
