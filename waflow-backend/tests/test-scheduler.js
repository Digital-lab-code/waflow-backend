/**
 * Test du planificateur de messages (mode DRY-RUN, sans Meta).
 * Lance :  npm run test:schedule
 */
const { load, save } = require('../src/store/db');
const scheduler = require('../src/scheduler/scheduler');

function run() {
  // 1. Réinitialise la base de test
  save({ contacts: [], scheduled: [], campaigns: [], logs: [], incoming: [] });

  // 2. Crée un message programmé avec une échéance DÉJÀ PASSÉE → il doit partir tout de suite
  const db = load();
  db.scheduled.push({
    id: 'test_1',
    to: '212612345678',
    body: 'Message de test programmé 🧪',
    sendAt: new Date(Date.now() - 1000).toISOString(),
    sent: false,
    status: 'pending',
  });
  save(db);
  console.log('→ 1 message programmé créé (échéance passée)\n');

  // 3. Déclenche un cycle du planificateur
  scheduler.tick().then(() => {
    const after = load();
    const job = after.scheduled[0];

    console.log('\n--- Résultat ---');
    if (job.sent && job.status === 'sent') {
      console.log('✅ TEST RÉUSSI : le message programmé a été envoyé automatiquement.');
      console.log(`   Destinataire : ${job.to}`);
      console.log(`   Statut       : ${job.status}`);
      console.log(`   Envoyé à     : ${job.sentAt}`);
    } else {
      console.log('❌ TEST ÉCHOUÉ :', job);
      process.exit(1);
    }
  }).catch((e) => {
    console.error('❌ Erreur pendant le test :', e.message);
    process.exit(1);
  });
}

run();
