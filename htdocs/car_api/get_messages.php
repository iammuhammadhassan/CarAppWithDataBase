<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'db_config.php';

$inquiry_id = isset($_GET['inquiry_id']) ? intval($_GET['inquiry_id']) : 0;
if ($inquiry_id <= 0) {
    echo json_encode([]);
    exit;
}

$tableCheck = $conn->query("SHOW TABLES LIKE 'messages'");
if (!$tableCheck || $tableCheck->num_rows === 0) {
    echo json_encode([]);
    exit;
}

$columns = [];
$columnResult = $conn->query("DESCRIBE messages");
if ($columnResult) {
    while ($row = $columnResult->fetch_assoc()) {
        $columns[] = $row['Field'];
    }
}

$inquiryColumn = in_array('inquiry_id', $columns, true) ? 'inquiry_id' : null;
if ($inquiryColumn === null) {
    echo json_encode([]);
    exit;
}

$orderColumn = in_array('sent_at', $columns, true)
    ? 'sent_at'
    : (in_array('created_at', $columns, true) ? 'created_at' : 'id');

$sql = "SELECT * FROM messages WHERE $inquiryColumn = ? ORDER BY $orderColumn ASC";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([]);
    exit;
}

$stmt->bind_param('i', $inquiry_id);
$stmt->execute();
$result = $stmt->get_result();

$messages = [];
while ($row = $result->fetch_assoc()) {
    $messages[] = $row;
}

$stmt->close();
$conn->close();

echo json_encode($messages);
?>