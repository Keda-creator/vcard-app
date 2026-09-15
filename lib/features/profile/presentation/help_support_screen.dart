import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'contact@bizkonec.com',
      queryParameters: {
        'subject': 'BizKonec Support Request',
      },
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Frequently Asked Questions'),
            const SizedBox(height: 16),
            _buildExpansionTile(
              'What is a vCard?',
              'A vCard is a digital business card. It allows you to share your contact information, social media links, and website instantly through a QR code or NFC tag.',
            ),
            _buildExpansionTile(
              'What are pCards?',
              'pCards (Physical Cards) are digital versions of your paper business cards. You can photograph and crop your physical cards to store them safely in the app with a 3D flip view.',
            ),
            _buildExpansionTile(
              'How to scan NFC on iPhone?',
              'To scan an NFC card on an iPhone, hold the top of your iPhone (near the front camera) close to the NFC tag or card. iPhone 11 and newer models have the scanner always active, while older models may need to open the scanner manually from the Control Center.',
            ),
            _buildExpansionTile(
              'How to scan NFC on Android?',
              'For most Android devices, the NFC antenna is located in the middle of the back of the phone. Ensure NFC is enabled in your system settings, then tap the center back of your device against the card.',
            ),
             _buildExpansionTile(
              'NFC Scanning Tips',
              '• Ensure your phone is unlocked.\n• If you have a very thick phone case, try removing it as it may block the signal.\n• Hold the device still for 1-2 seconds until you feel a vibration.\n• For QR codes, ensure there is sufficient lighting.',
            ),
            _buildExpansionTile(
              'How do I share my own vCard?',
              'Navigate to the "My vCard" tab. From there, you can present your digital card to others. They can scan your QR code or you can share your unique link directly.',
            ),
            _buildExpansionTile(
              'Organizing your Cards',
              'You can find all your digitized paper cards in the "pCards" tab and all received digital profiles in the "vCards" tab. Both sections allow you to search through your collection easily.',
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Contact Us'),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              color: Colors.blue.withAlpha(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.withAlpha(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.email_outlined, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Need more help?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Our team is here to assist you with any questions or technical issues.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _launchEmail,
                      icon: const Icon(Icons.send),
                      label: const Text('Email contact@bizkonec.com'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(30)),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(
            content,
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }
}
