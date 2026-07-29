const config = require('../../config');

let _client = null;

/**
 * Client Stripe paresseux. Retourne null si aucune clé configurée (mode démo).
 * Le module `stripe` n'est chargé que si une clé existe.
 */
function client() {
  if (_client) return _client;
  if (!config.billing.stripeSecretKey) return null;
  const Stripe = require('stripe');
  _client = Stripe(config.billing.stripeSecretKey);
  return _client;
}

/** Crée une session Checkout (abonnement). */
async function createCheckoutSession({ accountId, priceId, planId, successUrl, cancelUrl }) {
  const s = client();
  if (!s) return null;
  return s.checkout.sessions.create({
    mode: 'subscription',
    line_items: [{ price: priceId, quantity: 1 }],
    client_reference_id: accountId,
    metadata: { accountId, planId },
    success_url: successUrl,
    cancel_url: cancelUrl,
  });
}

/** Vérifie la signature d'un événement webhook Stripe. */
function constructEvent(rawBody, signature) {
  const s = client();
  return s.webhooks.constructEvent(rawBody, signature, config.billing.stripeWebhookSecret);
}

module.exports = { createCheckoutSession, constructEvent };
