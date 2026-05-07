<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'db_config.php';

// Read seller_id from POST request
$seller_id = isset($_POST['seller_id']) ? intval($_POST['seller_id']) : 0;

// Get stats
$sql_stats = "SELECT 
    (SELECT COUNT(*) FROM vehicles WHERE seller_id = $seller_id) as active_listings,
    (SELECT SUM(views) FROM vehicles WHERE seller_id = $seller_id) as total_views,
    (SELECT COUNT(*) FROM inquiries WHERE seller_id = $seller_id) as total_inquiries";

$result = $conn->query($sql_stats);
$stats = $result ? $result->fetch_assoc() : [];

// Get vehicles for this seller
$listings = [];
$error = null;
$sql_listings = "SELECT * FROM vehicles WHERE seller_id = $seller_id";
$listings_result = $conn->query($sql_listings);

if ($listings_result === false) {
    $error = $conn->error;
} else {
    while ($row = $listings_result->fetch_assoc()) {
        $listings[] = $row;
    }
}

// Get a sample vehicle
$sample_sql = "SELECT * FROM vehicles LIMIT 1";
$sample_result = $conn->query($sample_sql);
$sample = $sample_result && $sample_result->num_rows > 0 ? $sample_result->fetch_assoc() : null;

$response = [
    "stats" => $stats,
    "listings" => $listings,
    "_debug" => [
        "seller_id" => $seller_id,
        "listings_count" => count($listings),
        "error" => $error,
        "sample_vehicle" => $sample,
        "total_in_db" => isset($stats['active_listings']) ? (int)$stats['active_listings'] : 0
    ]
];

// Debug: verify response structure before encoding
error_log("Response structure: stats=" . count($stats) . ", listings=" . count($listings) . ", sample=" . ($sample ? "exists" : "null"));

$json_output = json_encode($response);
error_log("JSON encode result: " . ($json_output ? "success" : "failed"));
error_log("JSON length: " . strlen($json_output));

echo $json_output;
?>