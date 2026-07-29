import 'package:flutter/material.dart';
import 'chat_screen.dart';

class _Convo {
  final String name, initials, msg, time;
  final Color color;
  final int unread;
  final bool bot;
  const _Convo(this.name, this.initials, this.color, this.msg, this.time,
      {this.unread = 0, this.bot = false});
}

/// Boîte de réception unifiée (données de démo).
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final convos = [
      _Convo('Sara Klein', 'SK', const Color(0xFF3B82F6), 'Bonjour, ma commande est-elle prête ?', '14:32', unread: 2),
      _Convo('Ahmed Benali', 'AB', const Color(0xFFF59E0B), '🤖 Répondu automatiquement', '14:20', bot: true),
      _Convo('Marie Evrard', 'ME', const Color(0xFFEF4444), 'Merci ! Je recommande 👌', '13:55'),
      _Convo('Youssef Lahlou', 'YL', const Color(0xFF8B5CF6), 'Vous acceptez le paiement à la livraison ?', '13:40', unread: 1),
      _Convo('Clinique Dental', 'CK', const Color(0xFF10B981), 'Rappel RDV demain 10h ✓', '12:10'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boîte de réception'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: ListView.separated(
        itemCount: convos.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
        itemBuilder: (context, i) {
          final c = convos[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              radius: 23,
              backgroundColor: c.color,
              child: Text(c.initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(c.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                if (c.bot)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('BOT',
                        style: TextStyle(
                            fontSize: 9, color: Color(0xFF4F46E5), fontWeight: FontWeight.w700)),
                  ),
                const Spacer(),
                Text(c.time, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
            subtitle: Text(c.msg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
            trailing: c.unread > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(10)),
                    child: Text('${c.unread}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                  )
                : null,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ChatScreen(name: c.name))),
          );
        },
      ),
    );
  }
}
