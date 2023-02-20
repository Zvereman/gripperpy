import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

import "devices"
import "common"

Window {
    width: Screen.width * 0.3
    height: Screen.height * 0.4
    visible: true
    title: qsTr("Gripper")

    property int globalPosition: 0
    property QtObject backend

    StackView {
        id: globalStackView
        anchors.fill: parent
        initialItem: gripperComponent
    }

    Component {
        id: gripperComponent
        GripperPage { }
    }

    InfoPopup {
        id: globalInfoPopup
    }
}
