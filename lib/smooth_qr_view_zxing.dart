import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'design_constants.dart';
//import 'package:smooth_app/helpers/app_helper.dart';
//import 'package:smooth_app/helpers/camera_helper.dart';
//import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
//import 'package:smooth_app/pages/scan/scan_header.dart';
import 'scan_page.dart';
//import 'package:smooth_app/themes/constant_icons.dart';
import 'screen_visibility.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// QR View.
class SmoothQRViewZXing extends StatefulWidget {
  const SmoothQRViewZXing(this.onScan, this.barcodeFormats);

  final Future<bool> Function(String) onScan;
  final List<BarcodeFormat> barcodeFormats;

  @override
  State<StatefulWidget> createState() => _SmoothQRViewZXingState();
}

class _SmoothQRViewZXingState extends State<SmoothQRViewZXing> {
  bool _visible = false;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  bool get _showFlipCameraButton => true; // CameraHelper.hasMoreThanOneCamera;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  bottom: ScanPage.getCarouselHeight(constraints.maxHeight)),
              child: QRView(
                key: _qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                    borderColor: Colors.white,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutWidth: constraints.maxWidth - 2 * MINIMUM_TOUCH_SIZE,
                    cutOutHeight: constraints.maxHeight -
                        ScanPage.getCarouselHeight(constraints.maxHeight),
                    cutOutBottomOffset:
                        0 //constraints.maxHeight -ScanPage.getCarouselHeight(constraints.maxHeight),
                    ),
                formatsAllowed: widget.barcodeFormats,
                onPermissionSet: (ctrl, p) =>
                    _onPermissionSet(context, ctrl, p),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: ScanPage.getCarouselHeight(constraints.maxHeight),
                ),
                child: Row(
                  mainAxisAlignment: _showFlipCameraButton
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (_showFlipCameraButton)
                      IconButton(
                        icon: Icon(Icons.camera_front), // TODO
                        color: Colors.white,
                        onPressed: () async {
                          //SmoothHapticFeedback.click();
                          await _controller?.flipCamera();
                          setState(() {});
                        },
                      ),
                    FutureBuilder<bool?>(
                      future: _controller?.getFlashStatus(),
                      builder: (_, final AsyncSnapshot<bool?> snapshot) {
                        final bool? flashOn = snapshot.data;
                        if (flashOn == null) {
                          return Container(); //EMPTY_WIDGET;
                        }
                        return IconButton(
                          icon:
                              Icon(flashOn ? Icons.flash_on : Icons.flash_off),
                          color: Colors.white,
                          onPressed: () async {
                            //SmoothHapticFeedback.click();
                            await _controller?.toggleFlash();
                            // TODO(monsieurtanuki): handle "Unhandled Exception: CameraException(404, This device doesn't support flash)"
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  void _onQRViewCreated(final QRViewController controller) {
    setState(() => _controller = controller);
    controller.scannedDataStream.listen(
      (final Barcode barcode) async {
        final String? string = barcode.code;
        if (string != null) {
          await widget.onScan('$string (${barcode.format})');
        }
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PERMISSION!!!')),
      );
    }
  }
}
