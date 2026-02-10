import argparse
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication

from DMui.master_ui import MasterUI
from DMui.qml_parallel_bridge import QmlMasterBridge


def run_legacy_ui():
    app = QApplication(sys.argv)
    window = MasterUI()
    window.show()
    return app.exec()


def run_qml_parallel_ui():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    bridge = QmlMasterBridge()
    engine.rootContext().setContextProperty("dmBridge", bridge)

    qml_path = Path(__file__).resolve().parent / "qml_parallel" / "ParallelMasterScreen.qml"
    engine.load(str(qml_path))

    if not engine.rootObjects():
        return 1

    app.aboutToQuit.connect(bridge.shutdown)
    return app.exec()


def main():
    parser = argparse.ArgumentParser(description="DM интерфейс: legacy или parallel QML")
    parser.add_argument(
        "--ui-mode",
        choices=["legacy", "qml_parallel"],
        default="legacy",
        help="Режим интерфейса мастера",
    )
    args = parser.parse_args()

    if args.ui_mode == "qml_parallel":
        sys.exit(run_qml_parallel_ui())

    sys.exit(run_legacy_ui())


if __name__ == "__main__":
    main()
