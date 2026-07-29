const axios = require('axios');
const config = require('../config');
const conversation = require('./conversation');

/**
 * Génère une réponse via un LLM, avec la mémoire de conversation du contact.
 *
 * Supports :
 *  - provider "openai"    → OpenAI & tout endpoint compatible (OpenRouter, Groq…)
 *  - provider "anthropic" → Claude (API native)
 *
 * Retourne null si aucune clé n'est configurée (le webhook bascule sur les mots-clés).
 */
async function generateReply({ phone, name, userMessage }) {
  if (!config.ai.apiKey) return null;

  const history = conversation.getHistory(phone);
  const turns = history.map((m) => ({ role: m.role, content: m.content }));
  turns.push({ role: 'user', content: userMessage });

  const system = config.ai.systemPrompt
    .replace('{name}', name)
    .replace('{phone}', phone);

  // ── Claude (Anthropic) ──────────────────────────────
  if (config.ai.provider === 'anthropic') {
    const { data } = await axios.post(
      `${config.ai.anthropicUrl}/v1/messages`,
      {
        model: config.ai.model,
        max_tokens: config.ai.maxTokens,
        system,
        messages: turns,
      },
      {
        headers: {
          'x-api-key': config.ai.apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        timeout: 25000,
      }
    );
    return data?.content?.[0]?.text?.trim() || null;
  }

  // ── OpenAI-compatible (défaut) ──────────────────────
  const messages = [{ role: 'system', content: system }, ...turns];
  const { data } = await axios.post(
    `${config.ai.baseUrl}/chat/completions`,
    {
      model: config.ai.model,
      messages,
      max_tokens: config.ai.maxTokens,
      temperature: config.ai.temperature,
    },
    {
      headers: {
        Authorization: `Bearer ${config.ai.apiKey}`,
        'Content-Type': 'application/json',
      },
      timeout: 25000,
    }
  );
  return data?.choices?.[0]?.message?.content?.trim() || null;
}

module.exports = { generateReply };
