import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/file_transfer.dart';
import '../../controllers/file_sharing_controller.dart';
import '../../../../shared/widgets/file_item.dart';

class MacosFileSharingView extends StatelessWidget {
  const MacosFileSharingView({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: 0,
            onChanged: (i) {},
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.home),
                label: Text('Home'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.settings),
                label: Text('Settings'),
              ),
            ],
          );
        },
      ),
      child: MacosScaffold(
        toolBar: ToolBar(
          title: const Text('FileShare'),
          actions: [
            ToolBarIconButton(
              label: 'Send Files',
              icon: const MacosIcon(CupertinoIcons.add),
              onPressed: () {
                context.read<FileSharingController>().sendFiles();
              },
              showLabel: true,
            ),
          ],
        ),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return Consumer<FileSharingController>(
                builder: (context, controller, child) {
                  final transfers = controller.transfers;
                  
                  if (transfers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No file transfers yet\nClick "Send Files" to start sharing',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}