import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// Écran d'abonnement (freemium) — affiche les plans et active l'abonnement via l'API.
class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  List<Plan> _plans = [];
  String _currentPlan = 'free';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final plans = await ApiService().getPlans();
      final sub = await ApiService().getSubscription();
      setState(() {
        _plans = plans;
        _currentPlan = sub.planId;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Backend injoignable. Démarrez waflow-backend.';
      });
    }
  }

  Future<void> _subscribe(Plan plan) async {
    try {
      await ApiService().subscribe(plan.id);
      _snack('🎉 Plan ${plan.name} activé !');
      _load();
    } catch (e) {
      _snack('⚠️ $e');
    }
  }

  Future<void> _cancel() async {
    try {
      await ApiService().cancelSubscription();
      _snack('Retour au plan Free');
      _load();
    } catch (_) {
      _snack('⚠️ Backend injoignable');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Passer Premium')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    children: [
                      const Text('Choisissez votre plan',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('Annulez à tout moment · Sans engagement',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Row(children: [
                          Icon(Icons.info_outline, size: 16, color: Color(0xFF059669)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Mode démonstration — l\'activation est instantanée (paiement simulé).',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF065F46)),
                            ),
                          ),
                        ]),
                      ),
                      ..._plans.map(_planCard),
                      if (_currentPlan != 'free') ...[
                        const SizedBox(height: 8),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _cancel,
                          child: const Text('Annuler l\'abonnement (retour Free)'),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _planCard(Plan plan) {
    final isCurrent = plan.id == _currentPlan;
    final isPopular = plan.id == 'pro';
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isPopular ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
            width: isPopular ? 1.5 : 1),
        boxShadow: isPopular
            ? [BoxShadow(color: const Color(0x2610B981), blurRadius: 30, offset: const Offset(0, 10))]
            : null,
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: -8,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('⭐ POPULAIRE',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(plan.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Text(plan.tagline,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ]),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${plan.price}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  Text(' ${plan.currency} /mois',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 12),
              ...plan.features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('✓ ',
                          style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w800)),
                      Expanded(
                          child: Text(f, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                    ]),
                  )),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: isCurrent
                    ? _currentBadge()
                    : FilledButton(
                        onPressed: plan.id == 'free' ? null : () => _subscribe(plan),
                        child: Text(plan.id == 'free' ? 'Plan gratuit' : 'Choisir ${plan.name} →'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currentBadge() => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: const Text('✓ Plan actuel',
            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
      );

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, size: 48, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 14),
          FilledButton(onPressed: _load, child: const Text('Réessayer')),
        ]),
      ),
    );
  }
}
