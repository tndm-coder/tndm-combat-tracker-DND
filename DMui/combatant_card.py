# DMui/combatant_card.py
from PySide6.QtWidgets import QDialog, QVBoxLayout, QLabel, QTextEdit
from .combatant_card import CombatantCard

class CombatantCard(QDialog):
    def __init__(self, combatant):
        super().__init__()
        self.combatant = combatant
        self.setWindowTitle(f"Карточка: {combatant.name}")
        self.resize(400, 300)
        self.init_ui()

    def init_ui(self):
        layout = QVBoxLayout()

        layout.addWidget(QLabel(f"Имя: {self.combatant.name}"))
        layout.addWidget(QLabel(f"HP: {self.combatant.hp}/{self.combatant.max_hp}"))
        layout.addWidget(QLabel(f"AC: {self.combatant.ac}"))
        layout.addWidget(QLabel(f"Инициатива: {self.combatant.initiative}"))

        # эффекты
        eff_text = QTextEdit()
        eff_text.setReadOnly(True)
        eff_list = []
        if "custom_effects" in self.combatant.effects:
            for eff_name, (val, dur) in self.combatant.effects["custom_effects"].items():
                if dur is None:
                    eff_list.append(f"{eff_name}")
                else:
                    eff_list.append(f"{eff_name} ({dur})")
        if "immunities" in self.combatant.effects:
            eff_list.append("Иммунитет: " + ", ".join(self.combatant.effects["immunities"]))
        if "resistances" in self.combatant.effects:
            eff_list.append("Сопротивление: " + ", ".join(self.combatant.effects["resistances"]))

        eff_text.setText("\n".join(eff_list) if eff_list else "Нет эффектов")
        layout.addWidget(QLabel("Эффекты:"))
        layout.addWidget(eff_text)

        self.setLayout(layout)
