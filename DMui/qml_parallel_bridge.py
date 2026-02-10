from __future__ import annotations

from typing import Iterable

from PySide6.QtCore import QObject, Signal, Property, Slot

from battle_engine import BattleEngine
from battle_state_exporter import BattleStateExporter
from combatant_factory import CombatantFactory


class QmlMasterBridge(QObject):
    stateChanged = Signal()
    statusMessageChanged = Signal()

    def __init__(self):
        super().__init__()
        self.factory = CombatantFactory()
        self.battle_engine = BattleEngine()
        self.state_exporter = BattleStateExporter(self.battle_engine, interval=0.5)
        self.current_initiative_group = None
        self._status_message = "Готов к бою"

    @Property(str, notify=stateChanged)
    def roundText(self):
        return f"Раунд: {self.battle_engine.round if self.battle_engine.in_combat else 0}"

    @Property(bool, notify=stateChanged)
    def inCombat(self):
        return self.battle_engine.in_combat

    @Property(str, notify=stateChanged)
    def battleStateText(self):
        return "Идет бой" if self.battle_engine.in_combat else "Ожидание"

    @Property(str, notify=statusMessageChanged)
    def statusMessage(self):
        return self._status_message

    @Property("QVariantList", notify=stateChanged)
    def combatants(self):
        state_mapping = {
            "alive": "Жив",
            "unconscious": "Без сознания",
            "dead": "Мертв",
            "left": "Покинул бой",
        }
        payload = []
        for index, combatant in enumerate(self.battle_engine.combatants):
            custom_effects = combatant.effects.get("custom_effects", {})
            effect_text = []
            for effect_name, data in custom_effects.items():
                duration = data.get("duration")
                effect_text.append(effect_name if duration is None else f"{effect_name} ({duration})")

            payload.append(
                {
                    "index": index,
                    "name": str(combatant.custom_name or combatant.name),
                    "hp": "-" if combatant.hp is None else combatant.hp,
                    "tempHp": "-" if combatant.hp is None else combatant.temp_hp,
                    "ac": "-" if combatant.ac is None else combatant.ac,
                    "initiative": combatant.initiative if combatant.initiative is not None else "-",
                    "effects": ", ".join(effect_text),
                    "concentration": combatant.has_concentration(),
                    "incapacitated": combatant.incapacitated,
                    "state": state_mapping.get(combatant.state, "Жив"),
                    "isCurrent": self.current_initiative_group is not None
                    and combatant.initiative == self.current_initiative_group,
                }
            )
        return payload

    def _set_status(self, message: str):
        self._status_message = message
        self.statusMessageChanged.emit()

    def _emit_state(self):
        self.stateChanged.emit()

    @staticmethod
    def _parse_optional_int(raw_value):
        if raw_value is None:
            return None
        text = str(raw_value).strip()
        if not text:
            return None
        try:
            return int(text)
        except ValueError:
            return None

    @staticmethod
    def _safe_indices(indices: Iterable):
        result = []
        for value in indices or []:
            try:
                parsed = int(value)
                if parsed >= 0:
                    result.append(parsed)
            except (TypeError, ValueError):
                continue
        return result

    def _selected_combatants(self, indices: Iterable):
        selected = []
        valid_indices = self._safe_indices(indices)
        for index in valid_indices:
            if index < len(self.battle_engine.combatants):
                selected.append(self.battle_engine.combatants[index])
        return selected

    @Slot(str, str)
    def addPlayer(self, name: str, initiative_text: str):
        clean_name = (name or "").strip()
        if not clean_name:
            self._set_status("Введите имя игрока")
            return
        initiative = self._parse_optional_int(initiative_text)
        player = self.factory.create_player(name=clean_name, initiative=initiative)
        self.battle_engine.add_combatant(player)
        self._set_status(f"Игрок {clean_name} добавлен")
        self._emit_state()

    @Slot(str, int, str, str, str, str)
    def addMonsters(
        self,
        monster_name: str,
        count: int,
        custom_name: str,
        hp_text: str,
        ac_text: str,
        initiative_text: str,
    ):
        clean_name = (monster_name or "").strip()
        if not clean_name:
            self._set_status("Введите название монстра")
            return

        monsters = self.factory.create_monster(
            name=clean_name,
            count=max(1, int(count)),
            initiative=self._parse_optional_int(initiative_text),
            custom_name=(custom_name or "").strip() or None,
            ac=self._parse_optional_int(ac_text),
            hp_input=(hp_text or "").strip() or None,
        )
        for monster in monsters:
            self.battle_engine.add_combatant(monster)

        self._set_status(f"Добавлено монстров: {len(monsters)}")
        self._emit_state()

    @Slot()
    def startBattle(self):
        self.battle_engine.start_combat()
        if self.battle_engine.in_combat:
            self.state_exporter.start()
            self.current_initiative_group = self.battle_engine.current_initiative_group
            self._set_status("Бой начат")
        self._emit_state()

    @Slot()
    def nextTurn(self):
        group = self.battle_engine.next_turn()
        if not group:
            self._set_status("Нет доступного следующего хода")
            return
        self.current_initiative_group = group[0].initiative
        self._set_status("Ход обновлен")
        self._emit_state()

    @Slot()
    def endBattle(self):
        self.battle_engine.end_combat()
        self.state_exporter.stop()
        self.battle_engine.combatants.clear()
        self.current_initiative_group = None
        self._set_status("Бой завершен")
        self._emit_state()

    @Slot("QVariantList", int)
    def applyDamage(self, indices, damage: int):
        for combatant in self._selected_combatants(indices):
            combatant.take_damage(max(0, int(damage)))
        self._emit_state()

    @Slot("QVariantList", int)
    def applyHeal(self, indices, amount: int):
        for combatant in self._selected_combatants(indices):
            combatant.heal(max(0, int(amount)))
        self._emit_state()

    @Slot("QVariantList", int)
    def setTempHp(self, indices, amount: int):
        for combatant in self._selected_combatants(indices):
            combatant.add_temp_hp(max(0, int(amount)))
        self._emit_state()

    @Slot("QVariantList", str, int)
    def addEffect(self, indices, name: str, duration: int):
        effect_name = (name or "").strip()
        if not effect_name:
            self._set_status("Введите название эффекта")
            return
        effect_duration = None if int(duration) == 0 else int(duration)
        for combatant in self._selected_combatants(indices):
            effects = combatant.effects.setdefault("custom_effects", {})
            effects[effect_name] = {
                "value": True,
                "duration": effect_duration,
                "applied_round": self.battle_engine.round,
            }
        self._set_status("Эффект добавлен")
        self._emit_state()

    @Slot("QVariantList", str)
    def removeEffect(self, indices, name: str):
        effect_name = (name or "").strip()
        if not effect_name:
            return

        selected = self._selected_combatants(indices)
        targets = selected if selected else self.battle_engine.combatants
        for combatant in targets:
            effects = combatant.effects.get("custom_effects", {})
            if effect_name in effects:
                del effects[effect_name]

        self._set_status("Эффект удален")
        self._emit_state()

    @Slot(int, bool)
    def setConcentration(self, index: int, checked: bool):
        if index < 0 or index >= len(self.battle_engine.combatants):
            return
        combatant = self.battle_engine.combatants[index]
        target_checked = bool(checked)
        if combatant.incapacitated:
            target_checked = False

        if target_checked and not combatant.has_concentration():
            self.battle_engine.add_concentration(combatant)
        elif not target_checked and combatant.has_concentration():
            self.battle_engine.remove_concentration(combatant)
        self._emit_state()

    @Slot(int, bool)
    def setIncapacitated(self, index: int, checked: bool):
        if index < 0 or index >= len(self.battle_engine.combatants):
            return
        combatant = self.battle_engine.combatants[index]
        combatant.manually_disabled = bool(checked)
        self._emit_state()

    @Slot(int, str)
    def setState(self, index: int, state_text: str):
        if index < 0 or index >= len(self.battle_engine.combatants):
            return

        mapping = {
            "Жив": "alive",
            "Без сознания": "unconscious",
            "Мертв": "dead",
            "Покинул бой": "left",
        }
        state_value = mapping.get(state_text)
        if not state_value:
            return

        self.battle_engine.set_state(self.battle_engine.combatants[index], state_value)
        self._emit_state()

    @Slot()
    def shutdown(self):
        self.state_exporter.stop()
