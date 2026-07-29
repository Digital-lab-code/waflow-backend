/// Modèles de données WaFlow (issus du backend).

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}

/// Réponse de GET /api/health.
class HealthStatus {
  final String status;
  final String mode;
  final int scheduled;
  final int pending;
  final int campaigns;
  final int incoming;

  const HealthStatus({
    required this.status,
    required this.mode,
    required this.scheduled,
    required this.pending,
    required this.campaigns,
    required this.incoming,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> j) {
    final s = j['stats'] as Map<String, dynamic>?;
    return HealthStatus(
      status: j['status']?.toString() ?? '',
      mode: j['mode']?.toString() ?? '',
      scheduled: _toInt(s?['scheduled']),
      pending: _toInt(s?['pending']),
      campaigns: _toInt(s?['campaigns']),
      incoming: _toInt(s?['incoming']),
    );
  }
}

/// Message programmé (GET /api/messages/scheduled).
class ScheduledMessage {
  final String id;
  final String to;
  final String body;
  final String sendAt;
  final bool sent;
  final String status;

  const ScheduledMessage({
    required this.id,
    required this.to,
    required this.body,
    required this.sendAt,
    required this.sent,
    required this.status,
  });

  factory ScheduledMessage.fromJson(Map<String, dynamic> j) => ScheduledMessage(
        id: j['id']?.toString() ?? '',
        to: j['to']?.toString() ?? '',
        body: j['body']?.toString() ?? '',
        sendAt: j['sendAt']?.toString() ?? '',
        sent: j['sent'] == true,
        status: j['status']?.toString() ?? '',
      );
}

/// Campagne (GET /api/campaigns).
class Campaign {
  final String id;
  final String name;
  final int recipientCount;
  final String status;

  const Campaign({
    required this.id,
    required this.name,
    required this.recipientCount,
    required this.status,
  });

  factory Campaign.fromJson(Map<String, dynamic> j) => Campaign(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        recipientCount: (j['recipients'] as List?)?.length ?? 0,
        status: j['status']?.toString() ?? '',
      );
}

/// Plan d'abonnement (GET /api/billing/plans).
class Plan {
  final String id;
  final String name;
  final String tagline;
  final int price;
  final String currency;
  final List<String> features;
  final Map<String, dynamic> limits;

  const Plan({
    required this.id,
    required this.name,
    required this.tagline,
    required this.price,
    required this.currency,
    required this.features,
    required this.limits,
  });

  factory Plan.fromJson(Map<String, dynamic> j) => Plan(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        tagline: j['tagline']?.toString() ?? '',
        price: _toInt(j['price']),
        currency: j['currency']?.toString() ?? 'MAD',
        features: (j['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
        limits: Map<String, dynamic>.from(j['limits'] as Map? ?? {}),
      );
}

/// Abonnement courant d'un compte (GET /api/billing/subscription).
class Subscription {
  final String accountId;
  final String planId;
  final String status;

  const Subscription({required this.accountId, required this.planId, required this.status});

  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
        accountId: j['account']?['id']?.toString() ?? '',
        planId: j['account']?['plan']?.toString() ?? 'free',
        status: j['account']?['status']?.toString() ?? 'active',
      );
}
