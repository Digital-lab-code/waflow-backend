const config = require('../config');

/**
 * Normalise un numéro de téléphone au format international SANS le "+".
 * C'est le format attendu par l'API WhatsApp Cloud (ex: "212612345678").
 *
 * Accepte : "+212 6 12 34 56 78", "00 212 612...", "0612345678", "212612345678"
 */
function normalizePhone(input, defaultCc = config.defaultCountryCode) {
  if (!input) throw new Error('Numéro de téléphone manquant');
  let p = String(input).replace(/[^\d]/g, ''); // on ne garde que les chiffres

  // Préfixe international "00"
  if (p.startsWith('00')) p = p.slice(2);

  // Numéro local commençant par 0 -> on préfixe le code pays par défaut
  if (p.startsWith('0')) p = defaultCc + p.slice(1);

  if (!/^\d{8,15}$/.test(p)) {
    throw new Error(`Numéro invalide : "${input}". Format attendu : international (8 à 15 chiffres).`);
  }
  return p;
}

/** Génère un identifiant unique simple. */
function uid(prefix = 'id') {
  return `${prefix}_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`;
}

module.exports = { normalizePhone, uid };
