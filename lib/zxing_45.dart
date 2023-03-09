import 'package:barcode_scanner_test/scan_page.dart';
import 'package:barcode_scanner_test/smooth_qr_view_zxing.dart';
import 'package:flutter/material.dart';

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ZXING45 extends StatefulWidget {
  const ZXING45({Key? key}) : super(key: key);

  @override
  State<ZXING45> createState() => _ZXING45State();
}

class _ZXING45State extends State<ZXING45> {
  final List<String> _previousBarcodes = <String>[];

  Future<bool> _onScan(final String barcode) async {
    print('_onScan: $barcode');
    if (_previousBarcodes.isNotEmpty && _previousBarcodes.last == barcode) {
      return false;
    }
    setState(() {
      _previousBarcodes.add(barcode);
    });
    return true;
  }

  // just 1D formats and ios supported
  static const List<BarcodeFormat> _barcodeFormats = <BarcodeFormat>[
    BarcodeFormat.code39,
    BarcodeFormat.code93,
    BarcodeFormat.code128,
    BarcodeFormat.ean8,
    BarcodeFormat.ean13,
    BarcodeFormat.itf,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        body: Stack(
          children: [
            SmoothQRViewZXing(_onScan, _barcodeFormats),
            LayoutBuilder(
              builder: (context, constraints) => Padding(
                padding: EdgeInsets.only(
                  top: constraints.maxHeight -
                      ScanPage.getCarouselHeight(constraints.maxHeight),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * .05,
                  ),
                  child: Container(
                    color: Colors.green,
                    child: _previousBarcodes.isEmpty
                        ? Text('Nothing scanned yet ($_barcodeFormats)')
                        : ListView.builder(
                            itemCount: _previousBarcodes.length,
                            itemBuilder: (context, int i) => Text(
                              _previousBarcodes.reversed.elementAt(i),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
