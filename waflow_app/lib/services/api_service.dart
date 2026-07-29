import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/models.dart';

/// Client HTTP qui consomme le backend WaFlow (waflow-backend).
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();
  factory ApiService() => instance;

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (ApiConfig.apiKey.isNotEmpty) 'x-api-key': ApiConfig.apiKey,
        'x-account-id': ApiConfig.accountId,
      };

  /// GET /api/health
  Future<HealthStatus> health() async {
    final r = await http.get(_uri('/api/health'), headers: _headers);
    if (r.statusCode != 200) throw Exception('health ${r.statusCode}');
    return HealthStatus.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  /// POST /api/messages/send
  Future<Map<String, dynamic>> sendMessage({
    required String to,
    required String body,
  }) async {
    final r = await http.post(
      _uri('/api/messages/send'),
      headers: _headers,
      body: jsonEncode({'to': to, 'body': body}),
    );
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode != 200) throw Exception(data['error'] ?? 'send ${r.statusCode}');
    return data;
  }

  /// POST /api/messages/schedule
  Future<Map<String, dynamic>> scheduleMessage({
    required String to,
    required String body,
    required DateTime sendAt,
  }) async {
    final r = await http.post(
      _uri('/api/messages/schedule'),
      headers: _headers,
      body: jsonEncode({
        'to': to,
        'body': body,
        'sendAt': sendAt.toUtc().toIso8601String(),
      }),
    );
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode != 200) throw Exception(data['error'] ?? 'schedule ${r.statusCode}');
    return data;
  }

  /// GET /api/messages/scheduled
  Future<List<ScheduledMessage>> getScheduled() async {
    final r = await http.get(_uri('/api/messages/scheduled'), headers: _headers);
    if (r.statusCode != 200) throw Exception('scheduled ${r.statusCode}');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    final list = data['scheduled'] as List? ?? [];
    return list
        .map((e) => ScheduledMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/campaigns
  Future<List<Campaign>> getCampaigns() async {
    final r = await http.get(_uri('/api/campaigns'), headers: _headers);
    if (r.statusCode != 200) throw Exception('campaigns ${r.statusCode}');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    final list = data['campaigns'] as List? ?? [];
    return list
        .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/campaigns
  Future<Map<String, dynamic>> createCampaign({
    required String name,
    required List<String> to,
    String? templateName,
    DateTime? sendAt,
  }) async {
    final payload = <String, dynamic>{'name': name, 'to': to};
    if (templateName != null) payload['templateName'] = templateName;
    if (sendAt != null) payload['sendAt'] = sendAt.toUtc().toIso8601String();
    final r = await http.post(
      _uri('/api/campaigns'),
      headers: _headers,
      body: jsonEncode(payload),
    );
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode != 200) throw Exception(data['error'] ?? 'campaign ${r.statusCode}');
    return data;
  }

  /// GET /api/billing/plans
  Future<List<Plan>> getPlans() async {
    final r = await http.get(_uri('/api/billing/plans'), headers: _headers);
    if (r.statusCode != 200) throw Exception('plans ${r.statusCode}');
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    final list = data['plans'] as List? ?? [];
    return list.map((e) => Plan.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/billing/subscription
  Future<Subscription> getSubscription() async {
    final r = await http.get(_uri('/api/billing/subscription'), headers: _headers);
    if (r.statusCode != 200) throw Exception('subscription ${r.statusCode}');
    return Subscription.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  /// POST /api/billing/mock/complete — active un plan en mode démo (ou après paiement réel).
  Future<void> subscribe(String planId) async {
    final r = await http.post(
      _uri('/api/billing/mock/complete'),
      headers: _headers,
      body: jsonEncode({'planId': planId}),
    );
    if (r.statusCode != 200) {
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      throw Exception(data['error'] ?? 'subscribe ${r.statusCode}');
    }
  }

  /// POST /api/billing/cancel — repasse en Free.
  Future<void> cancelSubscription() async {
    await http.post(_uri('/api/billing/cancel'), headers: _headers);
  }
}
