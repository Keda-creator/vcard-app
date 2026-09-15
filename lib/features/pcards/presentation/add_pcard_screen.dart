import 'package:bizkonec/features/pcards/domain/physical_card.dart';
import 'package:bizkonec/features/pcards/presentation/pcards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class AddPCardScreen extends ConsumerStatefulWidget {
  final ImageSource? initialSource;
  const AddPCardScreen({super.key, this.initialSource});

  @override
  ConsumerState<AddPCardScreen> createState() => _AddPCardScreenState();
}

class _AddPCardScreenState extends ConsumerState<AddPCardScreen> {
  File? _frontImage;
  File? _backImage;
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  int _step = 0; // 0: Front, 1: Back, 2: Review

  @override
  void initState() {
    super.initState();
    if (widget.initialSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleCapture(widget.initialSource!, true);
      });
    }
  }

  void _saveCard() {
    if (_frontImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture at least the front of the card')),
      );
      return;
    }

    final newCard = PhysicalCard(
      id: const Uuid().v4(),
      name: _nameController.text.isEmpty ? 'Untitled Card' : _nameController.text,
      frontImagePath: _frontImage!.path,
      backImagePath: _backImage?.path,
      notes: _notesController.text,
      createdAt: DateTime.now(),
    );

    ref.read(pCardsProvider.notifier).addCard(newCard);
    Navigator.pop(context);
  }

  Future<void> _handleCapture(ImageSource source, bool isFront) async {
    if (source == ImageSource.camera) {
      await _scanWithDocumentScanner(isFront);
    } else {
      await _pickFromGallery(isFront);
    }
  }

  Future<void> _scanWithDocumentScanner(bool isFront) async {
    try {
      final List<String>? images = await CunningDocumentScanner.getPictures();
      if (images != null && images.isNotEmpty) {
        setState(() {
          if (isFront) {
            _frontImage = File(images.first);
            _step = 1;
          } else {
            _backImage = File(images.first);
            _step = 2;
          }
        });
      }
    } catch (e) {
      debugPrint('Scanner Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document scanner. Falling back to camera.')),
        );
        _pickWithStandardCamera(isFront);
      }
    }
  }

  Future<void> _pickWithStandardCamera(bool isFront) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile != null) {
      final croppedFile = await _cropImage(pickedFile.path);
      if (croppedFile != null) {
        setState(() {
          if (isFront) {
            _frontImage = File(croppedFile.path);
            _step = 1;
          } else {
            _backImage = File(croppedFile.path);
            _step = 2;
          }
        });
      }
    }
  }

  Future<void> _pickFromGallery(bool isFront) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await _cropImage(pickedFile.path);
      if (croppedFile != null) {
        setState(() {
          if (isFront) {
            _frontImage = File(croppedFile.path);
            _step = 1;
          } else {
            _backImage = File(croppedFile.path);
            _step = 2;
          }
        });
      }
    }
  }

  Future<CroppedFile?> _cropImage(String path) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Business Card',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio3x2,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Business Card',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_step == 0 ? 'Capture Front' : _step == 1 ? 'Capture Back' : 'Review Card'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case 0:
        return _buildCaptureStep(true);
      case 1:
        return _buildCaptureStep(false);
      case 2:
        return _buildReviewStep();
      default:
        return Container();
    }
  }

  Widget _buildCaptureStep(bool isFront) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFront ? Icons.document_scanner_outlined : Icons.flip_camera_ios_outlined,
              size: 80,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isFront ? 'Digitize Front' : 'Digitize Back',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            isFront 
              ? 'Position the front of the business card within the frame. Our smart scanner will auto-crop the edges.'
              : 'Optional: Capture the back of the card to see both sides in 3D.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 56),
          ElevatedButton.icon(
            onPressed: () => _handleCapture(ImageSource.camera, isFront),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Start Smart Scanner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _handleCapture(ImageSource.gallery, isFront),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Import from Gallery'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: Colors.blue.withAlpha(50)),
            ),
          ),
          if (!isFront) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() => _step = 2),
              child: const Text('Skip Back Side', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review Digitized Card', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildImageLabel('FRONT'),
          const SizedBox(height: 8),
          _buildImagePreview(_frontImage),
          const SizedBox(height: 24),
          _buildImageLabel('BACK'),
          const SizedBox(height: 8),
          _buildImagePreview(_backImage),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Card Owner / Company Name',
              hintText: 'e.g. John Smith - Tech Solutions',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Notes',
              hintText: 'Where did you meet? Important details...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveCard,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Card to Collection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImageLabel(String label) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
        const Spacer(),
        const Icon(Icons.check_circle, color: Colors.green, size: 16),
      ],
    );
  }

  Widget _buildImagePreview(File? file) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: file != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          : const Center(child: Text('No image captured', style: TextStyle(color: Colors.grey))),
    );
  }
}
