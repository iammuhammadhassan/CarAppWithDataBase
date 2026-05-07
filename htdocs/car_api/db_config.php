<?php
// Database Configuration
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "car_db";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode([
        'success' => false,
        'error' => 'Database connection failed: ' . $conn->connect_error
    ]));
}

// Set charset to utf8
$conn->set_charset("utf8");
?>
