import QtQuick 2.15
import QtLocation 5.15
import QtPositioning 5.15
import PolygonEditor 1.0
Item {
  id: root

  property Polygon polygon
  property Map map

  // Main polygon
  MapPolygon {
    id: mapPolygon
    autoFadeIn: false
    path: polygon ? polygon.path : []
    color: polygon ? polygon.color : "green"
    border.color: polygon && polygon.selected ? "#ff6600" : (polygon ? polygon.borderColor : "green")
    border.width: polygon && polygon.selected ? 3 : (polygon ? polygon.borderWidth : 1)
    opacity: polygon && polygon.selected ? 0.8 : 0.6
  }

  // Selection highlight overlay
  MapPolygon {
    id: selectionHighlight
    autoFadeIn: false
    path: polygon ? polygon.path : []
    color: "transparent"
    border.color: "#ffaa00"
    border.width: 5
    opacity: 0.9
    visible: polygon && polygon.selected
  }

  // Vertex handles
  Repeater {
    model: polygon ? polygon.vertexCount : 0
    delegate: MapQuickItem {
    //  parent: map
      coordinate: polygon ? polygon.getVertex(index) : QtPositioning.coordinate()
      anchorPoint.x: vertexHandle.width / 2
      anchorPoint.y: vertexHandle.height / 2

      sourceItem: Item {
        width: 20
        height: 20

        Rectangle {
          id: vertexHandleOuter
          anchors.centerIn: parent
          width: 18
          height: 18
          radius: 9
          color: "#ffffff"
          border.color: "#333333"
          border.width: 2
          opacity: 0.9
          visible: polygon && polygon.selected
        }

        Rectangle {
          id: vertexHandle
          anchors.centerIn: parent
          width: 12
          height: 12
          radius: 6
          color: polygon && polygon.selected ? "#ff4444" : "#4444ff"
          border.color: "#ffffff"
          border.width: 1
          visible: polygon && polygon.selected

          SequentialAnimation on scale {
            running: polygon && polygon.selected
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 1.2; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.2; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
          }
        }

        MouseArea {
          anchors.fill: parent
          drag.target: parent

          property bool dragging: false

          onPressed: {
            dragging = true
            vertexHandle.scale = 1.3
          }
          onReleased: {
            if (dragging && polygon) {
              var coord = map.toCoordinate(Qt.point(parent.x + width/2, parent.y + height/2))
              polygon.moveVertex(index, coord.latitude, coord.longitude)
            }
            dragging = false
            vertexHandle.scale = 1.0
          }
        }
      }
    }
  }

  // Add vertex handles (between existing vertices)
  Repeater {
    model: polygon ? polygon.vertexCount : 0
    delegate: MapQuickItem {
    //  parent: map
      coordinate: {
        if (!polygon || polygon.vertexCount < 2) return QtPositioning.coordinate()
        var current = polygon.getVertex(index)
        var next = polygon.getVertex((index + 1) % polygon.vertexCount)
        return QtPositioning.coordinate(
          (current.latitude + next.latitude) / 2,
          (current.longitude + next.longitude) / 2
        )
      }
      anchorPoint.x: addHandle.width / 2
      anchorPoint.y: addHandle.height / 2

      sourceItem: Item {
        width: 16
        height: 16

        Rectangle {
          id: addHandleOuter
          anchors.centerIn: parent
          width: 14
          height: 14
          radius: 7
          color: "#ffffff"
          border.color: "#22aa22"
          border.width: 1
          opacity: 0.8
          visible: polygon && polygon.selected
        }

        Rectangle {
          id: addHandle
          anchors.centerIn: parent
          width: 10
          height: 10
          radius: 5
          color: "#44ff44"
          border.color: "#ffffff"
          border.width: 1
          visible: polygon && polygon.selected

          Rectangle {
            anchors.centerIn: parent
            width: 6
            height: 2
            color: "#ffffff"
          }
          Rectangle {
            anchors.centerIn: parent
            width: 2
            height: 6
            color: "#ffffff"
          }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            if (polygon) {
              var coord = map.toCoordinate(Qt.point(parent.x + width/2, parent.y + height/2))
              polygon.addVertex(coord.latitude, coord.longitude, index + 1)
            }
          }
          onEntered: addHandle.scale = 1.2
          onExited: addHandle.scale = 1.0
        }
      }
    }
  }
}
