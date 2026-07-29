import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';
import 'chat_screen.dart';
import 'scheduler_screen.dart';
import 'pricing_screen.dart';

class _Convo {
  final String name, initials, msg;
  final Color color;
  final bool bot;
  const _Convo(this.name, this.initials, this.color, this.msg, {this.bot = false});
}

/// Tableau de bord — stats (depuis l'API) + actions rapides + conversations.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  HealthStatus? _health;
  bool _online = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final h = await ApiService().health();
      setState(() {
        _health = h;
        _online = true;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _online = false;
        _loading = false;
      });
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            children: [
              _header(),
              if (!_loading && !_online) _offlineBanner(),
              const SizedBox(height: 8),
              _stats(),
              const SizedBox(height: 22),
              _section('Actions rapides'),
              _quickActions(),
              const SizedBox(height: 18),
              _section('Conversations récentes'),
              ..._recents(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour 👋',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                SizedBox(height: 2),
                Text('Tableau de bord',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: const Color(0xFFF1F5F9),
            child: const Icon(Icons.notifications_none, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _offlineBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, size: 18, color: Color(0xFFB45309)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Backend injoignable — démarré ? Données de démo affichées.',
              style: TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    final incoming = _online ? (_health?.incoming ?? 0) : 1284;
    final campaigns = _online ? (_health?.campaigns ?? 0) : 24;
    final pending = _online ? (_health?.pending ?? 0) : 3;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 11,
      crossAxisSpacing: 11,
      childAspectRatio: 1.45,
      children: [
        StatCard(icon: Icons.chat, iconBg: const Color(0xFFECFDF5), value: '$incoming', label: 'Messages (7j)', delta: '▲ 12%'),
        StatCard(icon: Icons.people, iconBg: const Color(0xFFEFF6FF), value: '856', label: 'Contacts', delta: '▲ 8%'),
        StatCard(icon: Icons.send, iconBg: const Color(0xFFF5F3FF), value: '$campaigns', label: 'Campagnes', delta: '▲ 5%'),
        StatCard(icon: Icons.schedule, iconBg: const Color(0xFFFFF7ED), value: '$pending', label: 'En attente', delta: 'actifs'),
      ],
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      );

  Widget _quickActions() {
    Widget qa(IconData icon, String label, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF059669)),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 98,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          qa(Icons.send, 'Broadcast', () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const SchedulerScreen()))),
          const SizedBox(width: 10),
          qa(Icons.schedule, 'Programmer', () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const SchedulerScreen()))),
          const SizedBox(width: 10),
          qa(Icons.smart_toy, 'Chatbot', () => _snack('Chatbot IA — bientôt disponible')),
          const SizedBox(width: 10),
          qa(Icons.bar_chart, 'Stats', () => _snack('Statistiques — bientôt disponibles')),
          const SizedBox(width: 10),
          qa(Icons.star, 'Premium', () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const PricingScreen()))),
        ],
      ),
    );
  }

  List<Widget> _recents() {
    final convos = [
      _Convo('Sara Klein', 'SK', const Color(0xFF3B82F6), 'Merci pour la confirmation !'),
      _Convo('Ahmed Benali', 'AB', const Color(0xFFF59E0B), 'Répondu automatiquement', bot: true),
    ];
    return convos.map((c) => _convoTile(c)).toList();
  }

  Widget _convoTile(_Convo c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: CircleAvatar(
          backgroundColor: c.color,
          child: Text(c.initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        title: Row(
          children: [
            Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            if (c.bot)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('BOT',
                    style: TextStyle(fontSize: 9, color: Color(0xFF4F46E5), fontWeight: FontWeight.w700)),
              ),
          ],
        ),
        subtitle: Text(c.msg,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        trailing: const Text('2m', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => ChatScreen(name: c.name))),
      ),
    );
  }
}
