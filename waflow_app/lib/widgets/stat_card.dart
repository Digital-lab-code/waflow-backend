import 'package:flutter/material.dart';

/// Carte de statistique (tableau de bord).
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String value;
  final String label;
  final String? delta;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.value,
    required this.label,
    this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
          if (delta != null) ...[
            const SizedBox(height: 3),
            Text(delta!,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w700)),
          ],
        ],
      ),
    );
  }
}
