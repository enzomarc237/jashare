import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/file_chunk.dart';

class FileService {
  static const int chunkSize = 1024 * 32; // 32KB chunks

  Future<List<String>> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    
    if (result != null) {
      return result.files.map((file) => file.path!).toList();
    }
    return [];
  }

  Future<String> getSaveDirectory() async {
    if (Platform.isMacOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return (await getExternalStorageDirectory())!.path;
    }
  }

  Future<List<FileChunk>> createFileChunks(
    String filePath,
    String transferId,
  ) async {
    final file = File(filePath);
    final fileSize = await file.length();
    final fileName = file.path.split('/').last;
    
    final chunks = <FileChunk>[];
    final totalChunks = (fileSize / chunkSize).ceil();
    
    final fileStream = file.openRead();
    int chunkIndex = 0;
    
    await for (final chunk in fileStream.transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          if (data.length > chunkSize) {
            int offset = 0;
            while (offset < data.length) {
              final end = offset + chunkSize;
              sink.add(data.sublist(
                offset,
                end > data.length ? data.length : end,
              ));
              offset += chunkSize;
            }
          } else {
            sink.add(data);
          }
        },
      ),
    )) {
      chunks.add(FileChunk(
        transferId: transferId,
        chunkIndex: chunkIndex,
        totalChunks: totalChunks,
        data: chunk,
        fileName: fileName,
        fileSize: fileSize,
      ));
      chunkIndex++;
    }
    
    return chunks;
  }

  Future<void> saveFileChunk(FileChunk chunk, String saveDir) async {
    final file = File('$saveDir/${chunk.fileName}');
    
    if (chunk.chunkIndex == 0) {
      await file.writeAsBytes(chunk.data, mode: FileMode.write);
    } else {
      await file.writeAsBytes(chunk.data, mode: FileMode.append);
    }
  }
}