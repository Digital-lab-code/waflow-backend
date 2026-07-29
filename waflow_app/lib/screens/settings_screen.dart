import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'pricing_screen.dart';

/// Réglages & compte.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Widget _section(List<Widget> children) => Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(children: children),
      );

  Widget _tile(BuildContext context,
      {required IconData icon,
      required Color iconBg,
      required String label,
      String? value,
      VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () => _snack(context, '$label — bientôt'),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 17, color: Colors.black54),
      ),
      title: Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w700)),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
            ),
            child: const Row(children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: Colors.white24,
                child: Text('MB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
              ),
              SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Mon Business', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('+212 5XX XX XX XX', style: TextStyle(color: Colors.white, fontSize: 12)),
                SizedBox(height: 6),
                Text('Plan Free', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ]),
            ]),
          ),
          _section([
            _tile(context, icon: Icons.star, iconBg: Color(0xFFFFF7ED), label: 'Abonnement & facturation', value: 'Free',
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const PricingScreen()))),
            _tile(context, icon: Icons.person, iconBg: Color(0xFFEFF6FF), label: 'Profil & entreprise'),
            _tile(context, icon: Icons.phone_android, iconBg: Color(0xFFECFDF5), label: 'Numéro WhatsApp lié', value: 'Connecté'),
          ]),
          _section([
            _tile(context, icon: Icons.notifications, iconBg: Color(0xFFFEF3C7), label: 'Notifications'),
            _tile(context, icon: Icons.lock, iconBg: Color(0xFFFEE2E2), label: 'Sécurité & confidentialité'),
            _tile(context, icon: Icons.extension, iconBg: Color(0xFFF5F3FF), label: 'Intégrations & API'),
          ]),
          _section([
            _tile(context, icon: Icons.help_outline, iconBg: Color(0xFFE0F2FE), label: 'Aide & support'),
            _tile(context, icon: Icons.info_outline, iconBg: Color(0xFFF1F5F9), label: 'À propos', value: 'v1.0'),
          ]),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFECACA)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (_) => false),
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          const Center(
              child: Text('WaFlow v1.0 · © 2026',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))),
        ],
      ),
    );
  }
}
