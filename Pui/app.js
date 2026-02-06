const UI = document.getElementById("ui-root");

const UPDATE_INTERVAL = 250;
let lastState = null;
let rows = [];

/* ================= GRID ================= */

const gridWrapper = document.createElement("div");
gridWrapper.style.display = "flex";
gridWrapper.style.flexDirection = "column";
gridWrapper.style.alignItems = "center";
gridWrapper.style.gap = "12px";
UI.appendChild(gridWrapper);

const title = document.createElement("div");
title.className = "combat-title";
title.textContent = "⚔️ Бой";
gridWrapper.appendChild(title);

const grid = document.createElement("div");
grid.className = "combat-grid";
Object.assign(grid.style, {
  display: "grid",
  gridAutoFlow: "column",
  gridTemplateRows: "repeat(14, auto)",
  gap: "10px 40px",
  justifyContent: "center"
});
gridWrapper.appendChild(grid);

/* ================= API ================= */

const BattleAPI = {
  async loadJSON() {
    try {
      const res = await fetch("battle_state.json", { cache: "no-store" });
      if (!res.ok) return null;
      return await res.json();
    } catch {
      return null;
    }
  }
};

/* ================= EFFECTS ================= */

const VISUAL_EFFECTS = {
  temp_hp: "🛡️",
  concentration: "✨",
  dead: "💀",
  unconscious: "💔",
  incapacitated: "🌀"
};

const TRANSIENT = {
  damage: "⚡",
  heal: "❤️‍🩹"
};

/* ================= LOOP ================= */

setInterval(mainLoop, UPDATE_INTERVAL);

async function mainLoop() {
  const state = await BattleAPI.loadJSON();
  if (!state || !state.running) return clearUI();

  syncUI(state);
  lastState = structuredClone(state);
}

/* ================= SYNC ================= */

function syncUI(state) {
  while (rows.length < state.combatants.length) {
    const row = createRow();
    grid.appendChild(row);
    rows.push(row);
  }
  while (rows.length > state.combatants.length) {
    rows.pop().remove();
  }

  state.combatants.forEach((c, i) => {
    const prev = lastState?.combatants?.[i];
    const row = rows[i];

    updateRow(row, c, prev);

    const isActive = state.active_ids?.includes(c.id);
    row.classList.toggle("turn-active", isActive);
  });
}

/* ================= ROW ================= */

function createRow() {
  const row = document.createElement("div");
  row.className = "combat-row";
  row.innerHTML = `
    <div class="turn-indicator"></div>
    <div class="emoji-bar"></div>
    <div class="name-card"></div>
    <div class="effects-card"></div>
  `;
  return row;
}

function updateRow(row, data, prev) {
  row.querySelector(".name-card").textContent = data.name;

  updateEmojiBar(row, data);
  updateCustomEffects(row, data);
  applyStates(row, data);

  if (!prev) return;

  if (typeof data.hp === "number" && typeof prev.hp === "number" && data.hp < prev.hp) {
    transient(row, TRANSIENT.damage);
    flash(row, "damage");
  }

  if (typeof data.hp === "number" && typeof prev.hp === "number" && data.hp > prev.hp) {
    transient(row, TRANSIENT.heal);
    flash(row, "heal");
  }
}

/* ================= EMOJI ================= */

function updateEmojiBar(row, data) {
  const bar = row.querySelector(".emoji-bar");
  bar.innerHTML = "";

  const e = data.effects || {};

  if (e.dead) {
    bar.append(createEmoji(VISUAL_EFFECTS.dead));
    return;
  }

  if (e.unconscious) {
    bar.append(createEmoji(VISUAL_EFFECTS.unconscious));
  }

  if (!e.dead && !e.unconscious && e.incapacitated) {
    bar.append(createEmoji(VISUAL_EFFECTS.incapacitated));
  }

  if (e.temp_hp) bar.append(createEmoji(VISUAL_EFFECTS.temp_hp));
  if (e.concentration) bar.append(createEmoji(VISUAL_EFFECTS.concentration));

  if (typeof data.hp === "number" && typeof data.max_hp === "number" && isLowHP(data.hp, data.max_hp) && !e.dead && !e.unconscious) {
    const el = createEmoji("❤️");
    el.classList.add("pulse-lowhp");
    bar.append(el);
    row.classList.add("pulse-lowhp");
  } else {
    row.classList.remove("pulse-lowhp");
  }

  if (e.unconscious) {
    row.classList.add("pulse-unconscious");
  } else {
    row.classList.remove("pulse-unconscious");
  }
}

function createEmoji(char) {
  const e = document.createElement("span");
  e.textContent = char;
  return e;
}

function transient(row, emoji) {
  const bar = row.querySelector(".emoji-bar");
  const el = document.createElement("span");
  el.textContent = emoji;
  bar.prepend(el);
  setTimeout(() => el.remove(), 600);
}

/* ================= CUSTOM EFFECTS ================= */

function updateCustomEffects(row, data) {
  const card = row.querySelector(".effects-card");
  const effects = data.custom_effects || {};

  card.textContent = Object.keys(effects).join(" • ");
}

/* ================= STATES ================= */

function applyStates(row, data) {
  const e = data.effects || {};

  row.classList.toggle("state-dead", e.dead);
  row.classList.toggle(
    "state-incapacitated",
    !e.dead && !e.unconscious && e.incapacitated
  );
  row.classList.toggle("glow-purple", e.concentration);
}

/* ================= FLASH ================= */

function flash(row, type) {
  const color =
    type === "damage"
      ? "rgba(120, 0, 0, 0.8)"
      : "rgba(0, 120, 0, 0.7)";

  row.querySelector(".name-card").animate(
    [
      { boxShadow: "none" },
      { boxShadow: `0 0 26px ${color}` },
      { boxShadow: "none" }
    ],
    { duration: 450, easing: "ease-out" }
  );
}

/* ================= UTILS ================= */

function isLowHP(hp, max) {
  if (max <= 10) return hp === 1;
  return hp <= Math.max(5, Math.floor(max * 0.25));
}

function clearUI() {
  grid.innerHTML = "";
  rows = [];
}
