import 'dart:async';
import 'dart:io';

import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:device_orientation/device_orientation.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: StreamPreviewWidget());
  }
}

class StreamPreviewWidget extends StatefulWidget {
  const StreamPreviewWidget({Key? key}) : super(key: key);

  @override
  State<StreamPreviewWidget> createState() => _StreamPreviewWidgetState();
}

class _StreamPreviewWidgetState extends State<StreamPreviewWidget> {
  StreamSubscription? _orientationSubscription;
  bool _shouldLockPortrait = true;
  DeviceOrientation _deviceOrientation = DeviceOrientation.portraitUp;
  late LiveStreamController _controller;

  @override
  void initState() {
    _controller = LiveStreamController(
      onConnectionFailed: (_) {
        debugPrint('Stream connecton failed');
      },
      onConnectionSuccess: () {
        debugPrint('Stream connected');
      },
      onDisconnection: () {
        debugPrint('Server disconnect');
      },
    );
    _controller.create(
      initialAudioConfig: AudioConfig(),
      initialVideoConfig: VideoConfig.withDefaultBitrate(),
    );

    Future.delayed(Duration.zero, () {
      _forceOrientation(
          shouldLockPortrait:
              MediaQuery.of(context).orientation == Orientation.portrait);
    });
    _orientationSubscription = deviceOrientation$.listen((orientation) {
      _deviceOrientation = orientation.fixed;
      print('Device orientation: $_deviceOrientation');
      _forceOrientation();
    });
    super.initState();
  }

  @override
  void dispose() {
    _orientationSubscription?.cancel();
    _restoreOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CameraPreview(controller: _controller),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.crop_rotate),
        onPressed: () {
          _forceOrientation(shouldLockPortrait: !_shouldLockPortrait);
        },
      ),
    );
  }

  Future<void> _forceOrientation({bool? shouldLockPortrait}) async {
    if (shouldLockPortrait != null) {
      _shouldLockPortrait = shouldLockPortrait;
      // force orientation button was pressed
      // check if we are in correct device orientation
      if ((shouldLockPortrait && _deviceOrientation.isPortrait) ||
          !(shouldLockPortrait || _deviceOrientation.isPortrait)) {
        await SystemChrome.setPreferredOrientations([
          _deviceOrientation,
        ]);
        print('Forcing orientation1: $_deviceOrientation');
      } else {
        // use defaults
        await SystemChrome.setPreferredOrientations([
          shouldLockPortrait
              ? DeviceOrientation.portraitUp
              : DeviceOrientation.landscapeRight,
        ]);
        print(
            'Forcing orientation2: ${shouldLockPortrait ? DeviceOrientation.portraitUp : DeviceOrientation.landscapeRight}');
      }
    } else {
      // native orientation changed, check if we are in correct lock orientation
      // otherwise ignore
      if ((_shouldLockPortrait && _deviceOrientation.isPortrait) ||
          !(_shouldLockPortrait || _deviceOrientation.isPortrait)) {
        await SystemChrome.setPreferredOrientations([
          _deviceOrientation,
        ]);
        print('Forcing orientation3: $_deviceOrientation');
      }
    }
  }

  Future<void> _restoreOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

extension OrientationExtensions on DeviceOrientation {
  bool get isPortrait =>
      this == DeviceOrientation.portraitDown ||
      this == DeviceOrientation.portraitUp;

  DeviceOrientation get fixed {
    if (Platform.isIOS) return this;
    // Landscape is swapped on Android??
    switch (this) {
      case DeviceOrientation.portraitUp:
      case DeviceOrientation.portraitDown:
        return this;

      case DeviceOrientation.landscapeLeft:
        return DeviceOrientation.landscapeRight;
      case DeviceOrientation.landscapeRight:
        return DeviceOrientation.landscapeLeft;
    }
  }
}
