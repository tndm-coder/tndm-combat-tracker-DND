import json
import html
import sys
from pathlib import Path

from PySide6.QtCore import QAbstractListModel, QTimer, Qt, QObject, Property, Signal
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtGui import QGuiApplication


class CombatantModel(QAbstractListModel):
    NAME_ROLE = Qt.UserRole + 1
    HP_ROLE = Qt.UserRole + 2
    MAX_HP_ROLE = Qt.UserRole + 3
    TEMP_HP_ROLE = Qt.UserRole + 4
    STATE_ROLE = Qt.UserRole + 5
    ACTIVE_ROLE = Qt.UserRole + 6
    EFFECTS_ROLE = Qt.UserRole + 7
    CUSTOM_EFFECTS_ROLE = Qt.UserRole + 8
    KIND_ROLE = Qt.UserRole + 9
    DISPLAY_NAME_ROLE = Qt.UserRole + 10
    ID_ROLE = Qt.UserRole + 11

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = []

    def rowCount(self, parent=None):
        return len(self._items)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None
        item = self._items[index.row()]
        if role == self.NAME_ROLE:
            return item["name"]
        if role == self.HP_ROLE:
            return item["hp"]
        if role == self.MAX_HP_ROLE:
            return item["max_hp"]
        if role == self.TEMP_HP_ROLE:
            return item["temp_hp"]
        if role == self.STATE_ROLE:
            return item["state"]
        if role == self.ACTIVE_ROLE:
            return item["active"]
        if role == self.EFFECTS_ROLE:
            return item["effects"]
        if role == self.CUSTOM_EFFECTS_ROLE:
            return item["custom_effects"]
        if role == self.KIND_ROLE:
            return item["kind"]
        if role == self.DISPLAY_NAME_ROLE:
            return item["display_name"]
        if role == self.ID_ROLE:
            return item["id"]
        return None

    def roleNames(self):
        return {
            self.NAME_ROLE: b"name",
            self.HP_ROLE: b"hp",
            self.MAX_HP_ROLE: b"max_hp",
            self.TEMP_HP_ROLE: b"temp_hp",
            self.STATE_ROLE: b"state",
            self.ACTIVE_ROLE: b"is_active",
            self.EFFECTS_ROLE: b"effects",
            self.CUSTOM_EFFECTS_ROLE: b"custom_effects",
            self.KIND_ROLE: b"kind",
            self.DISPLAY_NAME_ROLE: b"display_name",
            self.ID_ROLE: b"id",
        }

    @staticmethod
    def _build_item(combatant, active_ids):
        effects = combatant.get("effects", {})
        return {
            "id": combatant.get("id"),
            "name": combatant.get("name", "—"),
            "hp": combatant.get("hp"),
            "max_hp": combatant.get("max_hp"),
            "temp_hp": combatant.get("temp_hp", 0),
            "state": combatant.get("state", "alive"),
            "active": combatant.get("id") in active_ids,
            "effects": effects,
            "custom_effects": combatant.get("custom_effects", {}),
            "kind": combatant.get("kind", "combatant"),
            "display_name": combatant.get("display_name", combatant.get("name", "—")),
        }

    def _full_reset(self, combatants, active_ids):
        self.beginResetModel()
        self._items = [self._build_item(combatant, active_ids) for combatant in combatants]
        self.endResetModel()

    def update_items(self, combatants, active_ids):
        # Preserve delegates (and ongoing QML animations) by avoiding full model
        # resets when the combatant list shape is unchanged.
        if len(combatants) != len(self._items):
            self._full_reset(combatants, active_ids)
            return

        incoming_ids = [combatant.get("id") for combatant in combatants]
        current_ids = [item.get("id") for item in self._items]
        if incoming_ids != current_ids:
            self._full_reset(combatants, active_ids)
            return

        for row, combatant in enumerate(combatants):
            updated_item = self._build_item(combatant, active_ids)
            if self._items[row] != updated_item:
                self._items[row] = updated_item
                model_index = self.index(row, 0)
                self.dataChanged.emit(model_index, model_index, list(self.roleNames().keys()))


class PlayerUiState(QObject):
    runningChanged = Signal()
    roundChanged = Signal()
    logLinesChanged = Signal()

    def __init__(self, model, parent=None):
        super().__init__(parent)
        self._running = False
        self._round = 0
        self._model = model
        self._prev_payload = None
        self._active_ids = []
        self._log_lines = ["", "", ""]
        self._clear_logs_timer = QTimer(self)
        self._clear_logs_timer.setSingleShot(True)
        self._clear_logs_timer.timeout.connect(self._clear_logs)

    @Property(bool, notify=runningChanged)
    def running(self):
        return self._running

    @Property(int, notify=roundChanged)
    def round(self):
        return self._round

    @Property(QObject, constant=True)
    def model(self):
        return self._model

    @Property("QVariantList", notify=logLinesChanged)
    def logLines(self):
        return self._log_lines

    @staticmethod
    def _display_name(combatant):
        return combatant.get("display_name") or combatant.get("name") or "—"

    @staticmethod
    def _name_markup(name):
        safe_name = html.escape(name)
        return f'<span style="color:#E0B26B;">{safe_name}</span>'

    def _actor_log(self, name, suffix):
        self._push_log(f"{self._name_markup(name)} {suffix}")

    def _push_log(self, message):
        if not message:
            return
        self._log_lines = [message] + self._log_lines[:2]
        self.logLinesChanged.emit()

    def _clear_logs(self):
        self._log_lines = ["", "", ""]
        self.logLinesChanged.emit()

    def _collect_diff_logs(self, payload):
        if self._prev_payload is None:
            return

        prev_combatants = {
            c.get("id"): c
            for c in self._prev_payload.get("combatants", [])
        }
        curr_combatants = {
            c.get("id"): c
            for c in payload.get("combatants", [])
        }

        for combatant_id, current in curr_combatants.items():
            previous = prev_combatants.get(combatant_id)
            if previous is None:
                continue

            name = self._display_name(current)
            prev_state = previous.get("state")
            curr_state = current.get("state")
            state_changed = prev_state != curr_state

            if state_changed:
                if curr_state == "dead":
                    self._actor_log(name, "погибает")
                elif curr_state == "unconscious":
                    self._actor_log(name, "без сознания")
                elif curr_state == "left":
                    self._actor_log(name, "покидает бой")
                elif curr_state == "alive":
                    if prev_state == "dead":
                        self._actor_log(name, "воскресает")
                    elif prev_state == "left":
                        self._actor_log(name, "возвращается в бой")
                    else:
                        self._actor_log(name, "приходит в себя")
                else:
                    self._actor_log(name, f"состояние {curr_state}")

            prev_hp = previous.get("hp")
            curr_hp = current.get("hp")
            hp_changed = isinstance(prev_hp, int) and isinstance(curr_hp, int) and curr_hp != prev_hp

            prev_temp = previous.get("temp_hp", 0)
            curr_temp = current.get("temp_hp", 0)
            temp_changed = isinstance(prev_temp, int) and isinstance(curr_temp, int) and curr_temp != prev_temp

            if not state_changed and (hp_changed or temp_changed):
                if isinstance(curr_hp, int) and isinstance(prev_hp, int) and curr_hp > prev_hp:
                    self._actor_log(name, "восстанавливает HP")
                elif isinstance(curr_temp, int) and isinstance(prev_temp, int) and curr_temp > prev_temp:
                    self._actor_log(name, "получает временные HP")
                else:
                    self._actor_log(name, "получает урон")
                    if (
                        isinstance(prev_temp, int)
                        and isinstance(curr_temp, int)
                        and prev_temp > 0
                        and curr_temp == 0
                    ):
                        self._actor_log(name, "теряет временные HP")

            prev_effects = previous.get("effects", {})
            curr_effects = current.get("effects", {})
            prev_concentration = bool(prev_effects.get("concentration"))
            curr_concentration = bool(curr_effects.get("concentration"))
            if not state_changed and prev_concentration != curr_concentration:
                if curr_concentration:
                    self._actor_log(name, "концентрируется на заклинании")
                else:
                    self._actor_log(name, "теряет концентрацию")

            prev_incapacitated = bool(prev_effects.get("incapacitated"))
            curr_incapacitated = bool(curr_effects.get("incapacitated"))
            if not state_changed and prev_incapacitated != curr_incapacitated:
                if curr_incapacitated:
                    self._actor_log(name, "теряет возможность действовать")
                else:
                    self._actor_log(name, "снова может действовать")

            prev_custom = previous.get("custom_effects", {})
            curr_custom = current.get("custom_effects", {})
            prev_names = set(prev_custom.keys())
            curr_names = set(curr_custom.keys())
            for effect_name in sorted(curr_names - prev_names):
                self._actor_log(name, f"получает эффект {html.escape(effect_name)}")
            for effect_name in sorted(prev_names - curr_names):
                self._actor_log(name, f"теряет эффект {html.escape(effect_name)}")

    def update_state(self, payload):
        running = bool(payload.get("running", False))
        round_value = int(payload.get("round", 0))

        was_running = self._running
        self._collect_diff_logs(payload)

        if running and not was_running:
            if self._clear_logs_timer.isActive():
                self._clear_logs_timer.stop()
            self._push_log("Бой начался")
        elif not running and was_running:
            self._push_log("Бой закончен")
            self._clear_logs_timer.start(10000)

        if self._running != running:
            self._running = running
            self.runningChanged.emit()
        if self._round != round_value:
            self._round = round_value
            self.roundChanged.emit()

        self._active_ids = list(payload.get("active_ids", []) or [])
        self._prev_payload = payload


def load_state(path):
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None
    if not isinstance(data, dict):
        return None
    return data


def main():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    model = CombatantModel()
    state = PlayerUiState(model)

    base_dir = Path(__file__).resolve().parent
    state_path = base_dir / "battle_state.json"
    last_payload = None

    def tick():
        nonlocal last_payload
        payload = load_state(state_path)
        if payload is None:
            if last_payload is None:
                state.update_state({"running": False, "round": 0})
                model.update_items([], [])
            return
        last_payload = payload
        state.update_state(payload)
        combatants = payload.get("combatants", [])
        active_ids = payload.get("active_ids", [])
        model.update_items(combatants, active_ids)

    timer = QTimer()
    timer.setInterval(250)
    timer.timeout.connect(tick)
    timer.start()

    engine.rootContext().setContextProperty("playerState", state)
    engine.rootContext().setContextProperty("playerModel", model)
    engine.load(base_dir / "main.qml")

    if not engine.rootObjects():
        sys.exit(1)
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
