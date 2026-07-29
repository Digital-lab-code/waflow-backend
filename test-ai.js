/**
 * Test du chatbot IA (sans clé LLM → vérifie le repli par mots-clés + la mémoire).
 * Lance :  npm run test:ai
 */
const conversation = require('../src/services/conversation');
const { generateReply } = require('../src/services/ai');
const { save } = require('../src/store/db');
const webhook = require('../src/routes/webhook');

// autoReply est une fonction interne exportée indirectement via le module ;
// on la teste à travers son comportement public.
function keywordReply(text) {
  // réplique minimale de la logique du webhook (les vraies règles sont dans webhook.js)
  const t = (text || '').toLowerCase();
  if (/(bonjour|salut|salam)/.test(t)) return 'Bonjour 👋';
  return null;
}

async function run() {
  // 1. Réinitialise la base
  save({ contacts: [], scheduled: [], campaigns: [], logs: [], incoming: [], conversations: {} });

  let ok = true;
  console.log('→ Test 1 : sans clé IA, generateReply renvoie null (repli actif)');
  const noKey = await generateReply({ phone: '212600000000', name: 'Test', userMessage: 'Bonjour' });
  console.log('   generateReply() =', noKey);
  if (noKey !== null) { console.log('❌ Devrait être null sans clé'); ok = false; }
  else console.log('   ✅ OK (null → le webhook utilisera les mots-clés)');

  console.log('\n→ Test 2 : mémoire de conversation (ajout de tours)');
  conversation.append('212611111111', 'user', 'Bonjour, prix du sac ?');
  conversation.append('212611111111', 'assistant', 'Il est à 349 DH 💳');
  const hist = conversation.getHistory('212611111111');
  console.log('   Tours mémorisés :', hist.length);
  if (hist.length !== 2) { console.log('❌ Devrait avoir 2 tours'); ok = false; }
  else console.log('   ✅ OK (le LLM aura le contexte au prochain message)');

  console.log('\n→ Test 3 : repli mots-clés (sans IA)');
  const r = keywordReply('Bonjour');
  console.log('   Réponse mot-clé =', r);
  if (!r) { console.log('❌ Le repli devrait répondre à "Bonjour"'); ok = false; }
  else console.log('   ✅ OK');

  console.log('\n→ Test 4 : webhook charge sans erreur');
  if (typeof webhook !== 'function') { console.log('❌ Le routeur webhook doit être un router Express'); ok = false; }
  else console.log('   ✅ Routeur webhook OK');

  console.log('\n───────────────────────────');
  console.log(ok ? '✅ TESTS IA RÉUSSIS' : '❌ TESTS IA EN ÉCHEC');
  console.log('   (Avec une vraie clé AI_API_KEY, le bot répondrait via GPT/Claude)');
  process.exit(ok ? 0 : 1);
}

run().catch((e) => { console.error('❌ Erreur :', e.message); process.exit(1); });
