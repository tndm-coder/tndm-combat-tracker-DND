import json
import random
from combatants import Monster, Player
from dice_roll import roll_formula

with open("srd_5e_monsters_ru.json", "r", encoding="utf-8") as f:
    raw_data = json.load(f)

bestiary_data = {monster["name"]: monster for monster in raw_data}
class CombatantFactory:
    next_id = 1

    @classmethod
    def _assign_id(cls, obj):
        obj.id = cls.next_id
        cls.next_id += 1

    def create_player(
        self,
        name: str,
        initiative: int | None = None,
        ac: int | None = None,
        hp: int | None = None
    ):
        players = []
        player = Player(
            name=name,
            hp=hp if hp is not None else 10,
            ac=ac if ac is not None else 10,
            initiative=initiative if initiative is not None else random.randint(1, 20)
        )
        self._assign_id(player)
        players.append(player)
        return player

    def create_monster(
        self,
        name: str,
        count: int = 1,
        initiative: int | None = None,
        custom_name: str | None = None,
        ac: int | None = None,
        hp_input: str | None = None
    ):
        data = bestiary_data.get(name)
        monsters = []

        group_initiative = initiative if initiative is not None else random.randint(1, 20)
        display_name = custom_name.strip() if custom_name else name

        for i in range(1, count + 1):
            if data:
                hp_str = data.get("Hit Points", "1d10")
                hp_val = roll_formula(hp_input) if hp_input else roll_formula(hp_str)
                ac_val = ac if ac is not None else 10
                ac_str = data.get("Armor Class", "")
                if ac_str:
                    try:
                        ac_val = int(ac_str.split()[0])
                    except ValueError:
                        pass
                if ac is not None:
                    ac_val = ac
                if ac_val is None:
                    ac_val = 10
                monster = Monster(
                    name=f"{display_name} {i}",
                    hp=hp_val,
                    ac=ac_val,
                    initiative=group_initiative,
                    monster_data=data,
                    monster_type=name
                )
            else:
                hp_val = roll_formula(hp_input) if hp_input else roll_formula("1d10")
                ac_val = ac if ac is not None else 10

                monster = Monster(
                    name=f"{display_name} {i}",
                    hp=hp_val,
                    ac=ac_val,
                    initiative=group_initiative,
                    monster_type=name
                )
            self._assign_id(monster)
            monsters.append(monster)
        return monsters
