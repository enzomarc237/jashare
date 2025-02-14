class FileChunk {
  final String transferId;
  final int chunkIndex;
  final int totalChunks;
  final List<int> data;
  final String fileName;
  final int fileSize;

  FileChunk({
    required this.transferId,
    required this.chunkIndex,
    required this.totalChunks,
    required this.data,
    required this.fileName,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'transferId': transferId,
      'chunkIndex': chunkIndex,
      'totalChunks': totalChunks,
      'data': data,
      'fileName': fileName,
      'fileSize': fileSize,
    };
  }

  factory FileChunk.fromJson(Map<String, dynamic> json) {
    return FileChunk(
      transferId: json['transferId'],
      chunkIndex: json['chunkIndex'],
      totalChunks: json['totalChunks'],
      data: List<int>.from(json['data']),
      fileName: json['fileName'],
      fileSize: json['fileSize'],
    );
  }
}