import sys
import os
import numpy as np

from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QTimer, QObject, pyqtSignal, pyqtSlot

from pyModbusTCP.client import ModbusClient


class Backend(QObject):

    currVelocity = pyqtSignal(int)
    currPosition = pyqtSignal(int)

    def __init__(self):
        super().__init__()
        self.getDataTimer = QTimer()
        self.getDataTimer.setInterval(10)
        self.getDataTimer.timeout.connect(self.currentPosition)
        self.getDataTimer.timeout.connect(self.currentVelocity)

    @pyqtSlot(int)
    def setPosition(self, position):
        positionValue = np.ushort(position)
        client.write_single_register(16, positionValue)

    @pyqtSlot(int)
    def setVelocity(self, velocity):
        velocityValue = np.ushort(velocity)
        client.write_single_register(17, velocityValue)

    def currentVelocity(self):
        readData = client.read_holding_registers(17, reg_nb=1)
        self.currVelocity.emit(readData[0])

    def currentPosition(self):
        readData = client.read_holding_registers(18, reg_nb=1)
        self.currPosition.emit(readData[0])

    @pyqtSlot()
    def connect(self):
        self.getDataTimer.start()

    @pyqtSlot()
    def disconnect(self):
        self.getDataTimer.stop()


backend = Backend()

if __name__ == "__main__":

    os.environ['QT_QUICK_CONTROLS_STYLE'] = 'Imagine'
    app = QGuiApplication(sys.argv)

    client = ModbusClient(host="127.0.0.1", port=5502, unit_id=1,
                          auto_open=True, auto_close=True)

    engine = QQmlApplicationEngine()
    engine.quit.connect(app.quit)
    engine.load('main.qml')

    engine.rootObjects()[0].setProperty('backend', backend)

    sys.exit(app.exec())
