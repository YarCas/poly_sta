import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtLocation 5.15
import QtPositioning 5.15
import PolygonEditor 1.0
Item {
  id: root
  focus: true

  property alias polygonManager: manager
  
  function formatArea(areaInSquareMeters) {
    if (areaInSquareMeters < 1000) {
      return areaInSquareMeters.toFixed(1) + " m²"
    } else if (areaInSquareMeters < 1000000) {
      return (areaInSquareMeters / 1000).toFixed(2) + " тыс. m²"
    } else if (areaInSquareMeters < 1000000000) {
      return (areaInSquareMeters / 1000000).toFixed(2) + " км²"
    } else {
      return (areaInSquareMeters / 1000000).toFixed(0) + " км²"
    }
  }

  PolygonManager {
    id: manager
    
    onErrorOccurred: function(message) {
      errorDialog.errorMessage = message
      errorDialog.open()
    }
  }
  
  ErrorDialog {
    id: errorDialog
  }

  Keys.onPressed: function(event) {
    if (event.key === Qt.Key_Delete && manager.selectedPolygon !== null) {
      manager.removeSelectedPolygon()
      event.accepted = true
    } else if (event.key === Qt.Key_Escape && manager.selectedPolygon !== null) {
      manager.selectedPolygon = null
      event.accepted = true
    }
  }

  RowLayout {
    anchors.fill: parent
    spacing: 0

    // Left sidebar with polygon properties
    Rectangle {
      Layout.preferredWidth: 320
      Layout.fillHeight: true
      color: "#ecf0f1"
      border.color: "#bdc3c7"
      border.width: 1
      
      Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: "#95a5a6"
      }

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
          spacing: 2

          delegate: Rectangle {
            width: ListView.view.width
            height: 90
            color: modelData.selected ? "#f0f8ff" : "#fafafa"
            border.color: modelData.selected ? "#4a90e2" : "#e0e0e0"
            border.width: modelData.selected ? 2 : 1
            radius: 6

            Rectangle {
              anchors.left: parent.left
              width: 4
              height: parent.height
              color: modelData.color
              radius: 2
              visible: modelData.selected
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onClicked: manager.selectedPolygon = modelData
              onEntered: parent.color = modelData.selected ? "#f0f8ff" : "#f5f5f5"
              onExited: parent.color = modelData.selected ? "#f0f8ff" : "#fafafa"
            }

            RowLayout {
              anchors.fill: parent
              anchors.margins: 12
              spacing: 12

              Column {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                  Layout.fillWidth: true
                  spacing: 8

                  Text { 
                    text: "ID: " + modelData.id 
                    font.pixelSize: 13
                    font.bold: true
                    color: "#2c3e50"
                  }

                  Rectangle {
                    Layout.preferredWidth: 12
                    Layout.preferredHeight: 12
                    color: modelData.color
                    border.color: "#34495e"
                    border.width: 1
                    radius: 6
                  }
                }

                Text { 
                  text: "Площадь: " + formatArea(modelData.area)
                  font.pixelSize: 11
                  color: "#7f8c8d"
                }
                Text { 
                  text: "Точки: " + modelData.vertexCount 
                  font.pixelSize: 11
                  color: "#7f8c8d"
                }
              }

              Column {
                Layout.preferredWidth: 32
                spacing: 4

                Rectangle {
                  width: 32
                  height: 32
                  color: modelData.color
                  border.color: "#34495e"
                  border.width: 2
                  radius: 4

                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                      manager.selectedPolygon = modelData
                      if (colorPickerLoader.item) {
                        colorPickerLoader.item.selectedColor = modelData.color
                      }
                    }
                    onEntered: parent.scale = 1.1
                    onExited: parent.scale = 1.0
                  }

                  Behavior on scale {
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                  }
                }

                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: "Цвет"
                  font.pixelSize: 9
                  color: "#95a5a6"
                }
              }
            }
          }
        }

        Loader {
          id: colorPickerLoader
          Layout.fillWidth: true
          Layout.preferredHeight: item ? item.height : 0
          visible: manager.selectedPolygon !== null
          
          sourceComponent: manager.selectedPolygon ? colorPickerComponent : null
        }

        Component {
          id: colorPickerComponent
          ColumnLayout {
            spacing: 8
            
            ColorPicker {
              selectedColor: manager.selectedPolygon ? manager.selectedPolygon.color : "#4444ff"
              onColorSelected: function(newColor) {
                if (manager.selectedPolygon) {
                  manager.selectedPolygon.color = newColor
                }
              }
            }
            
            AreaCalculator {
              polygon: manager.selectedPolygon
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
        Layout.preferredHeight: 56
        color: "#34495e"
        border.color: "#2c3e50"
        border.width: 1
        
        Rectangle {
          anchors.bottom: parent.bottom
          width: parent.width
          height: 1
          color: "#2c3e50"
        }

        RowLayout {
          anchors.centerIn: parent
          spacing: 12

          Button {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 36
            text: "+"
            
            background: Rectangle {
              color: parent.pressed ? "#27ae60" : "#2ecc71"
              border.color: "#27ae60"
              border.width: 1
              radius: 6
            }
            
            contentItem: Text {
              text: parent.text
              color: "#ffffff"
              font.pixelSize: 18
              font.bold: true
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
            
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
            Layout.preferredWidth: 44
            Layout.preferredHeight: 36
            text: "−"
            enabled: manager.selectedPolygon !== null
            
            background: Rectangle {
              color: parent.enabled ? (parent.pressed ? "#c0392b" : "#e74c3c") : "#bdc3c7"
              border.color: parent.enabled ? "#c0392b" : "#95a5a6"
              border.width: 1
              radius: 6
            }
            
            contentItem: Text {
              text: parent.text
              color: "#ffffff"
              font.pixelSize: 18
              font.bold: true
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
            }
            
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


        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.RightButton
          onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
              contextMenu.targetPolygon = null
              contextMenu.polygonManager = manager
              contextMenu.popup()
            }
          }
        }

        // Render polygons
        Repeater {
          z:20
          model: manager.polygons
          delegate: EditablePolygon {
            polygon: modelData
          }
        }
        
        ContextMenu {
          id: contextMenu
        }
      }
    }
  }
}
