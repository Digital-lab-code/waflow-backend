# WaFlow — Application mobile (Flutter) 📱

Frontend Flutter de la plateforme WaFlow. Il consomme le backend `waflow-backend` et reproduit l'UI du prototype (thème vert, navigation 5 onglets).

## 🗂️ Structure

```
lib/
├── main.dart                  → point d'entrée + thème
├── config.dart                → URL du backend
├── theme.dart                 → design system
├── models/models.dart         → HealthStatus, ScheduledMessage, Campaign
├── services/api_service.dart  → appels HTTP au backend
├── widgets/stat_card.dart     → carte de stat réutilisable
└── screens/
    ├── onboarding_screen.dart → bienvenue + connexion
    ├── main_shell.dart        → navigation inférieure (5 onglets)
    ├── dashboard_screen.dart  → stats (API) + actions (API réelle)
    ├── inbox_screen.dart      → boîte de réception
    ├── chat_screen.dart       → conversation (ENVOI via API)
    ├── scheduler_screen.dart  → programmation (CRÉATION via API)
    ├── contacts_screen.dart   → CRM
    └── settings_screen.dart   → réglages + déconnexion
```

## 🚀 Démarrage

```bash
# 1. Générer les dossiers plateforme (android/ios/…)
flutter create --org com.waflow .

# 2. Installer les dépendances
flutter pub get

# 3. Démarrer le backend (dans waflow-backend, autre terminal)
cd ../waflow-backend && npm run dev

# 4. Lancer l'app
flutter run
```

## 🔌 Connexion au backend

L'URL est dans `lib/config.dart` :

| Cible | Valeur |
|---|---|
| Émulateur Android | `http://10.0.2.2:3000` (défaut) |
| Simulateur iOS / desktop | `http://localhost:3000` |
| Appareil physique (local) | `http://<IP_LAN>:3000` |
| Production | `https://api.votre-domaine.com` |

### ⚠️ Android : autoriser le HTTP local
Dans `android/app/src/main/AndroidManifest.xml`, ajoutez sur `<application>` :
```xml
android:usesCleartextTraffic="true"
```
Et la permission :
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
*(Nécessaire uniquement en développement avec une URL en `http://`.)*

## ✅ Ce qui fonctionne dès maintenant (avec le backend en DRY-RUN)
- **Tableau de bord** : récupère `GET /api/health` et affiche les vraies stats (bannière « hors-ligne » si backend injoignable).
- **Chat** : bouton d'envoi → `POST /api/messages/send` (simulé côté backend).
- **Programmation** : dialogue date/heure → `POST /api/messages/schedule`, puis liste via `GET /api/messages/scheduled`.
- Navigation 5 onglets + onboarding + déconnexion.

## 🔁 Suite logique
- Brancher le **chatbot IA** (LLM) sur les messages entrants.
- Authentification (JWT) + multi-utilisateurs.
- Écrans manquants : campagne (broadcast), analytics, fiche contact, pricing.
- État global (Riverpod/Provider) pour partager les données.

---
*WaFlow App v1.0 · © 2026*
