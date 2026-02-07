import json
import re
import time
import threading
import os
from copy import deepcopy

from combatants import Monster, Player

EXPORT_DIR = r"C:\Users\8twii\PycharmProjects\CombatTracker\pui"
EXPORT_FILE = os.path.join(EXPORT_DIR, "battle_state.json")


class BattleStateExporter:
    def __init__(self, battle_engine, interval=0.2):
        self.engine = battle_engine
        self.interval = interval

        self._running = False
        self._thread = None

        self._prev_payload = None

        os.makedirs(EXPORT_DIR, exist_ok=True)

    # =========================
    # lifecycle
    # =========================

    def start(self):
        if self._running:
            return
        self._running = True
        self._thread = threading.Thread(target=self._loop, daemon=True)
        self._thread.start()

    def stop(self):
        self._running = False
        self._write_empty()

    def _loop(self):
        while self._running:
            self._tick()
            time.sleep(self.interval)

    # =========================
    # main tick
    # =========================

    def _tick(self):
        if not self.engine.in_combat:
            self._write_empty()
            self._prev_payload = None
            return

        combatants = self._build_combatants()
        active_ids = self._get_active_group_ids()

        payload = {
            "running": True,
            "timestamp": time.time(),
            "round": self.engine.round,
            "active_ids": active_ids,
            "combatants": combatants
        }

        # защита от лишних перезаписей
        if payload != self._prev_payload:
            self._write(payload)
            self._prev_payload = deepcopy(payload)

    # =========================
    # builders
    # =========================

    def _build_combatants(self):
        result = []

        for c in self.engine.combatants:
            kind = "combatant"
            if isinstance(c, Player):
                kind = "player"
            elif isinstance(c, Monster):
                kind = "monster"
            entry = {
                "id": self._combatant_id(c),
                "name": c.custom_name or c.name,
                "display_name": self._display_name(c),
                "kind": kind,
                "hp": c.hp,
                "max_hp": c.max_hp,
                "temp_hp": c.temp_hp,
                "state": c.state,
                "effects": {
                    "temp_hp": c.hp is not None and c.temp_hp > 0,
                    "concentration": bool(c.concentration),
                    "dead": c.state == "dead",
                    "unconscious": c.state == "unconscious",
                    "incapacitated": c.incapacitated,
                },
                "custom_effects": self._export_custom_effects(c),
            }

            result.append(entry)

        return result

    def _display_name(self, combatant):
        name = combatant.custom_name or combatant.name
        if isinstance(combatant, Monster):
            cleaned = re.sub(r"\s*\d+$", "", name).strip()
            return cleaned if cleaned else name
        return name

    def _export_custom_effects(self, combatant):
        effects = combatant.effects.get("custom_effects", {})
        exported = {}

        for name, data in effects.items():
            exported[name] = {
                "duration": data["duration"]
            }

        return exported

    def _get_active_group_ids(self):
        """
        Возвращает список id всех участников текущей инициативной группы
        """
        if not self.engine.in_combat:
            return []

        idx = self.engine.current_index - 1
        if idx < 0:
            idx = len(self.engine.combatant_groups) - 1

        if idx < 0 or idx >= len(self.engine.combatant_groups):
            return []

        group = self.engine.combatant_groups[idx]

        return [
            self._combatant_id(c)
            for c in group
            if not c.incapacitated
        ]

    # =========================
    # utils
    # =========================

    def _combatant_id(self, combatant):
        return f"id_{id(combatant)}"

    def _write(self, payload):
        with open(EXPORT_FILE, "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, indent=2)

    def _write_empty(self):
        with open(EXPORT_FILE, "w", encoding="utf-8") as f:
            json.dump(
                {
                    "running": False,
                    "combatants": [],
                    "active_ids": []
                },
                f,
                ensure_ascii=False,
                indent=2
            )
