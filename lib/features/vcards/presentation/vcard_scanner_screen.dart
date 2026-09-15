import 'package:bizkonec/features/vcards/presentation/widgets/vcard_preview_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class VCardScannerScreen extends ConsumerStatefulWidget {
  const VCardScannerScreen({super.key});

  @override
  ConsumerState<VCardScannerScreen> createState() => _VCardScannerScreenState();
}

class _VCardScannerScreenState extends ConsumerState<VCardScannerScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? code = barcodes.first.rawValue;
    if (code != null) {
      final trimmedCode = code.trim();
      if (trimmedCode.startsWith('http')) {
        setState(() => _isProcessing = true);
        _processUrl(trimmedCode, 'qr');
      }
    }
  }

  Future<void> _processUrl(String url, String source) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VCardPreviewSheet(url: url, source: source),
    );
    
    if (saved == true && mounted) {
      Navigator.pop(context); // Close scanner if card was saved
    } else if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        controller: MobileScannerController(
          facing: CameraFacing.back,
          torchEnabled: false,
        ),
        onDetect: _onDetect,
      ),
    );
  }
}
