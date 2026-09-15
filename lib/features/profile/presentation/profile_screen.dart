import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400'),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Smith',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'john@example.com',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildSection(context, 'Account', [
              _buildTile(context, Icons.person_outline, 'Personal Information'),
              _buildTile(context, Icons.account_balance_wallet_outlined, 'My Account'),
              _buildTile(context, Icons.contact_page_outlined, 'My vCard', onTap: () {
                context.go('/my-vcard');
              }),
            ]),
            _buildSection(context, 'Preferences', [
              _buildTile(context, Icons.notifications_none, 'Notifications'),
              _buildTile(context, Icons.language, 'Language'),
              _buildTile(context, Icons.palette_outlined, 'Appearance'),
            ]),
            _buildSection(context, 'Security', [
              _buildTile(context, Icons.lock_outline, 'Change Password'),
              _buildTile(context, Icons.security, 'Login & Security'),
            ]),
            _buildSection(context, 'Support', [
              _buildTile(context, Icons.help_outline, 'Help & Support', onTap: () {
                context.push('/help-support');
              }),
              _buildTile(context, Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {
                context.push('/privacy-policy');
              }),
              _buildTile(context, Icons.description_outlined, 'Terms & Conditions', onTap: () {
                context.push('/terms-conditions');
              }),
            ]),
            _buildSection(context, 'Danger Zone', [
              _buildTile(context, Icons.logout, 'Log Out', color: Colors.red),
              _buildTile(context, Icons.delete_forever, 'Delete Account', color: Colors.red),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildTile(BuildContext context, IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}
