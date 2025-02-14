import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig(
    toolbarStyle: NSWindowToolbarStyle.unified,
  );
  await config.apply();
}

void main() {
  _configureMacosWindowUtils();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      key: _globalKey,
      sidebar: Sidebar(
        minWidth: 300,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: 0,
            scrollController: scrollController,
            items: [
              SidebarItem(
                leading: const MacosIcon(CupertinoIcons.home),
                label: const Text('Home'),
              ),
            ],
            onChanged: (int value) {},
          );
        },
      ),
      child: Builder(
        builder: (context) {
          return MacosScaffold(
            toolBar: ToolBar(
              title: Text(widget.title),
              titleWidth: widget.title.length * 16.0,
              enableBlur: true,
              leading: GestureDetector(
                onTap: () => MacosWindowScope.of(context).toggleSidebar(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: MacosIcon(
                    CupertinoIcons.sidebar_left,
                    color: MacosColors.white.withOpacity(0.7),
                  ),
                ),
              ),
              actions: [
                ToolBarIconButton(
                  label: 'Add',
                  icon: const MacosIcon(CupertinoIcons.add),
                  onPressed: _incrementCounter,
                  showLabel: false,
                ),
              ],
            ),
            children: [
              ContentArea(
                builder: (context, scrollController) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'You have pushed the button this many times:',
                        ),
                        Text(
                          '$_counter',
                          style: MacosTheme.of(context).typography.largeTitle,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }
      ),
    );
  }
}
