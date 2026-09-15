import 'package:bizkonec/features/vcards/domain/vcard.dart';
import 'package:bizkonec/features/vcards/domain/vcard_repository.dart';
import 'package:bizkonec/features/vcards/presentation/widgets/vcard_preview_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import 'dart:convert';

final vCardsProvider = AsyncNotifierProvider<VCardsNotifier, List<VCard>>(VCardsNotifier.new);

class VCardsNotifier extends AsyncNotifier<List<VCard>> {
  @override
  Future<List<VCard>> build() {
    return ref.watch(vCardRepositoryProvider).getVCards();
  }

  Future<void> addVCard(VCard vcard) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(vCardRepositoryProvider).saveVCard(vcard);
      return ref.read(vCardRepositoryProvider).getVCards();
    });
  }

  Future<void> removeVCard(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(vCardRepositoryProvider).deleteVCard(id);
      return ref.read(vCardRepositoryProvider).getVCards();
    });
  }
}

class VCardsScreen extends ConsumerStatefulWidget {
  const VCardsScreen({super.key});

  @override
  ConsumerState<VCardsScreen> createState() => _VCardsScreenState();
}

class _VCardsScreenState extends ConsumerState<VCardsScreen> {
  bool _isNfcProcessing = false;

  @override
  Widget build(BuildContext context) {
    final vCardsAsync = ref.watch(vCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('vCards'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: vCardsAsync.when(
        data: (vCards) => vCards.isEmpty ? _buildEmptyState(context) : _buildList(vCards),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        label: const Text('Add vCard'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'No vCards saved yet.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Scan a QR code or NFC card to save a digital vCard.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/scan-vcard'),
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Scan QR'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _scanNfc(context),
                  icon: const Icon(Icons.nfc),
                  label: const Text('Scan NFC'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<VCard> cards) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () async {
              final uri = Uri.parse(card.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: card.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: card.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                card.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                _showDeleteDialog(context, () {
                                  ref.read(vCardsProvider.notifier).removeVCard(card.id);
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (card.description != null)
                          Text(
                            card.description!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          card.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.blue, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Digital Card'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Add vCard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan QR Code'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/scan-vcard');
                },
              ),
              ListTile(
                leading: const Icon(Icons.nfc),
                title: const Text('Scan NFC'),
                onTap: () {
                  Navigator.pop(context);
                  _scanNfc(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _scanNfc(BuildContext context) async {
    if (_isNfcProcessing) return;

    final availability = await NfcManager.instance.checkAvailability();

    if (!context.mounted) return;

    if (availability == NfcAvailability.unsupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NFC is not supported on this device')),
      );
      return;
    }

    if (availability == NfcAvailability.disabled) {
      _showNfcDisabledDialog(context);
      return;
    }

    setState(() => _isNfcProcessing = true);

    // Show scanning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ready to Scan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nfc, size: 60, color: Colors.blue),
            SizedBox(height: 16),
            Text('Hold your phone near the NFC card or tag.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              NfcManager.instance.stopSession();
              if (mounted) setState(() => _isNfcProcessing = false);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    try {
      NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        noPlatformSoundsAndroid: true,
        onDiscovered: (NfcTag tag) async {
          // ignore: invalid_use_of_protected_member
          debugPrint('NFC Tag Discovered: ${tag.data}');
          
          // ignore: invalid_use_of_protected_member
          final dynamic data = tag.data;
          // ignore: invalid_use_of_protected_member
          final dynamic ndef = data.ndef;
          
          if (ndef != null) {
            // ignore: invalid_use_of_protected_member
            final dynamic cachedMessage = ndef.cachedNdefMessage;
            if (cachedMessage != null && cachedMessage.records != null) {
              final List<dynamic> records = cachedMessage.records;
              for (var record in records) {
                // ignore: invalid_use_of_protected_member
                final List<int> payload = record.payload;
                // ignore: invalid_use_of_protected_member
                final List<int> type = record.type;
                
                // URI Record (TNF 1, Type 'U' or 0x55)
                if (type.length == 1 && type[0] == 0x55) {
                  String url = _parseNdefUri(payload);
                  if (url.startsWith('http')) {
                    _successScan(context, url);
                    return;
                  }
                }
              }
            }
          }
          
          // Deep inspection: iterate all keys in tag data for anything that looks like a URL
          try {
            // ignore: invalid_use_of_protected_member
            final String tagString = tag.data.toString();
            final RegExp urlRegExp = RegExp(r'https?://[^\s,\]\}]+');
            final match = urlRegExp.firstMatch(tagString);
            if (match != null) {
              _successScan(context, match.group(0)!);
              return;
            }
          } catch (_) {}
          
          debugPrint('No URL found in tag data structure.');
        },
      ).catchError((e) {
        if (context.mounted) {
          _handleNfcError(context, 'NFC Error: $e');
        }
      });
    } catch (e) {
      if (context.mounted) {
        _handleNfcError(context, 'NFC Error: $e');
      }
    }
  }

  void _successScan(BuildContext context, String url) {
    debugPrint('Found URL: $url');
    NfcManager.instance.stopSession();
    if (!mounted) return;
    
    // Close "Ready to Scan" dialog
    Navigator.of(context, rootNavigator: true).pop();
    _processNfcUrl(context, url);
    if (mounted) setState(() => _isNfcProcessing = false);
  }

  String _parseNdefUri(List<int> payload) {
    if (payload.isEmpty) return '';
    final protocols = [
      '', 'http://www.', 'https://www.', 'http://', 'https://', 'tel:', 'mailto:',
      'ftp://anonymous:anonymous@', 'ftp://ftp.', 'ftps://', 'sftp://', 'smb://',
      'nfs://', 'ftp://', 'dav://', 'news:', 'telnet://', 'imap:', 'rtsp://',
      'urn:', 'pop:', 'sip:', 'sips:', 'tftp:', 'btspp://', 'btl2cap://', 'btgoep://',
      'tcpobex://', 'irdaobex://', 'file://', 'urn:epc:id:', 'urn:epc:tag:',
      'urn:epc:pat:', 'urn:epc:raw:', 'urn:otp:', 'urn:nfc:'
    ];
    int protocolIndex = payload[0];
    String prefix = protocolIndex < protocols.length ? protocols[protocolIndex] : '';
    // Use utf8.decode to support potential special characters and remove null bytes
    String content = utf8.decode(payload.sublist(1), allowMalformed: true).replaceAll('\x00', '');
    return (prefix + content).trim();
  }

  void _processNfcUrl(BuildContext context, String url) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VCardPreviewSheet(url: url, source: 'nfc'),
    );
  }

  void _showNfcDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NFC is Disabled'),
        content: const Text('To scan digital cards, you need to enable NFC in your system settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppSettings.openAppSettings(type: AppSettingsType.nfc);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _handleNfcError(BuildContext context, String message) {
    NfcManager.instance.stopSession();
    if (mounted) setState(() => _isNfcProcessing = false);
    
    if (context.mounted) {
      // If the "Ready to Scan" dialog is still open, close it
      try {
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
      } catch (_) {}
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
