const { load, save } = require('../store/db');
const { sendText } = require('../whatsapp/client');
const config = require('../config');

const TICK_MS = 60 * 1000; // vérifie toutes les 60 secondes

/**
 * Worker de programmation : parcourt les messages planifiés
 * et envoie ceux dont l'heure est atteinte.
 *
 * En production : remplacer par BullMQ + Redis pour fiabilité/scalabilité.
 */
async function tick() {
  const db = load();
  const now = Date.now();
  const due = db.scheduled.filter((j) => !j.sent && new Date(j.sendAt).getTime() <= now);

  if (due.length === 0) return;

  for (const job of due) {
    try {
      await sendText({ to: job.to, body: job.body });
      job.sent = true;
      job.sentAt = new Date().toISOString();
      job.status = 'sent';
      console.log(`⏰  Message programmé envoyé → ${job.to} (${job.id})`);
    } catch (e) {
      job.status = 'error';
      job.error = e.message;
      job.attempts = (job.attempts || 0) + 1;
      console.error(`❌ Échec envoi programmé ${job.id} : ${e.message}`);
    }
  }
  save(db);
}

function start() {
  const mode = config.dryRun ? 'DRY-RUN (simulé)' : 'LIVE (API réelle)';
  console.log(`⏱️  Planificateur démarré — vérif toutes les ${TICK_MS / 1000}s — mode ${mode}`);
  setInterval(tick, TICK_MS);
  setTimeout(tick, 3000); // petit contrôle au démarrage
}

module.exports = { start, tick, TICK_MS };
