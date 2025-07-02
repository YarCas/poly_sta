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
   // parent: map
     autoFadeIn: false
    path: polygon ? polygon.path : []
    color: polygon ? polygon.color : "green"
    border.color: polygon ? polygon.borderColor : "green"
    border.width: polygon ? polygon.borderWidth : 0
    opacity: 0.7
  }

  // Vertex handles
  Repeater {
    model: polygon ? polygon.vertexCount : 0
    delegate: MapQuickItem {
    //  parent: map
      coordinate: polygon ? polygon.getVertex(index) : QtPositioning.coordinate()
      anchorPoint.x: vertexHandle.width / 2
      anchorPoint.y: vertexHandle.height / 2

      sourceItem: Rectangle {
        id: vertexHandle
        width: 12
        height: 12
        radius: 6
        color: polygon && polygon.selected ? "#ff4444" : "#4444ff"
        border.color: "white"
        border.width: 2
        visible: polygon && polygon.selected

        MouseArea {
          anchors.fill: parent
          drag.target: parent

          property bool dragging: false

          onPressed: dragging = true
          onReleased: {
            if (dragging && polygon) {
              var coord = map.toCoordinate(Qt.point(parent.x + width/2, parent.y + height/2))
              polygon.moveVertex(index, coord.latitude, coord.longitude)
            }
            dragging = false
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

      sourceItem: Rectangle {
        id: addHandle
        width: 8
        height: 8
        radius: 4
        color: "#44ff44"
        border.color: "white"
        border.width: 1
        visible: polygon && polygon.selected

        MouseArea {
          anchors.fill: parent
          onClicked: {
            if (polygon) {
              var coord = map.toCoordinate(Qt.point(parent.x + width/2, parent.y + height/2))
              polygon.addVertex(coord.latitude, coord.longitude, index + 1)
            }
          }
        }
      }
    }
  }
}
