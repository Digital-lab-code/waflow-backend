require('dotenv').config();

const config = {
  port: parseInt(process.env.PORT || '3000', 10),

  // Mode démo : true par défaut (pas d'appel réseau vers Meta)
  dryRun: process.env.DRY_RUN !== 'false',

  // Code pays par défaut (numéros locaux commençant par 0)
  defaultCountryCode: (process.env.DEFAULT_COUNTRY_CODE || '212').replace(/\D/g, ''),

  // Clé API optionnelle pour protéger les endpoints
  apiKey: process.env.API_KEY || '',

  // Identifiants WhatsApp Cloud API
  wa: {
    token: process.env.WHATSAPP_TOKEN || '',
    phoneNumberId: process.env.PHONE_NUMBER_ID || '',
    apiVersion: process.env.API_VERSION || 'v20.0',
    baseUrl: 'https://graph.facebook.com',
  },

  // ── Chatbot IA (LLM) ─────────────────────────────────────
  ai: {
    provider: process.env.AI_PROVIDER || 'openai', // 'openai' | 'anthropic'
    apiKey: process.env.AI_API_KEY || '',
    model: process.env.AI_MODEL || 'gpt-4o-mini',
    baseUrl: process.env.AI_BASE_URL || 'https://api.openai.com/v1',
    anthropicUrl: process.env.AI_ANTHROPIC_URL || 'https://api.anthropic.com',
    maxTokens: parseInt(process.env.AI_MAX_TOKENS || '300', 10),
    temperature: parseFloat(process.env.AI_TEMPERATURE || '0.6'),
    systemPrompt:
      process.env.AI_SYSTEM_PROMPT ||
      "Tu es l'assistant automatique de la messagerie WhatsApp d'une entreprise. " +
        'Tu aides les clients (produits, prix, horaires, commandes). ' +
        'Sois cordial, bref (2 à 4 phrases) et professionnel. Réponds en français. ' +
        "Si tu ne connais pas la réponse, propose de passer à un conseiller humain. " +
        "N'invente ni prix ni informations non confirmées.",
  },

  // Vérification du webhook entrant
  webhookVerifyToken: process.env.WEBHOOK_VERIFY_TOKEN || 'waflow_verify_token',

  // ── Facturation & abonnements (freemium) ────────────────
  billing: {
    currency: process.env.CURRENCY || 'MAD',
    successUrl: process.env.BILLING_SUCCESS_URL || 'http://localhost:3000/api/billing/subscription',
    cancelUrl: process.env.BILLING_CANCEL_URL || 'http://localhost:3000/api/billing/plans',
    stripeSecretKey: process.env.STRIPE_SECRET_KEY || '',
    stripeWebhookSecret: process.env.STRIPE_WEBHOOK_SECRET || '',
    priceIds: {
      pro: process.env.STRIPE_PRICE_PRO || '',
      business: process.env.STRIPE_PRICE_BUSINESS || '',
    },
    // CMI (Maroc)
    cmi: {
      merchantId: process.env.CMI_MERCHANT_ID || '',
      storeKey: process.env.CMI_STORE_KEY || '',
      baseUrl: process.env.CMI_BASE_URL || 'https://payment.cmi.co.ma/fim/est3Dgate',
      okUrl: process.env.CMI_OK_URL || '',
      failUrl: process.env.CMI_FAIL_URL || '',
      callbackUrl: process.env.CMI_CALLBACK_URL || '',
    },
  },
};

module.exports = config;
