import random
from typing import List
from combatants import Combatant


class BattleEngine:
    def __init__(self, combatants: List[Combatant] = None):
        self.combatants = combatants or []
        self.current_index = 0
        self.round = 1
        self.in_combat = False
        self.combatant_groups = []
        self.sub_index = 0
        self.turn_started = set()
        self.prev_group = None
        self.current_initiative_group = None

    def add_combatant(self, combatant):
        self.combatants.append(combatant)
        if not self.in_combat:
            self.sort_initiative()

    def roll_initiative(self):
        for c in self.combatants:
            if c.initiative is None:
                c.initiative = random.randint(1, 20)
        self.sort_initiative()

    def start_combat(self):
        if self.in_combat or not self.combatants:
            return
        self.sort_initiative()
        self.build_initiative_groups()
        self.in_combat = True
        self.current_index = 0
        self.sub_index = 0
        self.prev_group = None
        if self.combatant_groups:
            first_group = self.next_turn()
            self.current_initiative_group = first_group[0].initiative
            self.round = 1

    def end_combat(self):
        self.in_combat = False
        self.current_index = 0
        self.sub_index = 0
        self.round = 1

    def sort_initiative(self):
        if self.in_combat:
            return

        self.combatants.sort(
            key=lambda c: c.initiative if c.initiative is not None else 0,
            reverse=True
        )

    def build_initiative_groups(self):
        sorted_units = sorted(self.combatants, key=lambda x: x.initiative, reverse=True)
        groups = []
        current_group = []
        current_init = None
        for unit in sorted_units:
            if current_init is None or unit.initiative != current_init:
                if current_group:
                    groups.append(current_group)
                current_group = [unit]
                current_init = unit.initiative
            else:
                current_group.append(unit)
        if current_group:
            groups.append(current_group)
        self.combatant_groups = groups
        self.current_index = 0
        self.sub_index = 0

    def get_current(self):
        if not self.in_combat:
            return None
        if not self.combatant_groups:
            return None
        group = self.combatant_groups[self.current_index]
        if self.sub_index >= len(group):
            return None
        return group[self.sub_index]

    def next_turn(self):
        if not self.in_combat or not self.combatant_groups:
            return None
        if self.prev_group:
            self._update_effects_for_prev_turn(self.prev_group)

        total = len(self.combatant_groups)
        checked = 0
        while checked < total:
            group = self.combatant_groups[self.current_index]
            if any(not c.incapacitated for c in group):
                result = group
                self.prev_group = result
                self.current_index += 1
                if self.current_index >= total:
                    self.current_index = 0
                    self.round += 1
                return result
            self.current_index += 1
            if self.current_index >= total:
                self.current_index = 0
                self.round += 1
            checked += 1
        return None

    def set_state(self, combat, new_state):
        old_state = getattr(combat, "state", "alive")
        combat.state = new_state

        combat.effects["concentration"] = False

        if new_state == "dead":
            if combat.hp is not None:
                combat.hp = 0
            combat.effects["incapacitated"] = True

        elif new_state == "unconscious":
            if combat.hp is not None:
                combat.hp = 0
            combat.effects["incapacitated"] = True

        elif new_state == "left":
            combat.effects["incapacitated"] = True

        elif new_state == "alive":
            if old_state in ("dead", "unconscious") and combat.hp is not None:
                combat.hp = 1
            combat.effects["incapacitated"] = False

    def add_effect(self, combat, name, duration):
        effects = combat.effects.get("custom_effects", {})
        if duration == "вечный":
            duration = None
        effects[name] = {
            "duration": duration,
            "applied_round": self.round
        }
        combat.effects["custom_effects"] = effects

    def remove_effect(self, combat, name):
            effects = combat.effects.get("custom_effects", {})
            if name in effects:
                del effects[name]
            combat.effects["custom_effects"] = effects

    def add_concentration(self, combat):
        combat.add_concentration()

    def remove_concentration(self, combat):
        combat.remove_concentration()

    def _update_effects_for_prev_turn(self, group):
        for combat in group:
            effects = combat.effects.get("custom_effects", {})
            for name, eff in list(effects.items()):
                dur = eff["duration"]
                if dur is None:
                    continue
                if eff["applied_round"] == self.round:
                    continue
                eff["duration"] -= 1
                if eff["duration"] <= 0:
                    del effects[name]
