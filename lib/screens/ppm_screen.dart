import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ble/ble_controller.dart';

class PpmScreen extends StatelessWidget {
  const PpmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bleController = Provider.of<BleController>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Live PPM Monitor'),
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Formaldehyde Level',
              style: TextStyle(color: Colors.white70, fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              bleController.currentPpm.toStringAsFixed(3),
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'PPM',
              style: TextStyle(color: Colors.greenAccent, fontSize: 30),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  const Text('Status', style: TextStyle(color: Colors.white54)),
                  Text(
                    bleController.currentPpm > 0.1 ? 'DANGER' : 'SAFE',
                    style: TextStyle(
                      color: bleController.currentPpm > 0.1
                          ? Colors.red
                          : Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
