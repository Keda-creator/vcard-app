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
            _buildSectionHeader('BizKonec Guide'),
            const SizedBox(height: 16),
            _buildExpansionTile(
              'Digital vCards',
              'Your BizKonec Digital vCard is a modern networking tool. It stores your contact info, social links, and website. You can share it via QR code or NFC instantly. Unlike paper cards, digital cards are eco-friendly and always up-to-date.',
            ),
            _buildExpansionTile(
              'NFC Smart Cards',
              'Our physical NFC products allow you to share your digital profile with a single tap. Simply touch your BizKonec NFC card or tag to a compatible smartphone to instantly transmit your professional details.',
            ),
            _buildExpansionTile(
              'pCard Digitization',
              'The pCard feature lets you scan and save traditional paper business cards. Using our modern document scanner, you can capture both sides of a card, which are then stored in a searchable 3D flip-view gallery.',
            ),
            _buildExpansionTile(
              'How to scan on iPhone',
              'iPhone users should tap the top edge of their device against the NFC product. For iPhone 11 and newer, the background scanner is always active. Ensure the screen is on and the phone is unlocked.',
            ),
            _buildExpansionTile(
              'How to scan on Android',
              'Android users should tap the center-back of their device against the NFC product. Make sure NFC is enabled in your system settings and the device is unlocked.',
            ),
            _buildExpansionTile(
              'Physical Products',
              'We offer a variety of physical networking products including metal cards, PVC cards, and smart tags. Each product is integrated with your digital BizKonec profile for seamless professional interactions.',
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Contact Support'),
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
                    const Icon(Icons.support_agent, size: 48, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'Dedicated Professional Support',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Whether you have questions about your digital vCard, our NFC products, or account management, our team is ready to help.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _launchEmail,
                      icon: const Icon(Icons.email),
                      label: const Text('contact@bizkonec.com'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
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
