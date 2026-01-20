import json
from pathlib import Path

MONSTERS_FILE = Path(__file__).resolve().parent / "srd_5e_monsters_ru.json"
DEFAULT_MONSTER_TEMPLATE = {
    "name": "",
    "meta": "",
    "Armor Class": "",
    "Hit Points": "",
    "Speed": "",
    "STR": "",
    "STR_mod": "",
    "DEX": "",
    "DEX_mod": "",
    "CON": "",
    "CON_mod": "",
    "INT": "",
    "INT_mod": "",
    "WIS": "",
    "WIS_mod": "",
    "CHA": "",
    "CHA_mod": "",
    "Saving Throws": "",
    "Skills": "",
    "Damage Immunities": "",
    "Senses": "",
    "Languages": "",
    "Challenge": "",
    "Traits": "",
    "Actions": "",
    "Legendary Actions": "",
}

def load_monsters():
    if MONSTERS_FILE.exists():
        with open(MONSTERS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return []

def save_monsters(monsters):
    with open(MONSTERS_FILE, "w", encoding="utf-8") as f:
        json.dump(monsters, f, ensure_ascii=False, indent=2)

def create_monster(data: dict):
    monster = DEFAULT_MONSTER_TEMPLATE.copy()
    monster.update(data)
    monsters = load_monsters()
    monsters.append(monster)
    save_monsters(monsters)

def delete_monster_by_name(name: str) -> bool:
    monsters = load_monsters()
    filtered = [m for m in monsters if m['name'] != name]

    if len(filtered) == len(monsters):
        return False  # не нашли

    save_monsters(filtered)
    return True
