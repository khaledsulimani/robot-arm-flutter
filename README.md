# Robot Arm Control Panel

A complete solution for controlling and saving robot arm poses using a **Flutter app** and a **PHP/MySQL backend**.

---

## 📱 Features

- **4 Motor Sliders:** Set each servo angle (0–180°).
- **Save Pose:** Store the current pose in a MySQL database.
- **Reset:** Reset all sliders to 0.
- **Run:** Load a pose into the sliders (add Bluetooth/serial code if needed).
- **Saved Poses List:** View, play (load), and delete saved poses.
- **Backend:** PHP scripts for saving, loading, and deleting poses.
- **Database:** MySQL table for storing poses.

---
## 📱 Flutter App

- **Sliders** for 4 motors (0–180 degrees)
- **Save Pose** button to store current pose in the database
- **Reset** and **Run** buttons
- **Saved Poses** list with play (load) and delete buttons
- Connects to PHP backend via HTTP

---

## 🗄️ Backend (PHP + MySQL)

- **Database:** `robot_arm_db`
- **Table:** `motor_positions`
- **API Endpoints:**  
  - `save_pose.php` — Save a new pose  
  - `load_positions.php` — Load all poses  
  - `remove_position.php` — Delete a pose

---

## 📂 File Structure
robot-arm-control-panel/ │ 
  ├── save_pose.php 
    
  ├── load_positions.php 
    
  ├── remove_position.php │ 
    
        └── (Flutter project) 
          
                  └── lib/ 
                    
                    └── main.dart
                      



---

## 🛠️ Setup

### 1. MySQL Database

Create the database and table:

```sql
CREATE DATABASE robot_arm_db;
USE robot_arm_db;

CREATE TABLE motor_positions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    motor1 INT NOT NULL,
    motor2 INT NOT NULL,
    motor3 INT NOT NULL,
    motor4 INT NOT NULL
);

```

### 2. save position:

create save_pose.php:

```php
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

$motor1 = $_POST['motor1'];
$motor2 = $_POST['motor2'];
$motor3 = $_POST['motor3'];
$motor4 = $_POST['motor4'];

$stmt = $conn->prepare("INSERT INTO motor_positions (motor1, motor2, motor3, motor4) VALUES (?, ?, ?, ?)");
$stmt->bind_param("iiii", $motor1, $motor2, $motor3, $motor4);

if ($stmt->execute()) {
  echo "New pose saved successfully";
} else {
  echo "Error: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>
```

### 3. load position

create load_positions.php:

```php
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

$sql = "SELECT * FROM motor_positions";
$result = $conn->query($sql);

$poses = array();
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
    $poses[] = $row;
  }
  echo json_encode($poses);
} else {
  echo json_encode([]);
}

$conn->close();
?>
```

### 4. remove position

create remove_positions.php:

```php
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

$stmt = $conn->prepare("DELETE FROM motor_positions WHERE id = ?");
$stmt->bind_param("i", $pose_id);

if ($stmt->execute()) {
  echo "Pose removed successfully";
} else {
  echo "Error: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>
```

### 5. flutter dart file

create main.dart

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RobotArmControl(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RobotArmControl extends StatefulWidget {
  const RobotArmControl({Key? key}) : super(key: key);

  @override
  State<RobotArmControl> createState() => _RobotArmControlState();
}

class _RobotArmControlState extends State<RobotArmControl> {
  double motor1 = 0, motor2 = 0, motor3 = 0, motor4 = 0;
  List<Map<String, dynamic>> poses = [];

  final String baseUrl = 'http://192.168.1.13/robot-arm-control-panel';

  @override
  void initState() {
    super.initState();
    loadPositions();
  }

  Future<void> savePose() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save_pose.php'),
        body: {
          'motor1': motor1.toInt().toString(),
          'motor2': motor2.toInt().toString(),
          'motor3': motor3.toInt().toString(),
          'motor4': motor4.toInt().toString(),
        },
      );
      if (response.statusCode == 200) {
        await loadPositions();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> loadPositions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/load_positions.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            poses = List<Map<String, dynamic>>.from(data);
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> removePose(String poseId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/remove_position.php'),
        body: {'pose_id': poseId},
      );
      if (response.statusCode == 200) {
        await loadPositions();
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void resetMotors() {
    setState(() {
      motor1 = 0;
      motor2 = 0;
      motor3 = 0;
      motor4 = 0;
    });
  }

  void runPose(Map<String, dynamic> pose) {
    setState(() {
      motor1 = double.tryParse(pose['motor1'].toString()) ?? 0;
      motor2 = double.tryParse(pose['motor2'].toString()) ?? 0;
      motor3 = double.tryParse(pose['motor3'].toString()) ?? 0;
      motor4 = double.tryParse(pose['motor4'].toString()) ?? 0;
    });
    // Add Bluetooth send here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1FA),
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: const Text('Robot Arm Control Panel'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _motorSlider('Motor 1', motor1, (v) => setState(() => motor1 = v)),
              _motorSlider('Motor 2', motor2, (v) => setState(() => motor2 = v)),
              _motorSlider('Motor 3', motor3, (v) => setState(() => motor3 = v)),
              _motorSlider('Motor 4', motor4, (v) => setState(() => motor4 = v)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _roundedButton('Reset', resetMotors, Colors.grey[300]!),
                  _roundedButton('Save Pose', savePose, Colors.purple[200]!),
                  _roundedButton('Run', () {}, Colors.purple[100]!),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Saved Poses:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...poses.asMap().entries.map((entry) {
                final idx = entry.key;
                final pose = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      'Pose ${idx + 1}: ${pose['motor1']}, ${pose['motor2']}, ${pose['motor3']}, ${pose['motor4']}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => runPose(pose),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removePose(pose['id'].toString()),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _motorSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toInt()}'),
        Slider(
          value: value,
          min: 0,
          max: 180,
          divisions: 180,
          label: value.toInt().toString(),
          activeColor: Colors.purple,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _roundedButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

### 6. yaml defult:

dosent need to create it is in flutter just add this dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.1
```
---

## 📸 Project Results

### *front-end*:  
<img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/43c4f933-3013-4781-909e-cce9be543913" />





### *simple video*:

https://github.com/user-attachments/assets/ba29195a-1642-4e06-9c20-066be1d51eae





### *back-end*:

<img width="3438" height="1201" alt="image" src="https://github.com/user-attachments/assets/54add168-c60c-4b21-b753-0b152c7cf404" />


---

## 🧑‍💻 Author
- **khaled mahmoud sulaimani** – [@khaledsulimani](https://github.com/khaledsulimani)

---
**Enjoy controlling your robot
