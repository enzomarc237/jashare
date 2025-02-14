import 'package:flutter/material.dart';
import '../../../../core/models/file_transfer.dart';

class TransferStatsSheet extends StatelessWidget {
  final List<FileTransfer> transfers;

  const TransferStatsSheet({
    super.key,
    required this.transfers,
  });

  @override
  Widget build(BuildContext context) {
    final completed = transfers.where((t) => t.status == TransferStatus.completed);
    final failed = transfers.where((t) => 
        t.status == TransferStatus.failed || t.status == TransferStatus.cancelled);
    final inProgress = transfers.where((t) => 
        t.status == TransferStatus.inProgress || t.status == TransferStatus.pending);

    final totalSize = transfers.fold<int>(
      0,
      (sum, transfer) => sum + transfer.fileSize,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transfer Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Total Files',
            transfers.length.toString(),
            Icons.folder,
          ),
          _buildStatRow(
            'Completed',
            completed.length.toString(),
            Icons.check_circle,
            Colors.green,
          ),
          _buildStatRow(
            'Failed/Cancelled',
            failed.length.toString(),
            Icons.error,
            Colors.red,
          ),
          _buildStatRow(
            'In Progress',
            inProgress.length.toString(),
            Icons.sync,
            Colors.blue,
          ),
          _buildStatRow(
            'Total Size',
            _formatFileSize(totalSize),
            Icons.data_usage,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}