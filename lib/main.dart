import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:macos_ui/macos_ui.dart';
import 'features/file_sharing/controllers/file_sharing_controller.dart';
import 'features/file_sharing/views/macos/macos_file_sharing_view.dart';
import 'features/file_sharing/views/android/android_file_sharing_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FileSharingController(),
      child: const JaShare(),
    ),
  );
}

class JaShare extends StatelessWidget {
  const JaShare({super.key});

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.macOS) {
      return MacosApp(
        title: 'FileShare',
        theme: MacosThemeData.light(),
        darkTheme: MacosThemeData.dark(),
        home: const MacosFileSharingView(),
      );
    }
    
    return MaterialApp(
      title: 'FileShare',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AndroidFileSharingView(),
    );
  }
}