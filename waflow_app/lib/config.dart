/// Configuration de l'application WaFlow.
class ApiConfig {
  const ApiConfig._();

  /// URL du backend WaFlow (dossier waflow-backend).
  /// - Émulateur Android : http://10.0.2.2:3000
  /// - Simulateur iOS / desktop : http://localhost:3000
  /// - Appareil physique en local : http://<IP_LAN>:3000
  /// - Production : https://api.votre-domaine.com
  static const String baseUrl = 'http://10.0.2.2:3000';

  /// Clé API optionnelle (si API_KEY est défini côté backend).
  static const String apiKey = '';

  /// Identifiant de compte (pour la facturation freemium). En prod : l'ID utilisateur authentifié.
  static const String accountId = 'demo_account';
}
