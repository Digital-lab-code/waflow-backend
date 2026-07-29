const crypto = require('crypto');
const config = require('../../config');

/**
 * Adaptateur CMI (Centre Monétique Interbancaire — Maroc).
 *
 * ⚠️  SCAFFOLD : la logique de hachage exacte doit être VALIDÉE avec le guide
 *     d'intégration fourni par votre banque/acquéreur CMI. L'algorithme ci-dessous
 *     correspond à l'approche Nestpay/3D-Pay la plus couramment documentée.
 *
 * Flux : le marchand POST un formulaire (champs + hash) vers la passerelle CMI,
 *       l'utilisateur paie sur la page 3D Secure, puis CMI rappelle okUrl/failUrl/callback.
 *
 * Doc : https://payment.cmi.co.ma  (espace marchand)
 */

const FIELD_ORDER = [
  'clientid', 'oid', 'amount', 'okUrl', 'failUrl', 'callbackUrl',
  'email', 'BillToName', 'currency', 'TranType', 'storetype',
  'hashAlgorithm', 'rnd', 'lang',
];

/** Construit les paramètres de paiement + le hash. */
function buildPayment({ orderId, amount, email = 'client@example.com' }) {
  const c = config.billing.cmi;
  const params = {
    clientid: c.merchantId,
    oid: orderId,
    amount: Number(amount).toFixed(2),
    okUrl: c.okUrl,
    failUrl: c.failUrl,
    callbackUrl: c.callbackUrl,
    email,
    BillToName: 'WaFlow Client',
    currency: '950', // 950 = MAD (ISO 4217 numérique)
    TranType: 'Auth',
    storetype: '3D_pay_hosting',
    hashAlgorithm: 'ver3',
    rnd: `${Date.now()}${Math.floor(Math.random() * 1000)}`,
    lang: 'fr',
    refreshtime: '0',
  };

  // Hash CMI : storeKey | champ1=val1&champ2=val2&... | storeKey  →  SHA-512 base64
  const paramString = FIELD_ORDER.filter((k) => params[k] !== undefined)
    .map((k) => `${k}=${params[k]}`)
    .join('&');
  const storeKey = c.storeKey || '';
  const plain = `${storeKey}|${paramString}|${storeKey}`;
  params.hash = crypto.createHash('sha512').update(plain, 'utf8').digest('base64');

  return { params, gatewayUrl: c.baseUrl };
}

/** Génère une page HTML qui auto-submit le formulaire vers la passerelle. */
function htmlForm(params, gatewayUrl) {
  const inputs = Object.entries(params)
      .map(([k, v]) => `    <input type="hidden" name="${k}" value="${v}">`)
      .join('\n');
  return `<!doctype html>
<html lang="fr">
<head><meta charset="utf-8"><title>Redirection vers CMI…</title></head>
<body onload="document.forms[0].submit()">
  <h3>Redirection vers le paiement sécurisé CMI…</h3>
  <form method="post" action="${gatewayUrl}">
${inputs}
    <noscript><button type="submit">Continuer</button></noscript>
  </form>
</body>
</html>`;
}

/** Vérifie le hash renvoyé par CMI sur le callback (okUrl/callback). */
function verifyResponse(returnedParams) {
  const c = config.billing.cmi;
  const hash = returnedParams.HASH || returnedParams.hash;
  if (!hash) return false;
  const storeKey = c.storeKey || '';
  const paramString = FIELD_ORDER.filter((k) => returnedParams[k] !== undefined)
    .map((k) => `${k}=${returnedParams[k]}`)
    .join('&');
  const plain = `${storeKey}|${paramString}|${storeKey}`;
  const expected = crypto.createHash('sha512').update(plain, 'utf8').digest('base64');
  return expected === hash;
}

module.exports = { buildPayment, htmlForm, verifyResponse };
