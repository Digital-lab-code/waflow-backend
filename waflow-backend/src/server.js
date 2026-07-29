const express = require('express');
const config = require('./config');
const messages = require('./routes/messages');
const campaigns = require('./routes/campaigns');
const webhook = require('./routes/webhook');
const billing = require('./routes/billing');
const scheduler = require('./scheduler/scheduler');
const { load } = require('./store/db');

const app = express();
// Le body brut est conservé pour la vérification du webhook Stripe
app.use(express.json({ limit: '1mb', verify: (req, res, buf) => { req.rawBody = buf; } }));

// ── Middleware : clé API optionnelle ──────────────────────
if (config.apiKey) {
  app.use('/api', (req, res, next) => {
    if (req.path === '/webhook') return next(); // le webhook a sa propre vérif Meta
    if (req.headers['x-api-key'] !== config.apiKey) {
      return res.status(401).json({ error: 'Clé API manquante ou invalide' });
    }
    next();
  });
}

// ── Routes ────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  const db = load();
  res.json({
    status: 'ok',
    mode: config.dryRun ? 'DRY-RUN (simulation)' : 'LIVE (API Meta réelle)',
    stats: {
      scheduled: db.scheduled.length,
      pending: db.scheduled.filter((s) => !s.sent).length,
      campaigns: db.campaigns.length,
      incoming: db.incoming.length,
    },
    time: new Date().toISOString(),
  });
});

app.use('/api/messages', messages);
app.use('/api/campaigns', campaigns);
app.use('/api/webhook', webhook);
app.use('/api/billing', billing);

// Racine : petite page d'info
app.get('/', (req, res) => {
  res.type('text/plain').send(
    `WaFlow Backend ✅\n` +
      `---------------\n` +
      `Mode : ${config.dryRun ? 'DRY-RUN (simulation)' : 'LIVE (API Meta)'}\n` +
      `Endpoints :\n` +
      `  GET  /api/health\n` +
      `  POST /api/messages/send\n` +
      `  POST /api/messages/schedule\n` +
      `  GET  /api/messages/scheduled\n` +
      `  POST /api/campaigns\n` +
      `  GET  /api/campaigns\n` +
      `  GET  /api/billing/plans\n` +
      `  GET  /api/billing/subscription\n` +
      `  POST /api/billing/checkout\n` +
      `  POST /api/billing/mock/complete\n` +
      `  POST /api/billing/webhook\n` +
      `  POST /api/billing/cmi/initiate\n` +
      `  GET  /api/webhook   (vérification Meta)\n` +
      `  POST /api/webhook   (messages entrants + auto-réponse)\n`
  );
});

// ── Démarrage ─────────────────────────────────────────────
app.listen(config.port, () => {
  console.log('\n╔════════════════════════════════════════════╗');
  console.log('║   WaFlow Backend — API WhatsApp officielle ║');
  console.log('╚════════════════════════════════════════════╝');
  console.log(`▶  http://localhost:${config.port}`);
  console.log(`▶  Mode : ${config.dryRun ? 'DRY-RUN (simulation, sans Meta)' : 'LIVE (API Meta réelle)'}\n`);

  scheduler.start();
});

module.exports = app;
