import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/services/file_service.dart';
import '../../../core/models/file_transfer.dart';

class FileSharingController extends ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  final FileService _fileService = FileService();
  final _uuid = const Uuid();
  
  final Map<String, FileTransfer> _transfers = {};
  final String deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';

  List<FileTransfer> get transfers => _transfers.values.toList();
  
  FileSharingController() {
    _initializeWebSocket();
    _listenToTransfers();
  }

  get availableDevices => null;

  Future<void> _initializeWebSocket() async {
    await _webSocketService.connect('ws://your-websocket-server:8080');
  }

  void _listenToTransfers() {
    _webSocketService.transferStream.listen((transfer) {
      _transfers[transfer.id] = transfer;
      notifyListeners();
    });

    _webSocketService.chunkStream.listen((chunk) async {
      final saveDir = await _fileService.getSaveDirectory();
      await _fileService.saveFileChunk(chunk, saveDir);
    });
  }

  Future<void> sendFiles() async {
    final filePaths = await _fileService.pickFiles();
    
    for (final filePath in filePaths) {
      final transfer = FileTransfer(
        id: _uuid.v4(),
        fileName: filePath.split('/').last,
        filePath: filePath,
        fileSize: await File(filePath).length(),
        timestamp: DateTime.now(),
        senderId: deviceId,
        receiverId: 'broadcast',  // You might want to implement device discovery
      );

      _transfers[transfer.id] = transfer;
      notifyListeners();

      try {
        final chunks = await _fileService.createFileChunks(
          filePath,
          transfer.id,
        );
        
        var chunkIndex = 0;
        final totalChunks = chunks.length;
        
        await _webSocketService.sendFile(
          transfer,
          Stream.fromIterable(chunks).map((chunk) {
            chunkIndex++;
            final progress = chunkIndex / totalChunks;
            
            _transfers[transfer.id] = _transfers[transfer.id]!.copyWith(
              status: TransferStatus.inProgress,
              progress: progress,
            );
            notifyListeners();
            
            return chunk;
          }),
        );

        _transfers[transfer.id] = _transfers[transfer.id]!.copyWith(
          status: TransferStatus.completed,
          progress: 1.0,
        );
        notifyListeners();
      } catch (e) {
        _transfers[transfer.id] = _transfers[transfer.id]!.copyWith(
          status: TransferStatus.failed,
        );
        notifyListeners();
        print('Error sending file: $e');
      }
    }
  }

  void cancelTransfer(String transferId) {
    _webSocketService.cancelTransfer(transferId);
    _transfers[transferId] = _transfers[transferId]!.copyWith(
      status: TransferStatus.cancelled,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  void selectDevice(id) {}
}