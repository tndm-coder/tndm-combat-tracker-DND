# tndm-combat-tracker-DND

Трекер боёв для **Dungeons & Dragons 5e** с разделением интерфейсов:

- **DM UI** — рабочая панель мастера (инициатива, состояния, эффекты, управление ходом).
- **Player UI** — экран для игроков с актуальным состоянием боя в реальном времени.

Проект помогает вести бой быстро и прозрачно: мастер управляет механикой, игроки видят только нужную им информацию.

---

## Основные возможности

- Добавление игроков и монстров.
- Инициатива с группировкой существ с одинаковым значением.
- Пошаговое ведение боя по ходам и раундам.
- Управление состояниями: **жив / без сознания / мёртв / покинул бой**.
- Поддержка концентрации, недееспособности и пользовательских эффектов.
- Учет урона, лечения и временных HP.
- Экспорт текущего состояния боя в JSON для Player UI.
- Бестиарий SRD (RU/EN) в репозитории.

---

## Структура проекта

```text
.
├── DMui/
│   ├── master_ui.py
│   └── combatant_card.py
├── Pui/
│   ├── player_ui.py
│   ├── main.qml
│   ├── battle_state.json
│   ├── index.html
│   ├── app.js
│   └── style.css
├── battle_engine.py
├── battle_state_exporter.py
├── combatants.py
├── combatant_factory.py
├── dice_roll.py
├── monster_creator.py
├── srd_5e_monsters_ru.json
└── srd_5e_monsters.json
```

---

## Требования

- Python **3.11+**
- `pip`
- `PySide6`

---

## Установка

```bash
python -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install --upgrade pip
pip install PySide6
```

---

## Запуск

### 1. Панель мастера (DM UI)

```bash
python DMui/master_ui.py
```

### 2. Экран игроков (Player UI)

Запустите в отдельном терминале:

```bash
python Pui/player_ui.py
```

---

## Конфигурация экспорта состояния

`Player UI` читает файл состояния боя `battle_state.json`, который пишет `BattleStateExporter`.

Проверьте значения в `battle_state_exporter.py`:

- `EXPORT_DIR`
- `EXPORT_FILE`

Если в файле указан путь разработчика, замените его на ваш локальный путь к папке `Pui`, например:

```python
EXPORT_DIR = r"/workspace/tndm-combat-tracker-DND/Pui"
```

После этого `Pui/player_ui.py` будет получать актуальные данные боя.

---

## Базовый сценарий работы

1. Запустите `DMui/master_ui.py`.
2. Добавьте игроков и монстров.
3. Нажмите **«Начать бой»**.
4. Переключайте ход кнопкой **«Перейти к следующему ходу»**.
5. Обновляйте HP, состояния и эффекты участников.
6. Следите за отображением на `Pui/player_ui.py`.

---

## Web-вариант Player UI (опционально)

В папке `Pui` есть веб-вариант (`index.html`, `app.js`, `style.css`), который читает `battle_state.json` через HTTP.

Локальный запуск:

```bash
cd Pui
python -m http.server 8000
```

Откройте в браузере:

```text
http://localhost:8000
```

---

## Быстрая проверка

```bash
python -m compileall DMui Pui battle_engine.py combatants.py combatant_factory.py battle_state_exporter.py dice_roll.py monster_creator.py
```

---

## Планируемые улучшения

- Вынести настройки в `.env` или `config.yaml`.
- Добавить сохранение/загрузку сессии боя.
- Добавить сетевую синхронизацию DM UI ↔ Player UI.
- Закрыть TODO по открытию Player UI на другом мониторе.
- Добавить тесты на `BattleEngine` и `dice_roll`.

---

## Лицензия

Лицензия пока не добавлена. При необходимости создайте файл `LICENSE` (например, MIT).
