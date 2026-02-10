# DM UI modes

Модуль `DMui` теперь поддерживает два параллельных интерфейса мастера:

- `legacy` — существующий интерфейс на Qt Widgets (`MasterUI`).
- `qml_parallel` — альтернативный интерфейс полностью на QML.

## Запуск

Из корня репозитория:

```bash
python -m DMui.run_master_ui --ui-mode legacy
python -m DMui.run_master_ui --ui-mode qml_parallel
```

По умолчанию используется безопасный режим `legacy`.

Старый вариант запуска также продолжает работать:

```bash
python DMui/master_ui.py
```
