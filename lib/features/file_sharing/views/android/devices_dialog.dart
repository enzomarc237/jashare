import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/file_sharing_controller.dart';

class DevicesDialog extends StatelessWidget {
  const DevicesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Available Devices'),
      content: SizedBox(
        width: double.maxFinite,
        child: Consumer<FileSharingController>(
          builder: (context, controller, child) {
            final devices = controller.availableDevices;
            
            if (devices.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Searching for devices...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: Icon(
                    device.platform == 'android'
                        ? Icons.phone_android
                        : Icons.desktop_mac,
                  ),
                  title: Text(device.name),
                  subtitle: Text(device.id),
                  onTap: () {
                    controller.selectDevice(device.id);
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}