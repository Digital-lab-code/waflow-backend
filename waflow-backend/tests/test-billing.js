/**
 * Tests des abonnements freemium : plans, état par défaut, upgrade, quotas.
 * Lance :  npm run test:billing
 */
const plans = require('../src/services/plans');
const subs = require('../src/services/subscriptions');
const { save } = require('../src/store/db');

function assert(cond, msg) {
  if (!cond) { console.log('   ❌ ' + msg); return false; }
  console.log('   ✅ ' + msg);
  return true;
}

function run() {
  save({ contacts: [], scheduled: [], campaigns: [], logs: [], incoming: [], conversations: {}, accounts: {} });
  let ok = true;

  console.log('→ Test 1 : 3 plans définis');
  const list = plans.list();
  ok &= assert(list.length === 3, `3 plans (trouvé: ${list.length})`);
  ok &= assert(list[1].name === 'Pro', 'Le 2e plan est Pro');

  console.log('\n→ Test 2 : compte par défaut = Free');
  subs.getAccount('test_acc');
  ok &= assert(subs.getPlanOf('test_acc').id === 'free', 'Plan par défaut = Free');

  console.log('\n→ Test 3 : upgrade vers Pro');
  subs.setSubscription('test_acc', { plan: 'pro' });
  ok &= assert(subs.getPlanOf('test_acc').id === 'pro', 'Plan mis à jour = Pro');

  console.log('\n→ Test 4 : quotas par plan');
  subs.setSubscription('test_acc', { plan: 'free' });
  const e1 = subs.enforce('test_acc', 'campaignRecipients', 200);
  const e2 = subs.enforce('test_acc', 'campaignRecipients', 10);
  ok &= assert(!!e1, 'Free : 200 destinataires bloqué (limite 50)');
  ok &= assert(!e2, 'Free : 10 destinataires autorisé');

  subs.setSubscription('test_acc', { plan: 'business' });
  const e3 = subs.enforce('test_acc', 'campaignRecipients', 5000);
  ok &= assert(!e3, 'Business : 5000 destinataires autorisé (illimité)');

  console.log('\n───────────────────────────');
  console.log(ok ? '✅ TESTS BILLING RÉUSSIS' : '❌ TESTS BILLING EN ÉCHEC');
  process.exit(ok ? 0 : 1);
}

run();
