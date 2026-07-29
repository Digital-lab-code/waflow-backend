import 'package:flutter/material.dart';
import '../services/api_service.dart';

class _Msg {
  final String text;
  final bool me;
  final bool bot;
  const _Msg(this.text, this.me, {this.bot = false});
}

/// Conversation — envoie réellement un message via l'API (mode simulation côté backend).
class ChatScreen extends StatefulWidget {
  final String name;
  const ChatScreen({super.key, required this.name});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Msg> _msgs = [
    _Msg('Bonjour 👋 J\'ai vu votre post sur le sac à main.', false),
    _Msg('Est-il encore disponible ?', false),
    _Msg('Bonjour ! Oui, il est disponible 😊 Souhaitez-vous le commander ?', false, bot: true),
    _Msg('Super ! Combien et comment je paie ?', false),
    _Msg('Il est à 349 DH 💳 Paiement par carte ou à la livraison.', true),
  ];
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _msgs.add(_Msg(text, true));
      _sending = true;
    });
    _controller.clear();
    _scrollToBottom();
    try {
      // Numéro de démo — en réalité, le numéro réel du contact.
      await ApiService().sendMessage(to: '+212612345678', body: text);
      _snack('✅ Envoyé (simulation backend)');
    } catch (_) {
      _snack('⚠️ Backend injoignable');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Text(widget.name.substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const Text('En ligne', style: TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(14),
              itemCount: _msgs.length,
              itemBuilder: (context, i) => _bubble(_msgs[i]),
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _bubble(_Msg m) {
    final isMe = m.me;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: m.bot
              ? const Color(0xFFEEF2FF)
              : (isMe ? const Color(0xFFDCF8C6) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: m.bot ? Border.all(color: const Color(0xFFC7D2FE)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.bot)
              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('🤖 Réponse automatique',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF4F46E5))),
              ),
            Text(m.text, style: const TextStyle(fontSize: 12.5, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Écrire un message…',
                isDense: true,
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          IconButton(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send, color: Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }
}
