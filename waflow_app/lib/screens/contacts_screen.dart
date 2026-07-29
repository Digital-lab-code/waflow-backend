import 'package:flutter/material.dart';

class _Contact {
  final String name, initials, phone;
  final Color color;
  final String tag;
  final Color tagColor;
  final Color tagBg;
  const _Contact(this.name, this.initials, this.phone, this.color,
      this.tag, this.tagColor, this.tagBg);
}

/// Carnet de contacts / CRM (données de démo).
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      _Contact('Sara Klein', 'SK', '+212 6 12 34 56 78', const Color(0xFF3B82F6), 'VIP', const Color(0xFFB45309), const Color(0xFFFEF3C7)),
      _Contact('Ahmed Benali', 'AB', '+212 6 66 11 22 33', const Color(0xFFF59E0B), 'Client', const Color(0xFF1D4ED8), const Color(0xFFDBEAFE)),
      _Contact('Marie Evrard', 'ME', '+33 6 78 90 12 34', const Color(0xFFEF4444), 'Client', const Color(0xFF1D4ED8), const Color(0xFFDBEAFE)),
      _Contact('Youssef Lahlou', 'YL', '+212 5 22 44 55 66', const Color(0xFF8B5CF6), 'Prospect', const Color(0xFF7E22CE), const Color(0xFFE9D5FF)),
      _Contact('Fatima Tahiri', 'FT', '+212 6 55 99 88 77', const Color(0xFF10B981), 'VIP', const Color(0xFFB45309), const Color(0xFFFEF3C7)),
      _Contact('Karim Drissi', 'KD', '+212 6 14 25 36 47', const Color(0xFF0EA5E9), 'Prospect', const Color(0xFF7E22CE), const Color(0xFFE9D5FF)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts'), actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.person_add_alt)),
      ]),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              children: ['Tous · 856', 'VIP', 'Clients', 'Prospects']
                  .map((t) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: t.startsWith('Tous')
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(t,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: t.startsWith('Tous') ? Colors.white : const Color(0xFF64748B))),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
              itemBuilder: (context, i) {
                final c = contacts[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: c.color,
                    child: Text(c.initials,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  title: Row(
                    children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: c.tagBg, borderRadius: BorderRadius.circular(5)),
                        child: Text(c.tag,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: c.tagColor)),
                      ),
                    ],
                  ),
                  subtitle: Text(c.phone, style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fiche de ${c.name} — bientôt'))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
