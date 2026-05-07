<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'db_config.php';

$seller_id = isset($_GET['seller_id']) ? intval($_GET['seller_id']) : 1;

$sql = "SELECT * FROM vehicles WHERE seller_id = $seller_id";
$result = $conn->query($sql);

$cars = [];
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $cars[] = $row;
    }
}

echo json_encode($cars);
?>
