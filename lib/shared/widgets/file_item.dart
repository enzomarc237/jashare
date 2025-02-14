import 'package:flutter/material.dart';
import '../../core/models/file_transfer.dart';
import 'transfer_progress.dart';

class FileItem extends StatelessWidget {
  final FileTransfer transfer;
  final VoidCallback? onCancel;

  const FileItem({
    super.key,
    required this.transfer,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transfer.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatFileSize(transfer.fileSize)} • ${_getStatusText()}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (transfer.status == TransferStatus.inProgress)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TransferProgress(
                  transfer: transfer,
                  onCancel: onCancel,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getStatusIcon() {
    switch (transfer.status) {
      case TransferStatus.pending:
        return Icons.hourglass_empty;
      case TransferStatus.inProgress:
        return Icons.sync;
      case TransferStatus.completed:
        return Icons.check_circle;
      case TransferStatus.failed:
        return Icons.error;
      case TransferStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor() {
    switch (transfer.status) {
      case TransferStatus.pending:
        return Colors.orange;
      case TransferStatus.inProgress:
        return Colors.blue;
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.failed:
      case TransferStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (transfer.status) {
      case TransferStatus.pending:
        return 'Waiting';
      case TransferStatus.inProgress:
        return 'Transferring';
      case TransferStatus.completed:
        return 'Completed';
      case TransferStatus.failed:
        return 'Failed';
      case TransferStatus.cancelled:
        return 'Cancelled';
    }
  }
}