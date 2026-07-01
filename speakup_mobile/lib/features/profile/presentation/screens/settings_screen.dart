import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifPush = true;
  bool _notifEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi', style: TextStyle(color: AppTheme.neutral900, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.neutral900),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Menerima notifikasi langsung di perangkat'),
            value: _notifPush,
            onChanged: (val) => setState(() => _notifPush = val),
            activeColor: AppTheme.primary600,
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Menerima pemberitahuan via email'),
            value: _notifEmail,
            onChanged: (val) => setState(() => _notifEmail = val),
            activeColor: AppTheme.primary600,
          ),
        ],
      ),
    );
  }
}
