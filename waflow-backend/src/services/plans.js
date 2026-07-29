/**
 * Définition des plans d'abonnement (freemium) + quotas.
 * Infinity = "illimité" (sérialisé en null dans l'API).
 */
const PLANS = {
  free: {
    id: 'free',
    name: 'Free',
    price: 0,
    currency: 'MAD',
    tagline: 'Pour découvrir',
    features: [
      '1 numéro WhatsApp',
      '100 contacts',
      '50 messages programmés / mois',
      'Réponses automatiques (mots-clés)',
    ],
    limits: { contacts: 100, scheduledPerMonth: 50, campaignRecipients: 50, agents: 1, ai: false },
  },
  pro: {
    id: 'pro',
    name: 'Pro',
    price: 290,
    currency: 'MAD',
    tagline: 'PME & indépendants',
    features: [
      'Chatbot IA (GPT / Claude)',
      '1 000 contacts opt-in',
      'Campagnes illimitées',
      '3 agents',
      'Séquences automatiques',
    ],
    limits: { contacts: 1000, scheduledPerMonth: Infinity, campaignRecipients: 1000, agents: 3, ai: true },
  },
  business: {
    id: 'business',
    name: 'Business',
    price: 890,
    currency: 'MAD',
    tagline: 'Agences & e-commerce',
    features: [
      '10 000 contacts opt-in',
      'Multi-numéros',
      'Agents illimités',
      'Marque blanche + API publique',
    ],
    limits: { contacts: 10000, scheduledPerMonth: Infinity, campaignRecipients: 10000, agents: Infinity, ai: true },
  },
};

const ORDER = ['free', 'pro', 'business'];

function list() {
  return ORDER.map((id) => PLANS[id]);
}

function get(id) {
  return PLANS[id] || PLANS.free;
}

module.exports = { PLANS, list, get };
