from PySide6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QHBoxLayout,
    QPushButton, QTableWidget, QTableWidgetItem,
    QLineEdit, QLabel, QSpinBox, QCheckBox, QComboBox,
    QFrame, QToolButton, QSizePolicy, QGroupBox,
    QGridLayout, QHeaderView
)
from PySide6.QtCore import Qt
from PySide6.QtGui import QFont, QFontDatabase
from battle_engine import BattleEngine
from combatant_factory import CombatantFactory
import sys
from pathlib import Path
from battle_state_exporter import BattleStateExporter

TABLE_HEADERS = [
    "", "Имя", "Текущие HP", "Временные HP", "Класс брони",
    "Инициатива", "Эффекты", "Концентрация", "Недееспособность", "Состояние"]

class MasterUI(QWidget):
    def __init__(self):
        super().__init__()
        self.observers = []
        self.setWindowTitle("tndm/dnd/tracker")
        self.resize(1400, 850)
        self.factory = CombatantFactory()
        self.battle_engine = BattleEngine()
        self.current_initiative_group = None
        self.round_counter = 0
        self.turn_started = set()
        self.player_name_input = QLineEdit()
        self.player_initiative_input = QLineEdit()
        self.monster_name_input = QLineEdit()
        self.monster_custom_name_input = QLineEdit()
        self.monster_count_input = QSpinBox()
        self.monster_hp_input = QLineEdit()
        self.monster_ac_input = QLineEdit()
        self.monster_initiative_input = QLineEdit()
        self.effect_name_input = QLineEdit()
        self.effect_duration_input = QSpinBox()
        self.damage_input = QSpinBox()
        self.temp_set_input = QSpinBox()
        self.heal_input = QSpinBox()
        self.round_label = QLabel("Раунд: 0")
        self.start_btn = QPushButton("Начать бой")
        self.table = QTableWidget(0, len(TABLE_HEADERS))
        self.remove_effect_name_input = QLineEdit()
        self.init_ui()
        self.state_exporter = BattleStateExporter(
            self.battle_engine,
            interval=0.5
        )

    def apply_theme(self):
        card_border = "#6A4A31"
        panel_bg = "#251A16"
        field_bg = "#31221B"
        header_bg = "#3A2920"

        self.setStyleSheet(
            """
            QWidget {
                background-color: #110C10;
                color: #E8D9C5;
            }
            QLabel {
                color: #E8D9C5;
            }
            QGroupBox {
                border: 1px solid %s;
                border-radius: 0px;
                margin-top: 12px;
                padding-top: 12px;
                background-color: %s;
                font-weight: bold;
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                left: 12px;
                padding: 0 5px;
                color: #F0E2C8;
                background-color: %s;
            }
            QLineEdit, QSpinBox, QComboBox {
                background-color: %s;
                border: 1px solid %s;
                border-radius: 0px;
                padding: 5px 7px;
                color: #E8D9C5;
                selection-background-color: #E2BE6F;
                selection-color: #1A130F;
            }
            QPushButton, QToolButton {
                background-color: %s;
                border: 1px solid %s;
                border-radius: 0px;
                padding: 5px 10px;
                color: #F2E4CC;
                min-height: 28px;
            }
            QPushButton:hover, QToolButton:hover {
                background-color: #4B3529;
            }
            QPushButton:pressed, QToolButton:pressed {
                background-color: #281C16;
            }
            QTableWidget {
                background-color: %s;
                alternate-background-color: %s;
                border: 1px solid %s;
                border-radius: 0px;
                gridline-color: %s;
                color: #E8D9C5;
                selection-background-color: #E2BE6F;
                selection-color: #1A130F;
            }
            QHeaderView::section {
                background-color: %s;
                color: #F0E2C8;
                border: 0;
                border-bottom: 1px solid %s;
                padding: 6px;
                font-weight: bold;
            }
            """ % (
                card_border,
                panel_bg,
                header_bg,
                field_bg,
                card_border,
                field_bg,
                card_border,
                panel_bg,
                field_bg,
                card_border,
                card_border,
                header_bg,
                card_border,
            )
        )

    def apply_master_font(self):
        font_path = Path(__file__).resolve().parents[1] / "Pui" / "fonts" / "8bitoperator_jve.ttf"
        if not font_path.exists():
            return

        font_id = QFontDatabase.addApplicationFont(str(font_path))
        if font_id == -1:
            return

        families = QFontDatabase.applicationFontFamilies(font_id)
        if not families:
            return

        master_font = QFont(families[0])
        master_font.setPointSize(11)
        self.setFont(master_font)

    def init_ui(self):
        self.apply_master_font()
        self.apply_theme()
        layout = QVBoxLayout()
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)

        title_label = QLabel("Панель мастера боя")
        title_font = QFont()
        title_font.setPointSize(16)
        title_font.setBold(True)
        title_label.setFont(title_font)
        title_label.setStyleSheet("color: #E9DCCB;")
        layout.addWidget(title_label)

        controls_layout = QHBoxLayout()
        self.round_label = QLabel("Раунд боя: 0")
        round_font = QFont()
        round_font.setPointSize(12)
        self.round_label.setFont(round_font)
        self.round_label.setStyleSheet("color: #C2B1A0;")
        controls_layout.addWidget(self.round_label)
        controls_layout.addStretch(1)

        self.start_btn.clicked.connect(self.start_battle)
        controls_layout.addWidget(self.start_btn)
        next_btn = QPushButton("Перейти к следующему ходу")
        next_btn.clicked.connect(self.next_turn)
        end_btn = QPushButton("Завершить бой")
        end_btn.clicked.connect(self.end_battle)
        controls_layout.addWidget(next_btn)
        controls_layout.addWidget(end_btn)
        layout.addLayout(controls_layout)

        setup_row = QHBoxLayout()
        setup_row.setSpacing(12)

        player_group = QGroupBox("Добавление игрока")
        player_layout = QGridLayout()
        self.player_name_input.setPlaceholderText("Имя игрока")
        self.player_initiative_input.setPlaceholderText("Значение инициативы")
        add_player_btn = QPushButton("Добавить игрока")
        add_player_btn.clicked.connect(self.add_player)
        player_layout.addWidget(QLabel("Имя игрока"), 0, 0)
        player_layout.addWidget(self.player_name_input, 0, 1)
        player_layout.addWidget(QLabel("Инициатива"), 1, 0)
        player_layout.addWidget(self.player_initiative_input, 1, 1)
        player_layout.addWidget(add_player_btn, 2, 0, 1, 2)
        player_group.setLayout(player_layout)
        setup_row.addWidget(player_group, 1)

        monster_group = QGroupBox("Добавление монстров")
        monster_layout = QGridLayout()

        self.monster_name_input.setPlaceholderText("Название монстра")
        self.monster_custom_name_input.setPlaceholderText("Кастомное имя")
        self.monster_count_input.setRange(1, 99)
        self.monster_count_input.setValue(1)
        self.monster_hp_input.setPlaceholderText("HP")
        self.monster_ac_input.setPlaceholderText("AC")
        self.monster_initiative_input.setPlaceholderText("Инициатива")
        add_monster_btn = QPushButton("Добавить монстров")
        add_monster_btn.clicked.connect(self.add_monsters)
        monster_layout.addWidget(QLabel("Название монстра"), 0, 0)
        monster_layout.addWidget(self.monster_name_input, 0, 1)
        monster_layout.addWidget(QLabel("Кастомное имя"), 0, 2)
        monster_layout.addWidget(self.monster_custom_name_input, 0, 3)
        monster_layout.addWidget(QLabel("Количество"), 1, 0)
        monster_layout.addWidget(self.monster_count_input, 1, 1)
        monster_layout.addWidget(QLabel("Количество HP"), 1, 2)
        monster_layout.addWidget(self.monster_hp_input, 1, 3)
        monster_layout.addWidget(QLabel("Класс брони"), 2, 0)
        monster_layout.addWidget(self.monster_ac_input, 2, 1)
        monster_layout.addWidget(QLabel("Инициатива"), 2, 2)
        monster_layout.addWidget(self.monster_initiative_input, 2, 3)
        monster_layout.addWidget(add_monster_btn, 3, 0, 1, 4)
        monster_group.setLayout(monster_layout)
        setup_row.addWidget(monster_group, 2)

        player_ui_container = QFrame()
        player_ui_container.setFrameShape(QFrame.StyledPanel)
        player_ui_container.setSizePolicy(QSizePolicy.Maximum, QSizePolicy.Maximum)
        player_ui_container.setStyleSheet("QFrame { border-radius: 6px; }")
        player_ui_layout = QVBoxLayout()
        player_ui_layout.setContentsMargins(8, 6, 8, 8)

        player_ui_toggle = QToolButton()
        player_ui_toggle.setText("Player UI")
        player_ui_toggle.setCheckable(True)
        player_ui_toggle.setChecked(False)
        player_ui_toggle.setToolButtonStyle(Qt.ToolButtonTextBesideIcon)
        player_ui_toggle.setArrowType(Qt.RightArrow)
        player_ui_toggle.setSizePolicy(QSizePolicy.Maximum, QSizePolicy.Fixed)

        player_ui_panel = QFrame()
        player_ui_panel.setVisible(False)
        panel_layout = QVBoxLayout()
        panel_layout.setContentsMargins(0, 6, 0, 0)

        open_here_btn = QPushButton("Открыть на этом мониторе")
        open_other_btn = QPushButton("Открыть на другом мониторе")
        borderless_btn = QPushButton("Окно/Без рамок")
        fullscreen_btn = QPushButton("Полный экран/Окно")
        open_here_btn.clicked.connect(self.open_player_ui_current_monitor)
        open_other_btn.clicked.connect(self.open_player_ui_other_monitor)
        borderless_btn.clicked.connect(self.toggle_player_ui_borderless)
        fullscreen_btn.clicked.connect(self.toggle_player_ui_fullscreen)
        for w in [open_here_btn, open_other_btn, borderless_btn, fullscreen_btn]:
            panel_layout.addWidget(w)
        panel_layout.addStretch(1)
        player_ui_panel.setLayout(panel_layout)

        player_ui_layout.addWidget(player_ui_toggle)
        player_ui_layout.addWidget(player_ui_panel)
        player_ui_container.setLayout(player_ui_layout)
        setup_row.addWidget(player_ui_container)

        layout.addLayout(setup_row)

        def _toggle_player_panel(checked):
            player_ui_panel.setVisible(checked)
            player_ui_toggle.setArrowType(Qt.DownArrow if checked else Qt.RightArrow)

        player_ui_toggle.toggled.connect(_toggle_player_panel)
        self.table.setHorizontalHeaderLabels(TABLE_HEADERS)
        self.table.setAlternatingRowColors(True)
        self.table.verticalHeader().setVisible(False)
        self.table.horizontalHeader().setStretchLastSection(True)
        self.table.horizontalHeader().setSectionResizeMode(1, QHeaderView.Stretch)
        self.table.setColumnWidth(0, 20)
        self.table.setColumnWidth(2, 110)
        self.table.setColumnWidth(3, 130)
        self.table.setColumnWidth(4, 115)
        self.table.setColumnWidth(5, 110)
        self.table.setColumnWidth(6, 200)
        self.table.setColumnWidth(7, 125)
        self.table.setColumnWidth(8, 150)
        self.table.setColumnWidth(9, 170)
        layout.addWidget(self.table)

        bottom_row = QHBoxLayout()
        bottom_row.setSpacing(12)

        effect_group = QGroupBox("Эффекты")
        effect_layout = QGridLayout()

        self.effect_name_input.setPlaceholderText("Название эффекта")
        self.effect_duration_input.setRange(0, 999)
        self.effect_duration_input.setSpecialValueText("вечный")
        add_effect_btn = QPushButton("Добавить эффект")
        add_effect_btn.clicked.connect(self.add_effect)
        self.remove_effect_name_input.setPlaceholderText("Название эффекта для удаления")
        remove_effect_btn = QPushButton("Убрать эффект")
        remove_effect_btn.clicked.connect(
            lambda: self.remove_effect(self.remove_effect_name_input.text().strip())
        )
        effect_layout.addWidget(QLabel("Название эффекта"), 0, 0)
        effect_layout.addWidget(self.effect_name_input, 0, 1)
        effect_layout.addWidget(QLabel("Длительность эффекта"), 1, 0)
        effect_layout.addWidget(self.effect_duration_input, 1, 1)
        effect_layout.addWidget(add_effect_btn, 2, 0, 1, 2)
        effect_layout.addWidget(QLabel("Удалить эффект по названию"), 3, 0)
        effect_layout.addWidget(self.remove_effect_name_input, 3, 1)
        effect_layout.addWidget(remove_effect_btn, 4, 0, 1, 2)
        effect_group.setLayout(effect_layout)
        bottom_row.addWidget(effect_group, 1)

        action_group = QGroupBox("Действия с выбранными участниками")
        action_layout = QGridLayout()
        self.damage_input.setRange(1, 999)
        self.damage_input.setValue(1)
        dmg_btn = QPushButton("Нанести урон")
        dmg_btn.clicked.connect(self.attack)

        self.heal_input.setRange(1, 999)
        self.heal_input.setValue(1)
        heal_btn = QPushButton("Восстановить здоровье")
        heal_btn.clicked.connect(self.heal)

        self.temp_set_input.setRange(0, 999)
        self.temp_set_input.setValue(0)
        temp_set_btn = QPushButton("Выдать временные HP")
        temp_set_btn.clicked.connect(self.set_temp_hp)

        action_layout.addWidget(QLabel("Количество урона"), 0, 0)
        action_layout.addWidget(self.damage_input, 0, 1)
        action_layout.addWidget(dmg_btn, 0, 2)
        action_layout.addWidget(QLabel("Количество лечения"), 1, 0)
        action_layout.addWidget(self.heal_input, 1, 1)
        action_layout.addWidget(heal_btn, 1, 2)
        action_layout.addWidget(QLabel("Количество временных HP"), 2, 0)
        action_layout.addWidget(self.temp_set_input, 2, 1)
        action_layout.addWidget(temp_set_btn, 2, 2)
        action_group.setLayout(action_layout)
        bottom_row.addWidget(action_group, 2)

        layout.addLayout(bottom_row)

        self.setLayout(layout)

    @property
    def get_selected_combatants(self):
            selected = []
            for i in range(self.table.rowCount()):
                cb = self.table.cellWidget(i, 0)
                if cb and cb.isChecked():
                    selected.append(self.battle_engine.combatants[i])
            return selected

    def attack(self):
            damage = self.damage_input.value()
            for combatant in self.get_selected_combatants:
                combatant.take_damage(damage)
            self.refresh_table()

    def heal(self):
        amount = self.heal_input.value()
        for combatant in self.get_selected_combatants:
            combatant.heal(amount)
        self.refresh_table()

    def set_temp_hp(self):
        amount = self.temp_set_input.value()
        for combatant in self.get_selected_combatants:
            combatant.add_temp_hp(amount)
        self.refresh_table()

    def add_player(self):
        name = self.player_name_input.text().strip()
        if not name:
            return
        initiative_text = self.player_initiative_input.text().strip()
        initiative = int(initiative_text) if initiative_text else None
        player = self.factory.create_player(
            name=name,
            initiative=initiative
        )
        self.battle_engine.add_combatant(player)
        self.refresh_table()
        self.player_name_input.clear()
        self.player_initiative_input.clear()

    def add_monsters(self):
        name = self.monster_name_input.text().strip()
        if not name:
            return
        count = self.monster_count_input.value()
        custom_name = self.monster_custom_name_input.text().strip() or None
        hp_input = self.monster_hp_input.text().strip() or None
        ac = int(self.monster_ac_input.text()) if self.monster_ac_input.text().strip() else None
        initiative = int(
            self.monster_initiative_input.text()) if self.monster_initiative_input.text().strip() else None
        monsters = self.factory.create_monster(
            name=name,
            count=count,
            initiative=initiative,
            custom_name=custom_name,
            ac=ac,
            hp_input=hp_input
        )
        for m in monsters:
            self.battle_engine.add_combatant(m)
        self.refresh_table()
        self.monster_name_input.clear()
        self.monster_custom_name_input.clear()
        self.monster_count_input.setValue(1)
        self.monster_hp_input.clear()
        self.monster_ac_input.clear()
        self.monster_initiative_input.clear()

    def start_battle(self):
        self.battle_engine.start_combat()
        self.state_exporter.start()
        self.round_counter = self.battle_engine.round
        self.current_initiative_group = self.battle_engine.current_initiative_group
        self.round_label.setText(f"Раунд боя: {self.round_counter}")
        self.refresh_table()

    def next_turn(self):
        group = self.battle_engine.next_turn()
        if not group:
            return

        self.current_initiative_group = group[0].initiative
        self.round_counter = self.battle_engine.round
        self.round_label.setText(f"Раунд боя: {self.round_counter}")

        self.refresh_table()

    def add_effect(self):
        name = self.effect_name_input.text().strip()
        if not name:
            return
        dur = self.effect_duration_input.value()
        dur = None if dur == 0 else dur
        selected = self.get_selected_combatants
        for combat in selected:
            effects = combat.effects.setdefault("custom_effects", {})
            effects[name] = {
                "value": True,
                "duration": dur,
                "applied_round": self.battle_engine.round
            }
        self.refresh_table()

    def remove_effect(self, name):
        if not name:
            return
        selected = self.get_selected_combatants
        if selected:
            for combat in selected:
                effects = combat.effects.get("custom_effects", {})
                if name in effects:
                    del effects[name]
        else:
            for combat in self.battle_engine.combatants:
                effects = combat.effects.get("custom_effects", {})
                if name in effects:
                    del effects[name]
        self.refresh_table()
        self.remove_effect_name_input.clear()

    def refresh_table(self):
        self.table.setRowCount(0)
        state_mapping = {
            "alive": "Жив",
            "unconscious": "Без сознания",
            "dead": "Мертв",
            "left": "Покинул бой"
        }
        for i, c in enumerate(self.battle_engine.combatants):
            self.table.insertRow(i)
            cb = QCheckBox()
            self.table.setCellWidget(i, 0, cb)
            self.table.setItem(i, 1, QTableWidgetItem(str(c.custom_name or c.name)))
            self.table.setItem(i, 2, QTableWidgetItem(str(c.hp)))
            hp_value = "-" if c.hp is None else str(c.hp)
            temp_hp_value = "-" if c.hp is None else str(c.temp_hp)
            ac_value = "-" if c.ac is None else str(c.ac)
            self.table.setItem(i, 2, QTableWidgetItem(hp_value))
            self.table.setItem(i, 3, QTableWidgetItem(temp_hp_value))
            self.table.setItem(i, 4, QTableWidgetItem(ac_value))
            effs_list = []
            custom_effects = c.effects.get("custom_effects", {})
            for eff_name, eff_data in custom_effects.items():
                dur = eff_data["duration"]
                if dur is None:
                    effs_list.append(f"{eff_name}")
                else:
                    effs_list.append(f"{eff_name} ({dur})")
            self.table.setItem(i, 6, QTableWidgetItem(", ".join(effs_list)))
            conc_cb = QCheckBox()
            conc_cb.setChecked(c.has_concentration())
            conc_cb.stateChanged.connect(lambda state, combat=c: self.toggle_concentration(combat, state))

            self.table.setCellWidget(i, 7, conc_cb)
            inc_cb = QCheckBox()
            inc_cb.setChecked(c.incapacitated)
            inc_cb.stateChanged.connect(lambda state, combat=c: self.toggle_incapacitated(combat, state))
            self.table.setCellWidget(i, 8, inc_cb)
            state_cb = QComboBox()
            state_cb.addItems(list(state_mapping.values()))
            state_cb.setCurrentText(state_mapping.get(c.state, "Жив"))
            state_cb.currentTextChanged.connect(lambda text, combat=c: self.change_state(combat, text))
            self.table.setCellWidget(i, 9, state_cb)
            current_init = self.current_initiative_group
            is_current = current_init is not None and c.initiative == current_init
            color = Qt.yellow if is_current else Qt.white
            for col in range(1, 6):
                item = self.table.item(i, col)
                if item:
                    item.setForeground(color)

    def toggle_concentration(self, combat, state):
        checked = bool(state)
        if combat.incapacitated:
            checked = False

        has_concentration = combat.has_concentration()
        if checked and not has_concentration:
            self.battle_engine.add_concentration(combat)
        elif not checked and has_concentration:
            self.battle_engine.remove_concentration(combat)

    def change_state(self, combat, text):
        mapping = {
            "Мертв": "dead",
            "Без сознания": "unconscious",
            "Покинул бой": "left",
            "Жив": "alive"
        }
        new_state = mapping.get(text)
        if new_state:
            self.battle_engine.set_state(combat, new_state)
            self.refresh_table()

    def toggle_incapacitated(self, combatant, state):
        checked = bool(state)
        combatant.manually_disabled = checked
        self.refresh_table()

    def end_battle(self):
        self.battle_engine.end_combat()
        self.state_exporter.stop()
        self.battle_engine.combatants.clear()
        self.current_initiative_group = None
        self.round_counter = 0
        self.round_label.setText(f"Раунд боя: {self.round_counter}")
        self.refresh_table()

    def open_player_ui_current_monitor(self):
        print("TODO: открыть Player UI на текущем мониторе")

    def open_player_ui_other_monitor(self):
        print("TODO: открыть Player UI на другом мониторе")

    def toggle_player_ui_borderless(self):
        print("TODO: переключить режим окно/без рамок для Player UI")

    def toggle_player_ui_fullscreen(self):
        print("TODO: переключить режим полный экран/окно для Player UI")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MasterUI()
    window.show()
    sys.exit(app.exec())
