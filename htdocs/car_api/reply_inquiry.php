<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'db_config.php';

$inquiry_id = isset($_POST['inquiry_id']) ? intval($_POST['inquiry_id']) : 0;
$reply = isset($_POST['reply']) ? trim($_POST['reply']) : '';

if ($inquiry_id <= 0 || $reply === '') {
    echo json_encode([
        'success' => false,
        'message' => 'Missing inquiry reply data'
    ]);
    exit;
}

$columns = [];
$columnResult = $conn->query("DESCRIBE inquiries");
if ($columnResult) {
    while ($row = $columnResult->fetch_assoc()) {
        $columns[] = $row['Field'];
    }
}

$idColumn = in_array('inquiry_id', $columns, true) ? 'inquiry_id' : (in_array('id', $columns, true) ? 'id' : null);
$replyColumn = in_array('reply', $columns, true) ? 'reply' : (in_array('seller_reply', $columns, true) ? 'seller_reply' : (in_array('reply_message', $columns, true) ? 'reply_message' : null));
$replyAtColumn = in_array('reply_at', $columns, true) ? 'reply_at' : (in_array('replied_at', $columns, true) ? 'replied_at' : null);

if ($idColumn === null || $replyColumn === null) {
    echo json_encode([
        'success' => false,
        'message' => 'Inquiry table schema does not support replies'
    ]);
    exit;
}

$sql = $replyAtColumn
    ? "UPDATE inquiries SET $replyColumn = ?, $replyAtColumn = NOW() WHERE $idColumn = ?"
    : "UPDATE inquiries SET $replyColumn = ? WHERE $idColumn = ?";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([
        'success' => false,
        'message' => 'Database prepare failed: ' . $conn->error
    ]);
    exit;
}

$stmt->bind_param('si', $reply, $inquiry_id);

if ($stmt->execute() && $stmt->affected_rows >= 0) {
    echo json_encode([
        'success' => true,
        'message' => 'Reply saved successfully'
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Failed to save reply: ' . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>