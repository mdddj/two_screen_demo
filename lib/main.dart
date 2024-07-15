import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:ldd_winit/api/winit.dart';
import 'package:ldd_winit/ldd_winit.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main(List<String> args) async {
  print("args:${args}");
  WidgetsFlutterBinding.ensureInitialized();
  // 必须加上这一行。

  if (args.isEmpty) {
    await windowManager.ensureInitialized();
  } else {
  }

  winitLibarayInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WindowListener {
  List<LddDisplayInfo> displays = [];

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    Future.microtask(getDisplayInfoList);
  }

  Future<void> getDisplayInfoList() async {
    displays = await lddGetWindowsMonitors();
    setState(() {});
  }

  @override
  void onWindowMoved() {
    windowManager.getPosition().then((value) {
      print(value);
    });
    print('窗口移动');
    super.onWindowMoved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("多屏幕测试")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Wrap(
              children: [
                ...displays.map((e) => Chip(
                    label: Text(e.name +
                        " 大小:${e.width}x${e.height} 刷新率${e.frequency},id:${e.id}")))
              ],
            ),
            TextButton(
                onPressed: () async {
                  final window =
                      await DesktopMultiWindow.createWindow(jsonEncode({
                    'args1': 'Sub window',
                    'args2': 100,
                    'args3': true,
                    'business': 'business_test',
                  }));
                  await window.setFrame(const Offset(1928, 56) & const Size(1800, 1169));
                  await window.show();
                },
                child: const Text("创建一个窗口"))
          ],
        ),
      ),
    );
  }
}
