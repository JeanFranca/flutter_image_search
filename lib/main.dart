import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final statuses = [
      Permission.storage,
    ].request();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  final mySearchController = TextEditingController();

  String _searchData = "";
  String _searchText = "";

  void _searchImages() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = "${appDocDir.path}/$_searchText.jpg";
    await Dio().download(
      'https://github.com/guilhermesilveira/flutter-magic/raw/main/$_searchText.jpg',
      savePath);
    
    setState(() {
      _searchData = savePath;
    });
    print(_searchData);
  }

  void _saveImage() async {
    var file = File(_searchData);
    var params = SaveFileDialogParams(sourceFilePath: file.path);
    await FlutterFileDialog.saveFile(params: params);
  }

  void _setSearch() {
    setState(() => _searchText = mySearchController.text);
    _searchImages();
  }

  @override
  void dispose() {
    mySearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    controller: mySearchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Digite sua pesquisa",
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _setSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
            const Text(
              'Você pesquisou por:',
            ),
            Text(
              mySearchController.text,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if(_searchData.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.file(File(_searchData)),
              )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
