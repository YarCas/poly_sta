import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtLocation 5.15
import QtPositioning 5.15
import PolygonEditor 1.0
Item {
  id: root

  property alias polygonManager: manager

  PolygonManager {
    id: manager
  }

  RowLayout {
    anchors.fill: parent
    spacing: 0

    // Left sidebar with polygon properties
    Rectangle {
      Layout.preferredWidth: 300
      Layout.fillHeight: true
      color: "#f0f0f0"
      border.color: "#d0d0d0"
      border.width: 1

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Text {
          text: "Полигоны (" + manager.count + ")"
          font.bold: true
          font.pixelSize: 16
        }

        ListView {
          Layout.fillWidth: true
          Layout.fillHeight: true
          model: manager.polygons

          delegate: Rectangle {
            width: ListView.view.width
            height: 80
            color: modelData.selected ? "#e0e0ff" : "white"
            border.color: "#d0d0d0"
            border.width: 1

            MouseArea {
              anchors.fill: parent
              onClicked: manager.selectedPolygon = modelData
            }

            Column {
              anchors.left: parent.left
              anchors.leftMargin: 10
              anchors.verticalCenter: parent.verticalCenter

              Text { text: "ID: " + modelData.id }
              Text { text: "Площадь: " + modelData.area.toFixed(2) + " m²" }
              Text { text: "Точки: " + modelData.vertexCount }

              Rectangle {
                width: 20
                height: 20
                color: modelData.color
                border.color: "black"
                border.width: 1
              }
            }
          }
        }
      }
    }

    // Main content area
    ColumnLayout {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: 0

      // Top toolbar
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 50
        color: "#e0e0e0"
        border.color: "#d0d0d0"
        border.width: 1

        RowLayout {
          anchors.centerIn: parent
          spacing: 10

          Button {
            text: "+"
            font.pixelSize: 20
            onClicked: {
              if (map) {
                var center = map.center
                var widthMeters = map.visibleRegion.boundingGeoRectangle().width * 111320 * 2/3
                var heightMeters = map.visibleRegion.boundingGeoRectangle().height * 111320 * 2/3
                manager.createRectangularPolygon(center.latitude, center.longitude, widthMeters, heightMeters)
              }
            }
          }

          Button {
            text: "-"
            font.pixelSize: 20
            enabled: manager.selectedPolygon !== null
            onClicked: manager.removeSelectedPolygon()
          }
        }
      }

      // Map area
      Map {
        id: map
        Layout.fillWidth: true
        Layout.fillHeight: true
        plugin: Plugin { name: "osm" }
        center: QtPositioning.coordinate(59.9386, 30.3141)
        zoomLevel: 8
        copyrightsVisible: false

        layer {
                       enabled: true
                       samples: 8
                       smooth: true
                   }

        // MouseArea {
        //       anchors.fill: parent
        //       acceptedButtons: Qt.LeftButton | Qt.RightButton
        //       onWheel: (wheel) => {
        //           if (wheel.angleDelta.y > 0) map.zoomLevel += 0.5
        //           else map.zoomLevel -= 0.5
        //       }
        //       onPressed: (mouse) => {
        //           map.gesture.enabled = true
        //           lastX = mouse.x; lastY = mouse.y
        //       }
        //       onPositionChanged: (mouse) => {
        //           var dx = mouse.x - lastX
        //           var dy = mouse.y - lastY
        //           map.pan(-dx, -dy)
        //           lastX = mouse.x; lastY = mouse.y
        //       }

        //       property real lastX: -1
        //       property real lastY: -1
        //   }


        // Render polygons
        Repeater {
          z:20
          model: manager.polygons
          delegate: EditablePolygon {
            polygon: modelData
            map: map

          }
        }
      }
    }
  }
}
