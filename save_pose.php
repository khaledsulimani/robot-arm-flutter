<?php
header("Access-Control-Allow-Origin: *");
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "robot_arm_db";

// إنشاء الاتصال
$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

$motor1 = $_POST['motor1'];
$motor2 = $_POST['motor2'];
$motor3 = $_POST['motor3'];
$motor4 = $_POST['motor4'];

// حفظ الوضعية في قاعدة البيانات
$sql = "INSERT INTO motor_positions (motor1, motor2, motor3, motor4) 
        VALUES ('$motor1', '$motor2', '$motor3', '$motor4')";

if ($conn->query($sql) === TRUE) {
  echo "New pose saved successfully";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>