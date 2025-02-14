import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/file_transfer.dart';
import '../models/file_chunk.dart';
import '../models/transfer_message.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  final StreamController<FileTransfer> _transferController = 
      StreamController<FileTransfer>.broadcast();
  final StreamController<FileChunk> _chunkController = 
      StreamController<FileChunk>.broadcast();
  
  final Map<String, Completer<void>> _transferCompleters = {};
  final Map<String, int> _receivedChunks = {};

  Stream<FileTransfer> get transferStream => _transferController.stream;
  Stream<FileChunk> get chunkStream => _chunkController.stream;

  Future<void> connect(String url) async {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel.stream.listen(
      _handleMessage,
      onError: (error) {
        print('WebSocket Error: $error');
      },
      onDone: () {
        print('WebSocket Connection Closed');
      },
    );
  }

  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message);
      final transferMessage = TransferMessage.fromJson(data);

      switch (transferMessage.type) {
        case MessageType.chunk:
          _handleChunkMessage(transferMessage);
          break;
        case MessageType.request:
          _handleTransferRequest(transferMessage);
          break;
        case MessageType.complete:
          _handleTransferComplete(transferMessage);
          break;
        case MessageType.cancel:
          _handleTransferCancel(transferMessage);
          break;
        case MessageType.error:
          _handleTransferError(transferMessage);
          break;
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

  void _handleChunkMessage(TransferMessage message) {
    final chunk = FileChunk.fromJson(message.data);
    _chunkController.add(chunk);
    
    // Update received chunks counter
    _receivedChunks[chunk.transferId] = 
        (_receivedChunks[chunk.transferId] ?? 0) + 1;
    
    // Calculate progress
    final progress = _receivedChunks[chunk.transferId]! / chunk.totalChunks;
    
    // Notify transfer progress
    _transferController.add(FileTransfer(
      id: chunk.transferId,
      fileName: chunk.fileName,
      filePath: '',  // Will be set when saving
      fileSize: chunk.fileSize,
      timestamp: DateTime.now(),
      senderId: message.data['senderId'],
      receiverId: message.data['receiverId'],
      status: TransferStatus.inProgress,
      progress: progress,
    ));
  }

  void _handleTransferRequest(TransferMessage message) {
    final transfer = FileTransfer(
      id: message.transferId,
      fileName: message.data['fileName'],
      filePath: message.data['filePath'],
      fileSize: message.data['fileSize'],
      timestamp: DateTime.parse(message.data['timestamp']),
      senderId: message.data['senderId'],
      receiverId: message.data['receiverId'],
      status: TransferStatus.pending,
    );
    _transferController.add(transfer);
  }

  void _handleTransferComplete(TransferMessage message) {
    _transferCompleters[message.transferId]?.complete();
    _receivedChunks.remove(message.transferId);
    
    _transferController.add(FileTransfer(
      id: message.transferId,
      fileName: message.data['fileName'],
      filePath: message.data['filePath'],
      fileSize: message.data['fileSize'],
      timestamp: DateTime.parse(message.data['timestamp']),
      senderId: message.data['senderId'],
      receiverId: message.data['receiverId'],
      status: TransferStatus.completed,
      progress: 1.0,
    ));
  }

  void _handleTransferCancel(TransferMessage message) {
    _transferCompleters[message.transferId]?.completeError('Transfer cancelled');
    _receivedChunks.remove(message.transferId);
    
    _transferController.add(FileTransfer(
      id: message.transferId,
      fileName: message.data['fileName'],
      filePath: message.data['filePath'],
      fileSize: message.data['fileSize'],
      timestamp: DateTime.parse(message.data['timestamp']),
      senderId: message.data['senderId'],
      receiverId: message.data['receiverId'],
      status: TransferStatus.cancelled,
    ));
  }

  void _handleTransferError(TransferMessage message) {
    _transferCompleters[message.transferId]?.completeError(message.data['error']);
    _receivedChunks.remove(message.transferId);
    
    _transferController.add(FileTransfer(
      id: message.transferId,
      fileName: message.data['fileName'],
      filePath: message.data['filePath'],
      fileSize: message.data['fileSize'],
      timestamp: DateTime.parse(message.data['timestamp']),
      senderId: message.data['senderId'],
      receiverId: message.data['receiverId'],
      status: TransferStatus.failed,
    ));
  }

  Future<void> sendFile(FileTransfer transfer, Stream<FileChunk> chunks) async {
    final completer = Completer<void>();
    _transferCompleters[transfer.id] = completer;

    // Send transfer request
    _sendMessage(TransferMessage(
      type: MessageType.request,
      transferId: transfer.id,
      data: {
        'fileName': transfer.fileName,
        'filePath': transfer.filePath,
        'fileSize': transfer.fileSize,
        'timestamp': transfer.timestamp.toIso8601String(),
        'senderId': transfer.senderId,
        'receiverId': transfer.receiverId,
      },
    ));

    // Send chunks
    await for (final chunk in chunks) {
      _sendMessage(TransferMessage(
        type: MessageType.chunk,
        transferId: transfer.id,
        data: chunk.toJson(),
      ));
    }

    // Send complete message
    _sendMessage(TransferMessage(
      type: MessageType.complete,
      transferId: transfer.id,
      data: {
        'fileName': transfer.fileName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));

    return completer.future;
  }

  void _sendMessage(TransferMessage message) {
    _channel.sink.add(jsonEncode(message.toJson()));
  }

  void cancelTransfer(String transferId) {
    _sendMessage(TransferMessage(
      type: MessageType.cancel,
      transferId: transferId,
      data: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));
  }

  void dispose() {
    _channel.sink.close();
    _transferController.close();
    _chunkController.close();
  }
}