import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/file_transfer.dart';
import '../../controllers/file_sharing_controller.dart';
import '../../../../shared/widgets/file_item.dart';
import 'devices_dialog.dart';
import 'transfer_stats_sheet.dart';

class AndroidFileSharingView extends StatelessWidget {
  const AndroidFileSharingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FileSharingController>(
      builder: (context, controller, child) {
        final transfers = controller.transfers;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('FileShare'),
            actions: [
              IconButton(
                icon: const Icon(Icons.device_hub),
                onPressed: () {
                  _showDevicesDialog(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  _showTransferStats(context, transfers);
                },
              ),
            ],
          ),
          body: transfers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_upload_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No file transfers yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: controller.sendFiles,
                        icon: const Icon(Icons.add),
                        label: const Text('Send Files'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: transfers.length,
                  itemBuilder: (context, index) {
                    final transfer = transfers[index];
                    return FileItem(
                      transfer: transfer,
                      onCancel: transfer.status == TransferStatus.inProgress
                          ? () => controller.cancelTransfer(transfer.id)
                          : null,
                    );
                  },
                ),
          floatingActionButton: transfers.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: controller.sendFiles,
                  label: const Text('Send Files'),
                  icon: const Icon(Icons.send),
                ),
        );
      },
    );
  }

  void _showDevicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DevicesDialog(),
    );
  }

  void _showTransferStats(BuildContext context, List<FileTransfer> transfers) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TransferStatsSheet(transfers: transfers),
    );
  }
}