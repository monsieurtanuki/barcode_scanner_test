import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'design_constants.dart';
import 'scan_page.dart';
import 'screen_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// QR View.
class SmoothQRViewMLKit extends StatefulWidget {
  const SmoothQRViewMLKit(this.onScan, this.detectionTimeoutMs);

  final int detectionTimeoutMs;
  final Future<bool> Function(String) onScan;

  @override
  State<StatefulWidget> createState() => _SmoothQRViewMLKitState();
}

class _SmoothQRViewMLKitState extends State<SmoothQRViewMLKit>
    with SingleTickerProviderStateMixin {
  // just 1D formats and ios supported
  static const List<BarcodeFormat> _barcodeFormats = <BarcodeFormat>[
    //BarcodeFormat.code39,
    //BarcodeFormat.code93,
    //BarcodeFormat.code128,
    BarcodeFormat.ean8,
    BarcodeFormat.ean13,
    //BarcodeFormat.itf,
    //BarcodeFormat.upcA,
    //BarcodeFormat.upcE,
  ];

  bool _visible = false;
  bool _isStarted = true;

  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      torchEnabled: false,
      formats: _barcodeFormats,
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: widget.detectionTimeoutMs,
      returnImage: false,
      autoStart: true,
    );
  }

  Future<void> _start() async {
    if (_isStarted) {
      return;
    }
    try {
      await _controller.start();
      _isStarted = true;
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong (start)! $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stop() async {
    if (!_isStarted) {
      return;
    }
    try {
      await _controller.stop();
      _isStarted = false;
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong (stop)! $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double carouselHeight =
            ScanPage.getCarouselHeight(constraints.maxHeight);
        final double scannerHeight = constraints.maxHeight - carouselHeight;
        final double bottomPadding = constraints.maxHeight - scannerHeight;
        final Rect scanWindow = Rect.fromCenter(
          center: Offset(constraints.maxWidth / 2, scannerHeight / 2),
          width: constraints.maxWidth - 2 * MINIMUM_TOUCH_SIZE,
          height: scannerHeight,
        );
        return Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: MobileScanner(
                controller: _controller,
                fit: BoxFit.cover,
                scanWindow: scanWindow,
                errorBuilder: (
                  BuildContext context,
                  MobileScannerException error,
                  Widget? child,
                ) =>
                    ScannerErrorWidget(error: error),
                onDetect: (final BarcodeCapture capture) async {
                  print('onDetect');
                  for (final Barcode barcode in capture.barcodes) {
                    final String? string = barcode.displayValue;
                    if (string != null) {
                      await widget.onScan(string);
                    }
                  }
                },
              ),
            ),
            CustomPaint(
              painter: ScannerOverlay(scanWindow),
            ),
            /*
              const Align(
                alignment: Alignment.topCenter,
                child: ScanHeader(),
              ),
               */
            /*
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: carouselHeight,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/visor_icon.svg',
                    width: 35.0, // TODO different sizes?
                    height: 32.0,
                    package: AppHelper.APP_PACKAGE,
                  ),
                ),
              ),
               */
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: carouselHeight,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      color: Colors.white,
                      icon: ValueListenableBuilder<CameraFacing>(
                        valueListenable: _controller.cameraFacingState,
                        builder: (
                          BuildContext context,
                          CameraFacing state,
                          Widget? child,
                        ) {
                          switch (state) {
                            case CameraFacing.front:
                              return const Icon(Icons.camera_front);
                            case CameraFacing.back:
                              return const Icon(Icons.camera_rear);
                          }
                        },
                      ),
                      //iconSize: 32.0,
                      onPressed: () => _controller.switchCamera(),
                    ),
                    /*
                      IconButton(
                        color: Colors.white,
                        icon: _isStarted
                            ? const Icon(Icons.stop)
                            : const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                        onPressed:
                            _startOrStop, // TODO very interesting, but get rid of it!
                      ),

                       */
                    ValueListenableBuilder<bool?>(
                      valueListenable: _controller.hasTorchState,
                      builder: (
                        BuildContext context,
                        bool? state,
                        Widget? child,
                      ) {
                        if (state != true) {
                          return const SizedBox.shrink();
                        }
                        return IconButton(
                          color: Colors.white,
                          icon: ValueListenableBuilder<TorchState>(
                            valueListenable: _controller.torchState,
                            builder: (
                              BuildContext context,
                              TorchState state,
                              Widget? child,
                            ) {
                              switch (state) {
                                case TorchState.off:
                                  return const Icon(
                                    Icons.flash_off,
                                    color: Colors.white,
                                  );
                                case TorchState.on:
                                  return const Icon(
                                    Icons.flash_on,
                                    color: Colors.white,
                                  );
                              }
                            },
                          ),
                          //iconSize: 32.0,
                          onPressed: () => _controller.toggleTorch(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
/*
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          fit: BoxFit.fill,
          scanWindow: scanWindow,
          errorBuilder: (
            BuildContext context,
            MobileScannerException error,
            Widget? child,
          ) =>
              ScannerErrorWidget(error: error),
          onDetect: (final BarcodeCapture capture) async {
            for (final Barcode barcode in capture.barcodes) {
              final String? string = barcode.displayValue;
              if (string != null) {
                print('found: $string');
                // TODO 0000 put back await widget.onScan(string);
              }
            }
          },
        ),
        CustomPaint(
          painter: ScannerOverlay(scanWindow),
        ),
      ],
    );

 */
  }
}

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({Key? key, required this.error}) : super(key: key);

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Controller not ready.';
        break;
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permission denied';
        break;
      default:
        errorMessage = 'Generic Error';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              error.errorDetails?.message ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcode,
    required this.arguments,
    required this.boxFit,
    required this.capture,
  });

  final BarcodeCapture capture;
  final Barcode barcode;
  final MobileScannerArguments arguments;
  final BoxFit boxFit;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcode.corners == null) return;
    final adjustedSize = applyBoxFit(boxFit, arguments.size, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final ratioWidth =
        (Platform.isIOS ? capture.width! : arguments.size.width) /
            adjustedSize.destination.width;
    final ratioHeight =
        (Platform.isIOS ? capture.height! : arguments.size.height) /
            adjustedSize.destination.height;

    final List<Offset> adjustedOffset = [];
    for (final offset in barcode.corners!) {
      adjustedOffset.add(
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
      );
    }
    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
