<?php
header("Access-Control-Allow-Origin: *");
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "robot_arm_db";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$pose_id = $_POST['pose_id'];
$sql = "DELETE FROM motor_positions WHERE id = '$pose_id'";

if ($conn->query($sql) === TRUE) {
  echo "Pose removed successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>