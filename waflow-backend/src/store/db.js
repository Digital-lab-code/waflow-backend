const fs = require('fs');
const path = require('path');

const DB_FILE = path.join(__dirname, '../../data/db.json');

const DEFAULT_DB = { contacts: [], scheduled: [], campaigns: [], logs: [], incoming: [], conversations: {}, accounts: {} };

/**
 * Mini persistance JSON pour le prototype.
 * ⚠️  En production : remplacer par PostgreSQL/MongoDB (cf. cahier des charges).
 */
function load() {
  try {
    const raw = fs.readFileSync(DB_FILE, 'utf8');
    return { ...structuredClone(DEFAULT_DB), ...JSON.parse(raw) };
  } catch {
    return structuredClone(DEFAULT_DB);
  }
}

function save(db) {
  fs.mkdirSync(path.dirname(DB_FILE), { recursive: true });
  fs.writeFileSync(DB_FILE, JSON.stringify(db, null, 2));
}

module.exports = { load, save, DB_FILE };
