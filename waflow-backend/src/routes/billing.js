const express = require('express');
const config = require('../config');
const plans = require('../services/plans');
const subs = require('../services/subscriptions');
const stripe = require('../services/payments/stripe');
const cmi = require('../services/payments/cmi');

const router = express.Router();

const accountId = (req) => req.get('x-account-id') || 'demo_account';
const mockMode = () => !config.billing.stripeSecretKey;

// Infinity -> null pour la sortie JSON (null = illimité)
function serializePlan(p) {
  return {
    ...p,
    limits: Object.fromEntries(
      Object.entries(p.limits).map(([k, v]) => [k, v === Infinity ? null : v])
    ),
  };
}

/** GET /api/billing/plans — liste des plans + devise + mode démo. */
router.get('/plans', (req, res) => {
  res.json({
    plans: plans.list().map(serializePlan),
    currency: config.billing.currency,
    mockMode: mockMode(),
  });
});

/** GET /api/billing/subscription — plan courant du compte. */
router.get('/subscription', (req, res) => {
  res.json({
    account: subs.getAccount(accountId(req)),
    plan: serializePlan(subs.getPlanOf(accountId(req))),
  });
});

/** POST /api/billing/checkout — démarre un paiement Stripe (ou simule en démo). */
router.post('/checkout', async (req, res) => {
  const plan = plans.get(req.body?.planId);
  if (plan.id === 'free') return res.status(400).json({ error: 'Le plan Free est gratuit' });

  const successUrl = req.body?.successUrl || config.billing.successUrl;
  const cancelUrl = req.body?.cancelUrl || config.billing.cancelUrl;

  if (mockMode()) {
    return res.json({
      mock: true,
      planId: plan.id,
      message: 'Mode démonstration — paiement simulé.',
      url: `${config.billing.successUrl}?plan=${plan.id}&mock=1`,
    });
  }

  const priceId = config.billing.priceIds[plan.id];
  if (!priceId) {
    return res.status(500).json({
      error: `Prix Stripe manquant pour ${plan.name} (var STRIPE_PRICE_${plan.id.toUpperCase()})`,
    });
  }
  try {
    const session = await stripe.createCheckoutSession({
      accountId: accountId(req),
      priceId,
      planId: plan.id,
      successUrl,
      cancelUrl,
    });
    res.json({ url: session.url, sessionId: session.id });
  } catch (e) {
    res.status(500).json({ error: 'Stripe : ' + e.message });
  }
});

/** POST /api/billing/mock/complete — simule un paiement réussi (démo uniquement). */
router.post('/mock/complete', (req, res) => {
  if (!mockMode()) return res.status(400).json({ error: 'Réservé au mode démonstration (sans clé Stripe)' });
  const plan = plans.get(req.body?.planId);
  if (plan.id === 'free') return res.status(400).json({ error: 'Aucun paiement requis pour Free' });
  subs.setSubscription(accountId(req), { plan: plan.id, status: 'active' });
  console.log(`💳 [MOCK] Abonnement activé → ${accountId(req)} : ${plan.name}`);
  res.json({ success: true, account: subs.getAccount(accountId(req)), plan: serializePlan(plan) });
});

/** POST /api/billing/cancel — repasse en Free. */
router.post('/cancel', (req, res) => {
  subs.setSubscription(accountId(req), { plan: 'free', status: 'canceled' });
  console.log(`↩️  Abonnement annulé → ${accountId(req)} : Free`);
  res.json({ success: true, account: subs.getAccount(accountId(req)) });
});

/** POST /api/billing/webhook — événements Stripe (body brut). */
router.post('/webhook', (req, res) => {
  if (mockMode()) return res.status(400).json({ error: 'Webhook Stripe inactif en mode démo' });
  let event;
  try {
    event = stripe.constructEvent(req.rawBody, req.get('stripe-signature'));
  } catch (e) {
    return res.status(400).send(`Webhook Error: ${e.message}`);
  }
  const obj = event.data.object;
  const ref = obj.client_reference_id || obj.metadata?.accountId;
  const planId = obj.metadata?.planId;
  if (event.type === 'checkout.session.completed' && ref && planId) {
    subs.setSubscription(ref, { plan: planId, status: 'active', stripeCustomerId: obj.customer || null });
    console.log(`💳 [STRIPE] Abonnement activé → ${ref} : ${planId}`);
  }
  res.json({ received: true });
});

// ── CMI (Maroc) ──────────────────────────────────────────
/** POST /api/billing/cmi/initiate — génère le formulaire de paiement CMI. */
router.post('/cmi/initiate', (req, res) => {
  const c = config.billing.cmi;
  if (!c.merchantId) return res.status(500).json({ error: 'CMI non configuré (CMI_MERCHANT_ID, CMI_STORE_KEY, CMI_OK_URL...)' });
  const plan = plans.get(req.body?.planId);
  if (plan.id === 'free') return res.status(400).json({ error: 'Pas de paiement pour Free' });
  const { params, gatewayUrl } = cmi.buildPayment({
    orderId: `WF-${Date.now()}`,
    amount: plan.price,
    email: req.body?.email,
  });
  res.type('html').send(cmi.htmlForm(params, gatewayUrl));
});

/** POST /api/billing/cmi/callback — retour serveur de CMI (à adapter selon la banque). */
router.post('/cmi/callback', (req, res) => {
  const p = req.body || {};
  const ok = cmi.verifyResponse(p);
  if (ok && p.Response === 'Approved' && p.mdStatus === '1') {
    const planId = p.oid?.includes('pro') ? 'pro' : 'business';
    subs.setSubscription(accountId(req), { plan: planId, status: 'active' });
    console.log(`💳 [CMI] Paiement approuvé → ${planId}`);
    return res.send('APPROVED');
  }
  console.warn(`⚠️  [CMI] Paiement refusé ou hash invalide`);
  res.send('DECLINED');
});

module.exports = router;
