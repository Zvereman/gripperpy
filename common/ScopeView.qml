import QtQuick 2.15
import QtCharts 2.15

ChartView {
    id: chartView
    animationOptions: ChartView.SeriesAnimations

    property alias getChartInfoTimer: getChartInfoTimer

    property bool openGL: true

    property int minVal: 0
    property int maxPosVal: 1000
    property int maxValuesCount: 100

    property var min: new Date()
    property var max: new Date()

    function update() {
        max = new Date()
        var s = chartView.series("position");
        var valueY = globalPosition
        s.append(max, valueY)

        if (s.count > 11) {
            s.remove(0)
        }

        axisX.max = max
        min = max
        min.setSeconds(min.getSeconds() - 10)
        axisX.min = min
    }

    ValueAxis {
        id: axisY
        tickCount: 9
        min: minVal
        max: maxPosVal
    }

    DateTimeAxis {
        id: axisX
        format: "hh:mm:ss"
        tickCount: 10
        titleText: qsTr("Time")
    }

    LineSeries {
        id: positionSeries
        name: "position"
        axisX: axisX
        axisY: axisY
        useOpenGL: chartView.openGL
    }

    Timer {
        id: getChartInfoTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            update()
        }
    }
}
