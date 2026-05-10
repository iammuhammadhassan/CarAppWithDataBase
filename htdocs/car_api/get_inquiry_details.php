<?php
header('Content-Type: application/json');

$inquiry_id = isset($_GET['inquiry_id']) ? intval($_GET['inquiry_id']) : 0;

if ($inquiry_id <= 0) {
    echo json_encode(null);
    exit;
}

include 'db_config.php';

try {
    // Try to get inquiry with joined car data
    $stmt = $pdo->prepare('
        SELECT 
            i.id,
            i.vehicle_id,
            COALESCE(i.buyer_id, i.user_id) as buyer_id,
            i.message,
            CONCAT(c.make, \' \', c.model) as car_name,
            COALESCE(i.created_at, i.date) as date
        FROM inquiries i
        LEFT JOIN cars c ON i.vehicle_id = c.id
        WHERE i.id = ?
    ');
    $stmt->execute([$inquiry_id]);
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
