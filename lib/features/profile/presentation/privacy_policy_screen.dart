import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy for BizKonec',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated: September 2026',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection('1. Introduction', 
              'BizKonec is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application and digital vCard services.'),
            _buildSection('2. Information Collection', 
              'We collect information you provide directly to us, such as your name, contact details, and professional information for your digital vCard. When you scan physical pCards, images are processed locally on your device or uploaded to our secure servers for storage depending on your sync settings.'),
            _buildSection('3. NFC and Data Transmission', 
              'Our NFC products facilitate the transmission of your digital vCard URL. No private data is stored on the NFC tag itself except for your unique profile link. We do not track the precise location of your NFC taps.'),
            _buildSection('4. Use of Information', 
              'We use the collected data to manage your digital profile, facilitate networking interactions, and improve our physical products and digital services. Your professional information is shared only when you explicitly present your QR code or use an NFC-enabled BizKonec product.'),
            _buildSection('5. Data Security', 
              'We implement industry-standard security measures to protect your data from unauthorized access, alteration, or disclosure. All digital vCard transmissions are encrypted via SSL/TLS.'),
            _buildSection('6. Contact Us', 
              'If you have any questions about this Privacy Policy, please contact us at contact@bizkonec.com.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
