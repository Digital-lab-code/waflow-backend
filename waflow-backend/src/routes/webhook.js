const express = require('express');
const { load, save } = require('../store/db');
const { sendText } = require('../whatsapp/client');
const { uid } = require('../utils/validation');
const config = require('../config');
const { generateReply } = require('../services/ai');
const conversation = require('../services/conversation');

const router = express.Router();

/**
 * GET /api/webhook
 * Vérification du webhook par Meta (hub.challenge).
 * À configurer dans le tableau Meta avec WEBHOOK_VERIFY_TOKEN.
 */
router.get('/', (req, res) => {
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  if (mode === 'subscribe' && token === config.webhookVerifyToken) {
    console.log('✅ Webhook vérifié par Meta');
    return res.status(200).send(challenge);
  }
  res.sendStatus(403);
});

/**
 * POST /api/webhook
 * Réception des messages entrants + déclenchement de l'auto-réponse (chatbot).
 * C'est ici qu'on branche la logique IA / règles.
 */
router.post('/', async (req, res) => {
  try {
    const entry = req.body?.entry?.[0];
    const change = entry?.changes?.[0];
    const message = change?.value?.messages?.[0];
    const contact = change?.value?.contacts?.[0];

    if (message) {
      const from = message.from;
      const text = message.text?.body || '';
      const name = contact?.profile?.name || from;

      console.log(`📩 Reçu de ${name} (${from}) : "${text}"`);

      // ── Génération de la réponse ────────────────────────
      // 1) Chatbot IA (si configuré), avec mémoire de conversation
      let reply = null;
      let source = null;
      try {
        const aiReply = await generateReply({ phone: from, name, userMessage: text });
        if (aiReply) {
          conversation.append(from, 'user', text);
          conversation.append(from, 'assistant', aiReply);
          reply = aiReply;
          source = 'ai';
        }
      } catch (e) {
        console.error('⚠️  Erreur IA :', e.message);
      }

      // 2) Fallback : règles par mots-clés (si pas d'IA ou échec)
      if (!reply) {
        reply = autoReply(text, name);
        if (reply) source = 'keywords';
      }

      // Sauvegarde du message entrant + réponse
      const db = load();
      db.incoming.push({ id: uid('in'), from, name, text, reply, source, at: new Date().toISOString() });
      save(db);

      // 3) Envoi de la réponse
      if (reply) {
        await sendText({ to: from, body: reply });
        console.log(`🤖 Réponse (${source}) → ${from} : "${String(reply).slice(0, 50)}…"`);
      } else {
        console.log(`👤 Pas de réponse auto → ${from} (relais humain)`);
      }
    }

    // Toujours répondre 200 rapidement (exigence de Meta)
    res.sendStatus(200);
  } catch (e) {
    console.error('Erreur webhook :', e.message);
    res.sendStatus(200);
  }
});

/**
 * Logique de réponse automatique simple (par mots-clés).
 * À remplacer par un vrai LLM (GPT/Claude) pour le chatbot IA.
 */
function autoReply(text, name) {
  const t = (text || '').toLowerCase();
  if (/(bonjour|salut|salam|hello|bonsoir)/.test(t)) {
    return `Bonjour ${name} 👋 Merci de nous contacter. Comment puis-je vous aider ?`;
  }
  if (/(prix|combien|tarif|cher)/.test(t)) {
    return 'Nos prix sont disponibles sur notre catalogue 💳 Souhaitez-vous recevoir le lien ?';
  }
  if (/(horaire|ouvert|ferm|heure)/.test(t)) {
    return 'Nous sommes ouverts de 9h à 19h, du lundi au samedi 🕘';
  }
  if (/(merci|choukran|thanks)/.test(t)) {
    return 'Avec plaisir 😊 N\'hésitez pas si vous avez d\'autres questions !';
  }
  // Pas de règle : pas de réponse auto (un humain prendra le relais)
  return null;
}

module.exports = router;
