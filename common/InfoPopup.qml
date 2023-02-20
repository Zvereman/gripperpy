import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: control

    property alias text: messageText.text
    property int duration: 1000
    property bool noError: false

    function showMessage(text, noErr) {
        if(control.opened)
            return

        messageText.text = text
        noError = noErr
        control.open()
    }

    Timer {
        id: timer
        running: control.opened
        interval: control.duration
        onTriggered: control.close()
    }

    onClosed: messageText.text = ""

    clip: true
    parent: Overlay.overlay
    width: parent.width

    leftPadding: 15; rightPadding: 15
    topPadding: 15
    bottomPadding: 15

    background: Rectangle { color: noError ? "green" : "red" }

    contentItem: RowLayout {

        Text {
            id: messageText

            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.fillWidth: true

            leftPadding: 15; rightPadding: 15
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap

            color: "white"
            font { pixelSize: 18; weight: Font.Medium }
        }
    }

    enter: Transition { NumberAnimation { property: "height"; from: 0; to: control.contentHeight + control.topPadding + control.bottomPadding; duration: 400; easing.type: Easing.InOutCirc } }
    exit: Transition { NumberAnimation { property: "height"; to: 0; duration: 400; easing.type: Easing.InOutCirc } }
}
