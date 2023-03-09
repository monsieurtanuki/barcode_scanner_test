import 'package:barcode_scanner_test/scan_page.dart';
import 'package:barcode_scanner_test/smooth_qr_view_mlkit.dart';
import 'package:flutter/material.dart';

class MLKit45 extends StatefulWidget {
  const MLKit45(this.detectionTimeoutMs, {Key? key}) : super(key: key);

  final int detectionTimeoutMs;

  @override
  State<MLKit45> createState() => _MLKit45State();
}

class _MLKit45State extends State<MLKit45> {
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
            SmoothQRViewMLKit(_onScan, widget.detectionTimeoutMs),
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
                        ? Text(
                            'Nothing scanned yet (with ${widget.detectionTimeoutMs}ms)')
                        : ListView.builder(
                            itemCount: _previousBarcodes.length,
                            itemBuilder: (context, int i) => Text(
                              '${_previousBarcodes.reversed.elementAt(i)}',
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
