<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'db_config.php';

$inquiry_id = isset($_POST['inquiry_id']) ? intval($_POST['inquiry_id']) : 0;
$sender_id = isset($_POST['sender_id']) ? intval($_POST['sender_id']) : 0;
$message_text = isset($_POST['message_text']) ? trim($_POST['message_text']) : '';

if ($inquiry_id <= 0 || $sender_id <= 0 || $message_text === '') {
    echo json_encode([
        'success' => false,
        'message' => 'Missing message data'
    ]);
    exit;
}

$tableCheck = $conn->query("SHOW TABLES LIKE 'messages'");
if (!$tableCheck || $tableCheck->num_rows === 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Messages table does not exist'
    ]);
    exit;
}

$columns = [];
$columnResult = $conn->query("DESCRIBE messages");
if ($columnResult) {
    while ($row = $columnResult->fetch_assoc()) {
        $columns[] = $row['Field'];
    }
}

$hasInquiryId = in_array('inquiry_id', $columns, true);
$hasSenderId = in_array('sender_id', $columns, true);
$hasMessageText = in_array('message_text', $columns, true);
$hasSentAt = in_array('sent_at', $columns, true);
$hasCreatedAt = in_array('created_at', $columns, true);

if (!$hasInquiryId || !$hasSenderId || !$hasMessageText) {
    echo json_encode([
        'success' => false,
        'message' => 'Messages table schema is missing required columns'
    ]);
    exit;
}

$sql = $hasSentAt
    ? "INSERT INTO messages (inquiry_id, sender_id, message_text, sent_at) VALUES (?, ?, ?, NOW())"
    : ($hasCreatedAt
        ? "INSERT INTO messages (inquiry_id, sender_id, message_text, created_at) VALUES (?, ?, ?, NOW())"
        : "INSERT INTO messages (inquiry_id, sender_id, message_text) VALUES (?, ?, ?)");

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        'success' => false,
        'message' => 'Database prepare failed: ' . $conn->error
    ]);
    exit;
}

$stmt->bind_param('iis', $inquiry_id, $sender_id, $message_text);

if ($stmt->execute()) {
    echo json_encode([
        'success' => true,
        'message' => 'Message sent successfully'
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Failed to send message: ' . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>