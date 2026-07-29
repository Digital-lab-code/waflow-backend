const { load, save } = require('../store/db');
const plans = require('./plans');

/** Renvoie (et crée si besoin) le compte d'abonnement d'un identifiant. */
function getAccount(accountId) {
  const db = load();
  if (!db.accounts) db.accounts = {};
  if (!db.accounts[accountId]) {
    db.accounts[accountId] = {
      id: accountId,
      plan: 'free',
      status: 'active',
      stripeCustomerId: null,
      periodEnd: null,
      updatedAt: new Date().toISOString(),
    };
    save(db);
  }
  return db.accounts[accountId];
}

/** Met à jour l'abonnement d'un compte. */
function setSubscription(accountId, { plan, status = 'active', stripeCustomerId = null, periodEnd = null } = {}) {
  const db = load();
  if (!db.accounts) db.accounts = {};
  db.accounts[accountId] = {
    ...(db.accounts[accountId] || { id: accountId, plan: 'free' }),
    id: accountId,
    plan,
    status,
    stripeCustomerId,
    periodEnd,
    updatedAt: new Date().toISOString(),
  };
  save(db);
  return db.accounts[accountId];
}

/** Renvoie l'objet plan courant d'un compte. */
function getPlanOf(accountId) {
  return plans.get(getAccount(accountId).plan);
}

/**
 * Vérifie un quota. Retourne null si OK, sinon un objet décrivant le dépassement.
 * feature ∈ { contacts, scheduledPerMonth, campaignRecipients, agents }
 */
function enforce(accountId, feature, requested) {
  const plan = getPlanOf(accountId);
  const limit = plan.limits[feature];
  if (limit === undefined || limit === Infinity) return null;
  if (requested > limit) {
    return { plan: plan.id, feature, limit, requested };
  }
  return null;
}

module.exports = { getAccount, setSubscription, getPlanOf, enforce };
