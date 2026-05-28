import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final name = user?.name.trim().isNotEmpty == true ? user!.name.trim() : 'Guest User';
    final email = user?.email.trim().isNotEmpty == true ? user!.email.trim() : 'No email added';
    final phone = user?.phone?.trim().isNotEmpty == true ? user!.phone!.trim() : 'No phone added';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppColors.bg,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecoration(),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundImage: user?.photo_url == null ? null : NetworkImage(user!.photo_url!),
                      child: user?.photo_url == null ? const Icon(Icons.person, size: 34) : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: AppColors.primary, size: 16),
                            ],
                          ),
                          Text(email, style: const TextStyle(color: AppColors.muted), overflow: TextOverflow.ellipsis),
                          Text(phone, style: const TextStyle(color: AppColors.muted, fontSize: 12), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Verify(Icons.verified_user, 'Verified'),
                    _Verify(Icons.email_outlined, 'Email'),
                    _Verify(Icons.phone, 'Phone'),
                    _Verify(Icons.shield, 'Safe'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Information', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _InfoRow(icon: Icons.person_outline, label: 'Name', value: name),
                _InfoRow(icon: Icons.email_outlined, label: 'Email', value: email),
                _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: phone),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            SizedBox(width: 72, child: Text(label, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700))),
            Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
          ],
        ),
      );
}

class _Verify extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Verify(this.icon, this.title);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: Colors.green),
          Text(title, style: const TextStyle(color: Colors.green, fontSize: 11)),
        ],
      );
}