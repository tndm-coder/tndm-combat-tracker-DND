import random

class Combatant:
    def __init__(self, name, initiative=None, hp=0, ac=0, effects=None, custom_name=""):
        self.name = name
        self.custom_name = custom_name
        self.max_hp = hp
        self.hp = hp
        self.temp_hp = 0
        self.ac = ac
        self.effects = effects if effects else {}
        self.concentration = False
        self.manually_disabled = False
        self.initiative = initiative if initiative is not None else random.randint(1, 20)
        self.state = "alive"

    @property
    def incapacitated(self):
        return (
                self.effects.get("incapacitated", False) or
                self.state in ("dead", "unconscious", "left"))

    @property
    def manually_disabled(self):
        return self.effects.get("incapacitated", False)


    @manually_disabled.setter
    def manually_disabled(self, value):
        self.effects["incapacitated"] = bool(value)

    def has_concentration(self):
        return self.concentration

    def add_concentration(self):
        self.concentration = True

    def remove_concentration(self):
        self.concentration = False

    @property
    def is_alive(self):
        if self.hp is None:
            return self.state == "alive"
        return self.state == "alive" and self.hp > 0

    def take_damage(self, amount):
        if self.state in ("dead", "left"):
            return
        if self.temp_hp > 0:
            if self.temp_hp >= amount:
                self.temp_hp -= amount
                amount = 0
            else:
                amount -= self.temp_hp
                self.temp_hp = 0

        if amount > 0:
            self.hp -= amount
            if self.hp <= 0:
                self.hp = 0

    def heal(self, amount):
        if self.state == "dead":
            return
        self.hp = min(self.hp + amount, self.max_hp)

    def add_temp_hp(self, amount):
        if self.state == "dead":
            return
        if amount > self.temp_hp:
            self.temp_hp = amount

    def __repr__(self):
        if self.hp is None:
            return f"{self.custom_name or self.name}: Init={self.initiative}, Player"
        temp_part = f"+{self.temp_hp} temp" if self.temp_hp > 0 else ""
        return f"{self.custom_name or self.name}: Init={self.initiative}, HP={self.hp}/{self.max_hp} {temp_part}, AC={self.ac}"


class Player(Combatant):
    def __init__(self, name, initiative=None, effects=None, custom_name=""):
        super().__init__(name, initiative, hp=1, ac=0, effects=effects, custom_name=custom_name)
        self.max_hp = None
        self.hp = None
        self.temp_hp = 0
        self.ac = None
        self.saving_throws = {}
        self.spells = []
        self.id: int | None = None

    def take_damage(self, amount):
        return

    def heal(self, amount):
        return

    def add_temp_hp(self, amount):
        return


class Monster(Combatant):
    def __init__(self, name, initiative=None, hp=0, ac=0, effects=None,
                 monster_data=None, monster_type=None, custom_name=""):
        super().__init__(name, initiative, hp, ac, effects, custom_name)
        self.monster_type = monster_type if monster_type else name
        self.traits = monster_data.get("Traits", "") if monster_data else ""
        self.actions = monster_data.get("Actions", "") if monster_data else ""
        self.legendary_actions = monster_data.get("Legendary Actions", "") if monster_data else ""
        self.immunities = monster_data.get("Damage Immunities", "") if monster_data else ""
        self.id: int | None = None
