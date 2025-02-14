class FileTransfer {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final DateTime timestamp;
  final String senderId;
  final String receiverId;
  final TransferStatus status;
  final double progress;

  FileTransfer({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
    this.id = '',
    this.status = TransferStatus.pending,
    this.progress = 0.0,
  });

  FileTransfer copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? fileSize,
    DateTime? timestamp,
    String? senderId,
    String? receiverId,
    TransferStatus? status,
    double? progress,
  }) {
    return FileTransfer(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      timestamp: timestamp ?? this.timestamp,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}

enum TransferStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled
}