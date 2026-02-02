import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../ble/ble_controller.dart';
import 'ppm_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _ssidController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _ssidController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleController = Provider.of<BleController>(context);
    final isConnected =
        bleController.connectionState == DeviceConnectionState.connected;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connection Status: ${bleController.connectionState.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isConnected ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'WiFi Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _ssidController,
                decoration: const InputDecoration(labelText: 'WiFi SSID'),
              ),
              TextField(
                controller: _passController,
                decoration: const InputDecoration(labelText: 'WiFi Password'),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isConnected
                    ? () {
                        bleController.writeWifiSettings(
                          _ssidController.text,
                          _passController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('WiFi settings sent!')),
                        );
                      }
                    : null,
                child: const Text('Send WiFi Settings'),
              ),
              const Divider(height: 40),
              const Text(
                'Piezo Volume',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: bleController.piezoVolume.toDouble(),
                min: 0,
                max: 255,
                divisions: 255,
                label: bleController.piezoVolume.toString(),
                onChanged: isConnected
                    ? (value) {
                        bleController.writePiezoVolume(value.toInt());
                      }
                    : null,
              ),
              Center(child: Text('Volume: ${bleController.piezoVolume}')),
              const Divider(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: isConnected
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PpmScreen(),
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    'Live Monitor',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
