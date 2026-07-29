import 'package:flutter/material.dart';
import 'main_shell.dart';

/// Écran d'accueil (onboarding) — proposition de valeur + connexion.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.chat, size: 38, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Gérez tout votre WhatsApp,\nautomatiquement.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Réponses auto, campagnes, programmation et chatbot IA — dans une seule application.',
                  style: TextStyle(color: Colors.white, fontSize: 13.5, height: 1.5),
                ),
                const SizedBox(height: 26),
                _feature(Icons.flash_on, 'Réponses automatiques intelligentes'),
                _feature(Icons.send, 'Campagnes multi-contacts opt-in'),
                _feature(Icons.schedule, 'Programmation de messages'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell()),
                  ),
                  child: const Text('Connecter mon WhatsApp  →'),
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Déjà un compte ? Se connecter',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
