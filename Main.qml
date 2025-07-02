import QtQuick

Window {
    id: window
        width: 1200
        height: 800
        visible: true
        title: "Polygon Editor - Standalone"
        PolyView {
            anchors.fill: parent
        }
}
