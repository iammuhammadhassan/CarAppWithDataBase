<?php
header('Content-Type: application/json');

$vehicle_id = isset($_GET['vehicle_id']) ? intval($_GET['vehicle_id']) : 0;

if ($vehicle_id <= 0) {
    echo json_encode(null);
    exit;
}

include 'db_config.php';

try {
    $stmt = $pdo->prepare('
        SELECT id as vehicle_id, make, model, price, location, image_url, image_url_2, image_url_3,
               year_produced, mileage, fuel_type, transmission, is_inspected, views, seller_id
        FROM cars
        WHERE id = ?
    ');
    $stmt->execute([$vehicle_id]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode($result);
    } else {
        echo json_encode(null);
    }
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
?>
