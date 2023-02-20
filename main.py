import sys
import os
from pathlib import Path
import numpy as np

from PyQt5 import QtGui
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtWidgets import QApplication
from PyQt5.QtCore import QCoreApplication, Qt, QTimer, QObject, pyqtSignal, QUrl, pyqtSlot

from pyModbusTCP.client import ModbusClient

CURRENT_DIRECTORY = Path(__file__).resolve().parent

HOST_ADDRES = "127.0.0.1"
PORT_ADDRESS = 5502
DEVICE_ID = 1

POSITION_ADDRESS = 16
VELOCITY_ADDRESS = 17
CURRENT_POSITION_ADDRESS = 18
CLIENT = ModbusClient(host=HOST_ADDRES, port=PORT_ADDRESS,
                      unit_id=DEVICE_ID, auto_open=False)


class Backend(QObject):

    currVelocity = pyqtSignal(int)
    currPosition = pyqtSignal(int)
    infoMsg = pyqtSignal(str, bool)
    connected = pyqtSignal(bool)

    def __init__(self):
        super().__init__()
        self.getDataTimer = QTimer()
        self.getDataTimer.setInterval(10)
        self.getDataTimer.timeout.connect(self.currentPosition)
        self.getDataTimer.timeout.connect(self.currentVelocity)

    @pyqtSlot(int)
    def setPosition(self, position):
        positionValue = np.ushort(position)
        if CLIENT.is_open:
            CLIENT.write_single_register(POSITION_ADDRESS, positionValue)
        else:
            self.infoMsg.emit(CLIENT.last_error_as_txt, False)

    @pyqtSlot(int)
    def setVelocity(self, velocity):
        velocityValue = np.ushort(velocity)
        if CLIENT.is_open:
            CLIENT.write_single_register(VELOCITY_ADDRESS, velocityValue)
        else:
            self.infoMsg.emit(CLIENT.last_error_as_txt, False)

    def currentVelocity(self):
        if CLIENT.is_open:
            readData = CLIENT.read_holding_registers(
                VELOCITY_ADDRESS, reg_nb=1)
            if readData:
                self.currVelocity.emit(readData[0])
        else:
            self.infoMsg.emit(CLIENT.last_error_as_txt, False)
            self.disconnect()

    def currentPosition(self):
        if CLIENT.is_open:
            readData = CLIENT.read_holding_registers(
                CURRENT_POSITION_ADDRESS, reg_nb=1)
            if readData:
                self.currPosition.emit(readData[0])
        else:
            self.infoMsg.emit(CLIENT.last_error_as_txt, False)
            self.disconnect()

    @pyqtSlot()
    def connect(self):
        CLIENT.open()
        if CLIENT.is_open:
            self.connected.emit(True)
            self.getDataTimer.start()
        else:
            self.connected.emit(False)
            self.infoMsg.emit(CLIENT.last_error_as_txt, False)

    @pyqtSlot()
    def disconnect(self):
        CLIENT.close()
        self.getDataTimer.stop()
        self.connected.emit(False)


backend = Backend()


def main():
    os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Imagine'

    app = QApplication(sys.argv)
    app.setWindowIcon(QtGui.QIcon('app.ico'))

    engine = QQmlApplicationEngine()

    filename = os.fspath(CURRENT_DIRECTORY / "main.qml")
    url = QUrl.fromLocalFile(filename)

    def handle_object_created(obj, obj_url):
        if obj is None and url == obj_url:
            QCoreApplication.exit(-1)

    engine.objectCreated.connect(
        handle_object_created, Qt.ConnectionType.QueuedConnection
    )
    engine.load(url)

    engine.rootObjects()[0].setProperty('backend', backend)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
