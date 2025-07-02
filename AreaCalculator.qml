import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
  id: areaCalculator
  
  property var polygon: null
  property real totalArea: polygon ? polygon.area : 0
  
  width: 280
  height: 120
  color: "#f8f9fa"
  border.color: "#dee2e6"
  border.width: 1
  radius: 6
  
  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8
    
    Text {
      text: "Расчет площади"
      font.pixelSize: 14
      font.bold: true
      color: "#2c3e50"
    }
    
    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: "#dee2e6"
    }
    
    GridLayout {
      Layout.fillWidth: true
      columns: 2
      columnSpacing: 16
      rowSpacing: 4
      
      Text {
        text: "Площадь:"
        font.pixelSize: 11
        color: "#6c757d"
      }
      
      Text {
        text: formatDetailedArea(totalArea)
        font.pixelSize: 11
        font.bold: true
        color: "#2c3e50"
      }
      
      Text {
        text: "Периметр:"
        font.pixelSize: 11
        color: "#6c757d"
      }
      
      Text {
        text: formatPerimeter(calculatePerimeter())
        font.pixelSize: 11
        color: "#2c3e50"
      }
      
      Text {
        text: "Вершин:"
        font.pixelSize: 11
        color: "#6c757d"
      }
      
      Text {
        text: polygon ? polygon.vertexCount.toString() : "0"
        font.pixelSize: 11
        color: "#2c3e50"
      }
    }
  }
  
  function formatDetailedArea(areaInSquareMeters) {
    if (areaInSquareMeters < 1000) {
      return areaInSquareMeters.toFixed(1) + " m²"
    } else if (areaInSquareMeters < 10000) {
      return (areaInSquareMeters / 1000).toFixed(3) + " тыс. m²"
    } else if (areaInSquareMeters < 1000000) {
      return (areaInSquareMeters / 1000).toFixed(1) + " тыс. m²"
    } else {
      var hectares = areaInSquareMeters / 10000
      var km2 = areaInSquareMeters / 1000000
      if (hectares < 100) {
        return hectares.toFixed(2) + " га (" + km2.toFixed(4) + " км²)"
      } else {
        return km2.toFixed(2) + " км²"
      }
    }
  }
  
  function formatPerimeter(perimeterInMeters) {
    if (perimeterInMeters < 1000) {
      return perimeterInMeters.toFixed(1) + " м"
    } else {
      return (perimeterInMeters / 1000).toFixed(2) + " км"
    }
  }
  
  function calculatePerimeter() {
    if (!polygon || !polygon.path || polygon.path.length < 2) {
      return 0
    }
    
    var perimeter = 0
    var path = polygon.path
    
    for (var i = 0; i < path.length; i++) {
      var current = path[i]
      var next = path[(i + 1) % path.length]
      
      if (current && next && current.latitude !== undefined && next.latitude !== undefined) {
        perimeter += distanceBetweenCoordinates(
          current.latitude, current.longitude,
          next.latitude, next.longitude
        )
      }
    }
    
    return perimeter
  }
  
  function distanceBetweenCoordinates(lat1, lon1, lat2, lon2) {
    var R = 6371000
    var dLat = (lat2 - lat1) * Math.PI / 180
    var dLon = (lon2 - lon1) * Math.PI / 180
    var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon/2) * Math.sin(dLon/2)
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    return R * c
  }
}
