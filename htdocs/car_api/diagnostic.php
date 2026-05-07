<?php
header("Content-Type: text/plain");
include 'db_config.php';

echo "=== DATABASE DIAGNOSTIC ===\n\n";

// Test connection
if ($conn->connect_error) {
    echo "Connection Error: " . $conn->connect_error;
    exit;
}

echo "✓ Connection successful\n\n";

// Users table
echo "--- USERS TABLE ---\n";
$result = $conn->query("DESCRIBE users");
if ($result) {
    echo "Columns:\n";
    while ($row = $result->fetch_assoc()) {
        echo "  - {$row['Field']} ({$row['Type']})\n";
    }
} else {
    echo "Error: " . $conn->error . "\n";
}

$result = $conn->query("SELECT * FROM users LIMIT 1");
echo "Sample user:\n";
if ($result && $result->num_rows > 0) {
    $user = $result->fetch_assoc();
    foreach ($user as $key => $val) {
        echo "  $key: $val\n";
    }
} else {
    echo "  No users found\n";
}

echo "\nUser count: ";
$result = $conn->query("SELECT COUNT(*) as cnt FROM users");
$row = $result->fetch_assoc();
echo $row['cnt'] . "\n";

// Vehicles table
echo "\n--- VEHICLES TABLE ---\n";
$result = $conn->query("DESCRIBE vehicles");
if ($result) {
    echo "Columns:\n";
    while ($row = $result->fetch_assoc()) {
        echo "  - {$row['Field']} ({$row['Type']})\n";
    }
} else {
    echo "Error: " . $conn->error . "\n";
}

$result = $conn->query("SELECT * FROM vehicles LIMIT 1");
echo "Sample vehicle:\n";
if ($result && $result->num_rows > 0) {
    $vehicle = $result->fetch_assoc();
    foreach ($vehicle as $key => $val) {
        echo "  $key: $val\n";
    }
} else {
    echo "  No vehicles found\n";
}

echo "\nVehicle count: ";
$result = $conn->query("SELECT COUNT(*) as cnt FROM vehicles");
$row = $result->fetch_assoc();
echo $row['cnt'] . "\n";

// Check each user's vehicle count
echo "\n--- VEHICLES BY USER ---\n";
$result = $conn->query("SELECT user_id, COUNT(*) as cnt FROM vehicles GROUP BY user_id");
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "  user_id {$row['user_id']}: {$row['cnt']} vehicles\n";
    }
} else {
    echo "  No data found\n";
}

$conn->close();
?>
