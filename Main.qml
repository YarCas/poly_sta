import QtQuick
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    width: 1400
    height: 900
    visible: true
    title: "Polygon Editor - QGC Style"
    
    color: "#2c3e50"
    
    header: Rectangle {
        height: 32
        color: "#34495e"
        border.color: "#2c3e50"
        border.width: 1
        
        Text {
            anchors.centerIn: parent
            text: "Polygon Survey Editor"
            color: "#ecf0f1"
            font.pixelSize: 14
            font.bold: true
        }
        
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "#1a252f"
        }
    }
    
    PolyView {
        anchors.fill: parent
    }
}
