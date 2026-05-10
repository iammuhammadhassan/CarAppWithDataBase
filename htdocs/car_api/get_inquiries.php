<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'db_config.php';

$seller_id = isset($_GET['seller_id']) ? intval($_GET['seller_id']) : 0;
$buyer_id = isset($_GET['buyer_id']) ? intval($_GET['buyer_id']) : 0;

if ($seller_id <= 0 && $buyer_id <= 0) {
    echo json_encode([]);
    exit;
}

$tableCheck = $conn->query("SHOW TABLES LIKE 'inquiries'");
if (!$tableCheck || $tableCheck->num_rows === 0) {
    echo json_encode([]);
    exit;
}

$columns = [];
$columnResult = $conn->query("DESCRIBE inquiries");
if ($columnResult) {
    while ($row = $columnResult->fetch_assoc()) {
        $columns[] = $row['Field'];
    }
}

$ownerColumn = null;
if ($seller_id > 0 && in_array('seller_id', $columns, true)) {
    $ownerColumn = 'seller_id';
} elseif ($buyer_id > 0 && in_array('buyer_id', $columns, true)) {
    $ownerColumn = 'buyer_id';
} elseif (($seller_id > 0 || $buyer_id > 0) && in_array('user_id', $columns, true)) {
    $ownerColumn = 'user_id';
}

if ($ownerColumn === null) {
    echo json_encode([]);
    exit;
}

$id = $seller_id > 0 ? $seller_id : $buyer_id;
$orderColumn = in_array('created_at', $columns, true)
    ? 'created_at'
    : (in_array('id', $columns, true)
        ? 'id'
        : (in_array('inquiry_id', $columns, true) ? 'inquiry_id' : null));

$sql = $orderColumn
    ? "SELECT * FROM inquiries WHERE $ownerColumn = ? ORDER BY $orderColumn DESC"
    : "SELECT * FROM inquiries WHERE $ownerColumn = ?";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode([]);
    exit;
}

$stmt->bind_param('i', $id);
$stmt->execute();
$result = $stmt->get_result();

$inquiries = [];
while ($row = $result->fetch_assoc()) {
    $inquiries[] = $row;
}

$stmt->close();
$conn->close();

echo json_encode($inquiries);
?>