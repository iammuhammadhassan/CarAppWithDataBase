<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'db_config.php';

$seller_id = isset($_GET['seller_id'])
    ? intval($_GET['seller_id'])
    : (isset($_GET['user_id']) ? intval($_GET['user_id']) : 0);

$ownerCol = null;
$sellerCol = $conn->query("SHOW COLUMNS FROM vehicles LIKE 'seller_id'");
if ($sellerCol && $sellerCol->num_rows > 0) {
    $ownerCol = 'seller_id';
} else {
    $userCol = $conn->query("SHOW COLUMNS FROM vehicles LIKE 'user_id'");
    if ($userCol && $userCol->num_rows > 0) {
        $ownerCol = 'user_id';
    }
}

if ($ownerCol === null) {
    echo json_encode([]);
    exit;
}

$sql = "SELECT * FROM vehicles WHERE $ownerCol = $seller_id";
$result = $conn->query($sql);

$cars = [];
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $cars[] = $row;
    }
}

echo json_encode($cars);
?>
