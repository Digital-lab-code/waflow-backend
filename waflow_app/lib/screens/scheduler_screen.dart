import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// Campagnes & programmation — liste + création de messages planifiés via l'API.
class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  List<ScheduledMessage> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await ApiService().getScheduled();
      setState(() {
        _items = items.reversed.toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _showCreateDialog() async {
    final toCtl = TextEditingController();
    final bodyCtl = TextEditingController();
    DateTime? dt;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Nouveau message programmé'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: toCtl,
                    decoration: const InputDecoration(
                        labelText: 'Destinataire', hintText: 'ex : +212612345678')),
                const SizedBox(height: 12),
                TextField(
                    controller: bodyCtl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Message')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dt == null ? 'Aucune date choisie' : '⏰ ${_fmt(dt!)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now().add(const Duration(minutes: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (d == null || !ctx.mounted) return;
                        final t = await showTimePicker(
                            context: ctx, initialTime: TimeOfDay.now());
                        if (t == null) return;
                        setSt(() =>
                            dt = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                      },
                      child: const Text('Choisir date/heure'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            FilledButton(
              onPressed: () async {
                if (toCtl.text.isEmpty || bodyCtl.text.isEmpty || dt == null) {
                  _snack('Veuillez remplir tous les champs');
                  return;
                }
                try {
                  await ApiService().scheduleMessage(
                      to: toCtl.text.trim(), body: bodyCtl.text.trim(), sendAt: dt!);
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _snack('✅ Message programmé');
                  _load();
                } catch (_) {
                  _snack('⚠️ Backend injoignable');
                }
              },
              child: const Text('Programmer'),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programmation')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, size: 48, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      const Text('Aucun message programmé',
                          style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextButton(
                          onPressed: _showCreateDialog, child: const Text('+ Créer un message')),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, i) {
                    final s = _items[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFF1F5F9),
                        child: Icon(
                          s.sent ? Icons.check_circle : Icons.hourglass_top,
                          color: s.sent ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                      title: Text(s.body,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      subtitle: Text('→ ${s.to} · ${s.status}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                      trailing: Text(_fmt(DateTime.tryParse(s.sendAt) ?? DateTime.now()),
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    );
                  },
                ),
    );
  }
}
