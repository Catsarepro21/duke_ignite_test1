import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ble/ble_controller.dart';
import 'config_screen.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bleController = Provider.of<BleController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Scanner'),
        actions: [
          if (bleController.isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: bleController.startScan,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: bleController.devices.isEmpty
                ? const Center(
                    child: Text('No devices found. Tap refresh to scan.'),
                  )
                : ListView.builder(
                    itemCount: bleController.devices.length,
                    itemBuilder: (context, index) {
                      final device = bleController.devices[index];
                      return ListTile(
                        title: Text(device.name),
                        subtitle: Text(device.id),
                        trailing: const Icon(Icons.bluetooth),
                        onTap: () {
                          bleController.connect(device.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ConfigScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: bleController.isScanning
            ? bleController.stopScan
            : bleController.startScan,
        child: Icon(bleController.isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
