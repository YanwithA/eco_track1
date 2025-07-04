import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late MobileScannerController controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcodeDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcodeValue = barcodes.first.rawValue ?? 'No value';

      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.pop(context, {
        'barcode': barcodeValue,
        'imageUrl': null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        controller: controller,
        onDetect: _handleBarcodeDetection,
      ),
    );
  }
}
