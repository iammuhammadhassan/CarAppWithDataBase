<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'db_config.php';

$vehicle_id = isset($_POST['vehicle_id']) ? intval($_POST['vehicle_id']) : 0;
$seller_id = isset($_POST['seller_id']) ? intval($_POST['seller_id']) : 0;
$buyer_id = isset($_POST['buyer_id']) ? intval($_POST['buyer_id']) : 0;

if ($vehicle_id <= 0 || $seller_id <= 0 || $buyer_id <= 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing or invalid inquiry data'
    ]);
    exit;
}

$tableCheck = $conn->query("SHOW TABLES LIKE 'inquiries'");
if (!$tableCheck || $tableCheck->num_rows === 0) {
    echo json_encode([
        'success' => false,
        'message' => 'Inquiries table does not exist'
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

$hasVehicleId = in_array('vehicle_id', $columns, true);
$hasSellerId = in_array('seller_id', $columns, true);
$hasBuyerId = in_array('buyer_id', $columns, true);
$hasCreatedAt = in_array('created_at', $columns, true);

if (!$hasVehicleId || !$hasSellerId || !$hasBuyerId) {
    echo json_encode([
        'success' => false,
        'message' => 'Inquiries table schema is missing required columns'
    ]);
    exit;
}

$sql = $hasCreatedAt
    ? "INSERT INTO inquiries (vehicle_id, seller_id, buyer_id, created_at) VALUES (?, ?, ?, NOW())"
    : "INSERT INTO inquiries (vehicle_id, seller_id, buyer_id) VALUES (?, ?, ?)";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode([
        'success' => false,
        'message' => 'Database prepare failed: ' . $conn->error
    ]);
    exit;
}

$stmt->bind_param('iii', $vehicle_id, $seller_id, $buyer_id);

if ($stmt->execute()) {
    echo json_encode([
        'success' => true,
        'message' => 'Inquiry sent successfully'
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Failed to save inquiry: ' . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>