# WaFlow — Backend 🟢

Backend de la plateforme **WaFlow** (gestion WhatsApp) branché sur l'**API officielle Cloud de Meta**.  
Implémente : **envoi de messages**, **campagnes (broadcast opt-in)**, **programmation** et **auto-réponse (chatbot)**.

> ⚙️ Conçu pour fonctionner **immédiatement en mode simulation (DRY-RUN)**, sans clés Meta.

---

## 🚀 Démarrage rapide

```bash
cd waflow-backend
npm install
cp .env.example .env      # DRY_RUN=true par défaut
npm run dev               # ou: npm start
```

Le serveur démarre sur `http://localhost:3000`. Vérifiez :

```bash
curl http://localhost:3000/api/health
```

---

## 🧪 Tester la programmation (sans Meta)

```bash
npm run test:schedule
```

Devrait afficher : `✅ TEST RÉUSSI : le message programmé a été envoyé automatiquement.`

---

## 🔌 Les endpoints

| Méthode | Route | Rôle |
|---|---|---|
| `GET` | `/api/health` | État du serveur + stats |
| `POST` | `/api/messages/send` | Envoi immédiat (fenêtre 24h) |
| `POST` | `/api/messages/schedule` | Programmer un message |
| `GET` | `/api/messages/scheduled` | Liste des messages programmés |
| `POST` | `/api/campaigns` | Créer/envoyer une campagne opt-in |
| `GET` | `/api/campaigns` | Liste des campagnes |
| `GET` | `/api/webhook` | Vérification du webhook (Meta) |
| `POST` | `/api/webhook` | Messages entrants + auto-réponse |

### Exemples `curl`

```bash
# Envoyer un message (simulé en DRY-RUN)
curl -X POST http://localhost:3000/api/messages/send \
  -H "Content-Type: application/json" \
  -d '{"to":"+212612345678","body":"Bonjour depuis WaFlow !"}'

# Programmer un message dans 2 minutes
curl -X POST http://localhost:3000/api/messages/schedule \
  -H "Content-Type: application/json" \
  -d '{"to":"0612345678","body":"Rappel RDV demain 10h ⏰","sendAt":"2026-07-29T20:00:00"}'

# Créer une campagne vers plusieurs contacts opt-in (via template)
curl -X POST http://localhost:3000/api/campaigns \
  -H "Content-Type: application/json" \
  -d '{"name":"Solde -30%","to":["+212612345678","0666112233"],"templateName":"promo_sale"}'
```

---

## 🤖 Chatbot IA (LLM)

Le webhook répond automatiquement aux messages entrants. **Priorité** :

1. **LLM** (GPT/Claude) — si `AI_API_KEY` est défini, **avec mémoire de conversation** par contact.
2. **Repli par mots-clés** — sinon, ou en cas d'erreur (bonjour/prix/horaires/merci…).

### Configurer le LLM

```bash
# .env
AI_PROVIDER=openai                      # ou "anthropic" pour Claude
AI_API_KEY=sk-...                       # votre clé
AI_MODEL=gpt-4o-mini                    # gpt-4o-mini, gpt-4o, ou claude-3-5-sonnet-…
# Optionnels :
AI_BASE_URL=https://api.openai.com/v1   # ou OpenRouter/Groq (compatible OpenAI)
AI_SYSTEM_PROMPT=Tu es l'assistant de…  # persona (variables : {name} {phone})
```

| Provider | `AI_PROVIDER` | `AI_MODEL` (ex.) | Endpoint |
|---|---|---|---|
| OpenAI | `openai` | `gpt-4o-mini` | `api.openai.com/v1` |
| OpenRouter / Groq | `openai` | (au choix) | leur base URL |
| Claude | `anthropic` | `claude-3-5-sonnet-20241022` | `api.anthropic.com` |

> La mémoire de conversation (12 derniers messages par contact) est stockée dans `data/db.json`.

---

## 💳 Abonnements & facturation (freemium)

Système complet Free / Pro / Business avec **application des quotas** par plan.

| Endpoint | Rôle |
|---|---|
| `GET /api/billing/plans` | Liste des plans + devises + mode démo |
| `GET /api/billing/subscription` | Plan courant du compte (`x-account-id`) |
| `POST /api/billing/checkout` | Démarre un paiement **Stripe** (ou simule en démo) |
| `POST /api/billing/mock/complete` | Active un plan en **mode démo** (sans Stripe) |
| `POST /api/billing/cancel` | Repasse en Free |
| `POST /api/billing/webhook` | Événements Stripe (active l'abonnement après paiement) |
| `POST /api/billing/cmi/initiate` | Formulaire de paiement **CMI** (Maroc) |
| `POST /api/billing/cmi/callback` | Retour serveur CMI |

### Mode démonstration (par défaut, sans clé Stripe)
Sans `STRIPE_SECRET_KEY`, le backend est en **mode démo** : `POST /api/billing/mock/complete` active instantanément un plan (paiement simulé). C'est ce qu'utilise l'app Flutter pour tester.

### Quotas (freemium en action)
Les quotas sont **vérifiés automatiquement**. Exemple : en Free, une campagne à 200 destinataires renvoie **HTTP 402** (limite = 50). En Pro, elle passe.

```bash
# Compte "carol" en Free → 200 destinataires = 402 Payment Required
curl -X POST $URL/api/campaigns -H "x-account-id: carol" ...
```

### Activer Stripe (réel)
```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PRICE_PRO=price_xxx        # prix récurrent créé dans Stripe
STRIPE_PRICE_BUSINESS=price_xxx
```
Configurez le webhook `https://votre-domaine/api/billing/webhook` pour l'événement `checkout.session.completed`.

### CMI (paiement en dirhams)
Renseignez `CMI_MERCHANT_ID`, `CMI_STORE_KEY`, `CMI_OK_URL`… puis appelez `POST /api/billing/cmi/initiate`.
⚠️ La logique de hash (Nestpay/3D-Pay) est dans `src/services/payments/cmi.js` et **doit être validée** avec le guide de votre acquéreur CMI.

---

## 🔑 Brancher les vraies clés WhatsApp Cloud API

1. Créez une app sur **https://developers.facebook.com/apps** → type *Business*.
2. Ajoutez le produit **WhatsApp**.
3. Récupérez : `WHATSAPP_TOKEN`, `PHONE_NUMBER_ID`, `WHATSAPP_BUSINESS_ID`.
4. Ajoutez un numéro de test, puis un numéro business vérifié.
5. (Webhook) Définissez `WEBHOOK_VERIFY_TOKEN`, configurez l'URL `https://votre-domaine/api/webhook` dans Meta, abonnez-vous à `messages`.
6. Mettez `DRY_RUN=false` dans `.env`.

> ℹ️ Docs officielles : https://developers.facebook.com/docs/whatsapp/cloud-api/get-started

---

## 🏗️ Architecture

```
src/
├── server.js            # App Express + démarrage
├── config.js            # Configuration (.env)
├── whatsapp/client.js   # Client API Cloud Meta (texte + template)
├── scheduler/           # Worker de programmation (toutes les 60s)
├── services/            # ai.js (LLM) + conversation.js (mémoire) + subscriptions.js + plans.js
│   └── payments/        # stripe.js + cmi.js
├── store/db.js          # Persistance JSON (→ PostgreSQL en prod)
├── routes/              # messages, campaigns, webhook
└── utils/validation.js  # Normalisation des numéros
```

### ⚠️ Rappels de conformité (API officielle)
- **Fenêtre de 24 h** : on ne peut écrire librement qu'à un contact ayant écrit récemment.
- **Campagnes sortantes** : nécessitent un **template validé** + **opt-in** du contact.
- **Pas de scraping** de groupes ni de spam — sous peine de bannissement.

---

## 🔁 Évolutions prévues (vers la production)
| Prototype | Production |
|---|---|
| Persistance JSON | PostgreSQL |
| `setInterval` | BullMQ + Redis |
| Chatbot par mots-clés | LLM (GPT / Claude) |
| Auth simple | JWT + multi-utilisateurs |
| Mono-numéro | Multi-numéros WhatsApp |

---

*WaFlow Backend v1.0 · © 2026*
