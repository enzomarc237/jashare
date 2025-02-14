import 'package:flutter/material.dart';
import '../../core/models/file_transfer.dart';

class TransferProgress extends StatelessWidget {
  final FileTransfer transfer;
  final VoidCallback? onCancel;

  const TransferProgress({
    super.key,
    required this.transfer,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: transfer.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  transfer.status == TransferStatus.failed
                      ? Colors.red
                      : Colors.blue,
                ),
              ),
            ),
            if (transfer.status == TransferStatus.inProgress && onCancel != null)
              IconButton(
                icon: const Icon(Icons.cancel, size: 20),
                onPressed: onCancel,
                color: Colors.grey,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${(transfer.progress * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}