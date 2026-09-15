import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'BizKonec Terms and Conditions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last Updated: September 2026',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection('1. Acceptance of Terms', 
              'By accessing or using the BizKonec app and our physical products (NFC cards, tags, etc.), you agree to be bound by these Terms and Conditions.'),
            _buildSection('2. Digital vCard Services', 
              'BizKonec provides a platform for creating and sharing digital business cards. You are responsible for maintaining the accuracy of the information provided on your vCard profile.'),
            _buildSection('3. Physical Products and NFC', 
              'The BizKonec NFC cards are provided as networking tools. While we ensure the highest quality of our physical products, we are not responsible for damage caused by improper use or wear and tear over time.'),
            _buildSection('4. User Conduct', 
              'You agree not to use our digital products to share illegal, offensive, or infringing content. BizKonec reserves the right to suspend accounts that violate our usage policies.'),
            _buildSection('5. Intellectual Property', 
              'All software, design, and branding elements associated with BizKonec are the property of ATM BizKonec. You may not reproduce or redistribute any part of our digital products without authorization.'),
            _buildSection('6. Limitation of Liability', 
              'BizKonec shall not be liable for any indirect, incidental, or consequential damages resulting from the use or inability to use our digital or physical networking products.'),
            _buildSection('7. Support', 
              'For any disputes or support requirements regarding our terms, please email contact@bizkonec.com.'),
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
