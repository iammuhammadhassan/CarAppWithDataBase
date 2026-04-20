<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'db_config.php';

$seller_id = 1; // In a real app, this comes from the logged-in user session

// 1. Get Summary Stats
$sql_stats = "SELECT 
    (SELECT COUNT(*) FROM vehicles WHERE seller_id = $seller_id) as active_listings,
    (SELECT SUM(views) FROM vehicles WHERE seller_id = $seller_id) as total_views,
    (SELECT COUNT(*) FROM inquiries WHERE seller_id = $seller_id) as total_inquiries";

$result = $conn->query($sql_stats);
$stats = $result->fetch_assoc();

// 2. Fetch Active Listings for the list
$sql_listings = "SELECT * FROM vehicles WHERE seller_id = $seller_id";
$listings_result = $conn->query($sql_listings);
$listings = [];
while($row = $listings_result->fetch_assoc()) {
    $listings[] = $row;
}

echo json_encode([
    "stats" => $stats,
    "listings" => $listings
]);
?>