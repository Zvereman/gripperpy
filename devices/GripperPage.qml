import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
//import QtCharts 2.15

import "../common"

Page {
    id: root
    anchors.fill: parent

    property double sliderPosStep: 0.5
    property double sliderVelStep: 1

    // Min gripper position value
    property int minPositionValue: 0
    // Max gripper position value
    property int maxPositionValue: 1000
    // Min gripper velocity value in %
    property int minVelocityValue: 1
    // Max gripper velocity value in %
    property int maxVelocityValue: 100

    property bool inited: false

    property var items: new Array

    function gripperPosition() {
        let tempVal = 0
        tempVal = currentPosition.second.value - currentPosition.first.value
        return tempVal.toFixed(0)
    }

    RowLayout {
        anchors {
            fill: parent
            margins: 10
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            GText {
                text: qsTr("Gripper position:")
                Layout.fillWidth: true
            }

            Frame {
                ColumnLayout {
                    anchors {
                        fill: parent
                    }

                    RowLayout {
                        GText {
                            text: qsTr("Current gripper position:")
                        }
                        GText {
                            id: gripperCurrentPosition
                            Layout.fillWidth: true
                            Layout.alignment: Text.AlignLeft
                        }
                        Layout.fillWidth: true
                    }

                    GText {
                        text: qsTr("Set gripper position to: ") + gripperPosition()
                        Layout.fillWidth: true
                    }

                    RangeSlider {
                        id: currentPosition

                        from: minPositionValue
                        to: maxPositionValue

                        stepSize: sliderPosStep
                        snapMode: RangeSlider.SnapAlways

                        Layout.fillWidth: true

                        first.onMoved: {
                            second.value = maxPositionValue - first.value
                            backend.setPosition(gripperPosition())
                        }
                        second.onMoved: {
                            first.value = maxPositionValue - second.value
                            backend.setPosition(gripperPosition())
                        }
                    }
                }
                Layout.fillWidth: true
            }

            GText {
                text: qsTr("Gripper velocity:")
                Layout.fillWidth: true
            }

            Frame {
                ColumnLayout {
                    anchors {
                        fill: parent
                    }

                    GText {
                        text: qsTr("Set gripper velocity to: ") + gripperVelocity.value.toFixed(0) + "%"
                        Layout.fillWidth: true
                    }

                    Slider {
                        id: gripperVelocity

                        from: minVelocityValue
                        to: maxVelocityValue

                        stepSize: sliderVelStep
                        snapMode: RangeSlider.SnapAlways

                        Layout.fillWidth: true
                        onMoved: {
                            backend.setVelocity(gripperVelocity.value.toFixed(0))
                        }
                    }
                }
                Layout.fillWidth: true
            }

            Item {
                //spacer
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            GridLayout {
                rows: 2
                columns: 2

                Button {
                    text: qsTr("Connect Device")
                    Layout.fillWidth: true
                    onClicked: {
                        backend.connect()
                        //scopeView.getChartInfoTimer.start()
                    }
                }
                Button {
                    text: qsTr("Disconnect Device")
                    Layout.fillWidth: true
                    onClicked: {
                        backend.disconnect()
                        //scopeView.getChartInfoTimer.stop()
                        inited = false
                    }
                }

                Button {
                    text: qsTr("Open gripper")
                    Layout.fillWidth: true
                    onClicked: {
                        backend.setPosition(maxPositionValue)
                        currentPosition.setValues(minPositionValue, maxPositionValue)
                    }
                }
                Button {
                    text: qsTr("Close gripper")
                    Layout.fillWidth: true
                    onClicked: {
                        backend.setPosition(minPositionValue)
                        currentPosition.setValues(minPositionValue + (maxPositionValue / 2),
                                                  maxPositionValue / 2)
                    }
                }

                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width * 0.5

            GText {
                text: qsTr("Last 10 sec gripper positions:")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

//            ScopeView {
//                id: scopeView
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//            }
        }
    }

    Connections {
        target: backend

        function onCurrVelocity(currVel) {
            gripperVelocity.value = currVel
        }

        function onCurrPosition(currPos) {
            gripperCurrentPosition.text = currPos
            globalPosition = currPos

            let tempFirst = minPositionValue + ((maxPositionValue - currPos) / 2)
            let tempSecond = maxPositionValue - ((maxPositionValue - currPos) / 2)
            currentPosition.setValues(tempFirst, tempSecond)
        }
    }
}
