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