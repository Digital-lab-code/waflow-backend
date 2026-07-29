const express = require('express');
const { load, save } = require('../store/db');
const { sendText } = require('../whatsapp/client');
const { normalizePhone, uid } = require('../utils/validation');

const router = express.Router();

/**
 * POST /api/messages/send
 * Envoie un message texte immédiat (fenêtre 24h).
 * body: { to: "+2126...", body: "Bonjour !" }
 */
router.post('/send', async (req, res) => {
  try {
    const to = normalizePhone(req.body?.to);
    const body = (req.body?.body || '').toString().trim();
    if (!body) return res.status(400).json({ error: 'Le contenu (body) est requis' });

    const result = await sendText({ to, body });

    const db = load();
    db.logs.push({ id: uid('log'), to, body, type: 'immediate', ...result, at: new Date().toISOString() });
    save(db);

    res.json({ success: true, to, ...result });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

/**
 * POST /api/messages/schedule
 * Programme un message à une date/heure donnée.
 * body: { to, body, sendAt: "2026-07-29T18:00:00" }
 */
router.post('/schedule', async (req, res) => {
  try {
    const to = normalizePhone(req.body?.to);
    const body = (req.body?.body || '').toString().trim();
    const sendAt = req.body?.sendAt;
    if (!body) return res.status(400).json({ error: 'Le contenu (body) est requis' });
    if (!sendAt) return res.status(400).json({ error: 'La date (sendAt) est requise' });

    const when = new Date(sendAt);
    if (isNaN(when.getTime())) return res.status(400).json({ error: 'Date invalide (sendAt)' });
    if (when.getTime() < Date.now()) return res.status(400).json({ error: 'La date doit être dans le futur' });

    const job = {
      id: uid('sch'),
      to,
      body,
      sendAt: when.toISOString(),
      sent: false,
      status: 'pending',
      createdAt: new Date().toISOString(),
    };

    const db = load();
    db.scheduled.push(job);
    save(db);

    console.log(`📅 Message programmé → ${to} à ${when.toLocaleString('fr-FR')}`);
    res.json({ success: true, scheduled: job });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

/** GET /api/messages/scheduled — liste les messages programmés. */
router.get('/scheduled', (req, res) => {
  res.json({ scheduled: load().scheduled });
});

module.exports = router;
