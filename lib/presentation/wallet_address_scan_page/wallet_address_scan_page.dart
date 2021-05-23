import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class WalletAddressScanPage extends StatefulWidget {
  @override
  _WalletAddressScanPageState createState() => _WalletAddressScanPageState();
}

class _WalletAddressScanPageState extends State<WalletAddressScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Scan address code')),
        body: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.blue,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
          ),
        ),
      );

  Future<void> _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    StreamSubscription? subscription;
    subscription = controller.scannedDataStream.listen((event) {
      context.popRoute(event.code);
      subscription?.cancel();
    });
  }
}
