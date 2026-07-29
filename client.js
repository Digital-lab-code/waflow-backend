const axios = require('axios');
const config = require('../config');

/**
 * Client pour l'API officielle WhatsApp Cloud (Meta).
 * Docs : https://developers.facebook.com/docs/whatsapp/cloud-api
 *
 * ⚠️ Règles importantes (API officielle) :
 *  - On ne peut écrire LIBREMENT à un contact que dans la fenêtre de 24 h
 *    qui suit son dernier message entrant.
 *  - Pour initier une conversation (campagne), il faut un TEMPLATE validé
 *    par Meta et le consentement (opt-in) du contact.
 */
const headers = () => ({
  Authorization: `Bearer ${config.wa.token}`,
  'Content-Type': 'application/json',
});

const apiUrl = () =>
  `${config.wa.baseUrl}/${config.wa.apiVersion}/${config.wa.phoneNumberId}/messages`;

/** Envoie un message TEXTE (dans la fenêtre de 24h). */
async function sendText({ to, body }) {
  if (config.dryRun) {
    console.log(`✉️  [DRY-RUN] Texte simulé → ${to} : "${body}"`);
    return { success: true, simulated: true, to, body };
  }
  const { data } = await axios.post(
    apiUrl(),
    { messaging_product: 'whatsapp', to, type: 'text', text: { body } },
    { headers: headers() }
  );
  return { success: true, messageId: data.messages?.[0]?.id };
}

/**
 * Envoie un message TEMPLATE (pour initier une conversation / campagne).
 * Le template doit être préalablement validé dans le tableau Meta.
 */
async function sendTemplate({ to, templateName, languageCode = 'fr', components }) {
  if (config.dryRun) {
    console.log(`✉️  [DRY-RUN] Template "${templateName}" simulé → ${to}`);
    return { success: true, simulated: true, to, templateName };
  }
  const template = { name: templateName, language: { code: languageCode } };
  if (components) template.components = components;
  const { data } = await axios.post(
    apiUrl(),
    { messaging_product: 'whatsapp', to, type: 'template', template },
    { headers: headers() }
  );
  return { success: true, messageId: data.messages?.[0]?.id };
}

module.exports = { sendText, sendTemplate };
