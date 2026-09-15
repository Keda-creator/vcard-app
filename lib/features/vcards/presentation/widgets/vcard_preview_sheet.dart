import 'package:bizkonec/features/vcards/domain/vcard.dart';
import 'package:bizkonec/features/vcards/presentation/vcards_screen.dart';
import 'package:bizkonec/shared/services/metadata_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class VCardPreviewSheet extends ConsumerStatefulWidget {
  final String url;
  final String source;

  const VCardPreviewSheet({super.key, required this.url, required this.source});

  @override
  ConsumerState<VCardPreviewSheet> createState() => _VCardPreviewSheetState();
}

class _VCardPreviewSheetState extends ConsumerState<VCardPreviewSheet> {
  Map<String, String?>? _metadata;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    final meta = await MetadataService.fetchMetadata(widget.url);
    if (mounted) {
      setState(() {
        _metadata = meta;
        _isLoading = false;
      });
    }
  }

  void _save() {
    final vcard = VCard(
      id: const Uuid().v4(),
      url: widget.url,
      title: _metadata?['title'] ?? widget.url,
      description: _metadata?['description'],
      imageUrl: _metadata?['image'],
      domain: _metadata?['domain'] ?? Uri.parse(widget.url).host,
      source: widget.source,
      createdAt: DateTime.now(),
    );

    ref.read(vCardsProvider.notifier).addVCard(vcard);
    Navigator.pop(context, true); // Return true to indicate saved
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text('vCard Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            )
          else ...[
            if (_metadata?['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _metadata!['image']!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              _metadata?['title'] ?? 'Digital Card',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.url,
              style: const TextStyle(color: Colors.blue, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            if (_metadata?['description'] != null)
              Text(
                _metadata!['description']!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save to My vCards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
