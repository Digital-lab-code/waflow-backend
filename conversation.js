const { load, save } = require('../store/db');

const MAX = 12; // nombre max de messages conservés en contexte par contact

/** Renvoie l'historique de conversation d'un contact (tableau de tours). */
function getHistory(phone) {
  const db = load();
  return db.conversations?.[phone] || [];
}

/**
 * Ajoute un tour (user / assistant) à la conversation d'un contact
 * et tronque aux MAX derniers messages (fenêtre de contexte).
 */
function append(phone, role, content) {
  const db = load();
  if (!db.conversations) db.conversations = {};
  if (!db.conversations[phone]) db.conversations[phone] = [];
  db.conversations[phone].push({ role, content, ts: new Date().toISOString() });
  if (db.conversations[phone].length > MAX) {
    db.conversations[phone] = db.conversations[phone].slice(-MAX);
  }
  save(db);
  return db.conversations[phone];
}

module.exports = { getHistory, append, MAX };
