import 'package:barcode_scanner_test/mlkit_45.dart';
import 'package:barcode_scanner_test/permission_helper.dart';
import 'package:barcode_scanner_test/zxing_45.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

final PermissionListener _permissionListener =
    PermissionListener(permission: Permission.camera);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // The `create` constructor of [ChangeNotifierProvider] takes care of
    // disposing the value.
    ChangeNotifierProvider<T> provide<T extends ChangeNotifier>(T value) =>
        ChangeNotifierProvider<T>(create: (BuildContext context) => value);
    return MultiProvider(
      providers: [
        provide<PermissionListener>(_permissionListener),
      ],
      builder: (_, __) => MaterialApp(
        title: 'Barcode Scanner Test',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barcode Scanner Test v2')),
      body: Center(
        child: Consumer<PermissionListener>(
          builder: (
            BuildContext context,
            PermissionListener listener,
            _,
          ) {
            switch (listener.value.status) {
              case DevicePermissionStatus.checking:
                return CircularProgressIndicator();
              case DevicePermissionStatus.granted:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => MLKit45(5000),
                        ),
                      ),
                      child: Text('MLKit (5000ms) (slow)'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => MLKit45(2000),
                        ),
                      ),
                      child: Text('MLKit (2000ms)'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => MLKit45(250),
                        ),
                      ),
                      child: Text('MLKit (250ms) (fast, default)'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => ZXING45(),
                        ),
                      ),
                      child: Text('ZXING 45'),
                    ),
                  ],
                );
              default:
                return ElevatedButton(
                  onPressed: () => _askPermission(context),
                  child: Text('ask for camera permission'),
                );
            }
          },
        ),
      ),
    );
  }

  Future<void> _askPermission(BuildContext context) =>
      Provider.of<PermissionListener>(
        context,
        listen: false,
      ).askPermission(
        onRationaleNotAvailable: () async {
          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('Camera Permission?'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      );
}
