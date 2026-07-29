const express = require('express');
const { load, save } = require('../store/db');
const { sendTemplate, sendText } = require('../whatsapp/client');
const { normalizePhone, uid } = require('../utils/validation');
const { enforce } = require('../services/subscriptions');

const router = express.Router();

/**
 * POST /api/campaigns
 * Crée (et envoie) une campagne vers plusieurs contacts OPT-IN.
 *
 * ⚠️  Conformité : les destinataires DOIVENT avoir consenti à recevoir
 *     des messages marketing. On utilise un TEMPLATE validé par Meta.
 *
 * body: {
 *   name: "Solde -30%",
 *   to: ["+2126...", "+2126..."],
 *   templateName: "promo_sale",          // requis pour une campagne sortante
 *   languageCode: "fr",                   // optionnel
 *   sendAt: "2026-07-29T18:00:00"         // optionnel = immédiat
 * }
 */
router.post('/', async (req, res) => {
  try {
    const { name, templateName, languageCode = 'fr', sendAt } = req.body || {};
    const rawNumbers = Array.isArray(req.body?.to) ? req.body.to : [];
    if (!name) return res.status(400).json({ error: 'Le nom de la campagne est requis' });
    if (rawNumbers.length === 0) return res.status(400).json({ error: 'Au moins un destinataire (to) est requis' });

    // Normalisation + déduplication des numéros
    const seen = new Set();
    const recipients = [];
    for (const n of rawNumbers) {
      try {
        const p = normalizePhone(n);
        if (!seen.has(p)) { seen.add(p); recipients.push(p); }
      } catch (e) {
        return res.status(400).json({ error: `Destinataire invalide "${n}" : ${e.message}` });
      }
    }

    const when = sendAt ? new Date(sendAt) : null;
    if (sendAt && (isNaN(when.getTime()) || when.getTime() < Date.now())) {
      return res.status(400).json({ error: 'sendAt invalide ou dans le passé' });
    }

    // ── Quota freemium : nombre de destinataires selon le plan ──
    const accountId = req.get('x-account-id') || 'demo_account';
    const quota = enforce(accountId, 'campaignRecipients', recipients.length);
    if (quota) {
      return res.status(402).json({
        error: `Plan ${quota.plan} : limite de campagne = ${quota.limit} destinataires (demandé ${quota.requested}). Passez à un plan supérieur.`,
        upgrade: true,
        ...quota,
      });
    }

    const campaign = {
      id: uid('cmp'),
      name,
      recipients,
      templateName,
      languageCode,
      sendAt: when ? when.toISOString() : null,
      status: when ? 'scheduled' : 'sending',
      results: [],
      createdAt: new Date().toISOString(),
    };

    // Envoi immédiat (si pas de sendAt) — via template (conforme)
    if (!when) {
      for (const to of recipients) {
        try {
          if (templateName) {
            await sendTemplate({ to, templateName, languageCode });
          } else {
            // Sans template : uniquement valable dans la fenêtre 24h (reply).
            await sendText({ to, body: name });
          }
          campaign.results.push({ to, status: 'sent' });
        } catch (e) {
          campaign.results.push({ to, status: 'error', error: e.message });
        }
      }
      campaign.status = 'done';
      console.log(`📨 Campagne "${name}" envoyée à ${recipients.length} contact(s)`);
    }

    const db = load();
    db.campaigns.push(campaign);
    save(db);

    res.json({ success: true, campaign });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

/** GET /api/campaigns — liste les campagnes. */
router.get('/', (req, res) => {
  res.json({ campaigns: load().campaigns });
});

module.exports = router;
