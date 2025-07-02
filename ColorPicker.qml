import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
  id: colorPicker
  width: 200
  height: 120
  color: "#f8f8f8"
  border.color: "#d0d0d0"
  border.width: 1
  radius: 4

  property color selectedColor: "#4444ff"
  property var predefinedColors: [
    "#ff4444", "#44ff44", "#4444ff", "#ffff44",
    "#ff44ff", "#44ffff", "#ff8844", "#8844ff",
    "#44ff88", "#ff4488", "#88ff44", "#4488ff"
  ]

  signal colorSelected(color newColor)

  Column {
    anchors.fill: parent
    anchors.margins: 8
    spacing: 8

    Text {
      text: "Цвет полигона"
      font.pixelSize: 12
      font.bold: true
    }

    Grid {
      columns: 4
      spacing: 4
      anchors.horizontalCenter: parent.horizontalCenter

      Repeater {
        model: colorPicker.predefinedColors
        delegate: Rectangle {
          width: 32
          height: 32
          color: modelData
          border.color: colorPicker.selectedColor === modelData ? "#000000" : "#888888"
          border.width: colorPicker.selectedColor === modelData ? 3 : 1
          radius: 4

          MouseArea {
            anchors.fill: parent
            onClicked: {
              colorPicker.selectedColor = modelData
              colorPicker.colorSelected(modelData)
            }
          }
        }
      }
    }

    Row {
      spacing: 8
      anchors.horizontalCenter: parent.horizontalCenter

      Text {
        text: "Текущий:"
        font.pixelSize: 10
        anchors.verticalCenter: parent.verticalCenter
      }

      Rectangle {
        width: 24
        height: 24
        color: colorPicker.selectedColor
        border.color: "#000000"
        border.width: 1
        radius: 2
      }
    }
  }
}
