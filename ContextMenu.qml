import QtQuick 2.15
import QtQuick.Controls 2.15

Menu {
  id: contextMenu
  
  property var targetPolygon: null
  property var polygonManager: null
  
  MenuItem {
    text: "Выбрать полигон"
    enabled: targetPolygon !== null
    onTriggered: {
      if (polygonManager && targetPolygon) {
        polygonManager.selectedPolygon = targetPolygon
      }
    }
  }
  
  MenuSeparator {}
  
  MenuItem {
    text: "Удалить полигон"
    enabled: targetPolygon !== null
    onTriggered: {
      if (polygonManager && targetPolygon) {
        polygonManager.removePolygon(targetPolygon)
      }
    }
  }
  
  MenuItem {
    text: "Дублировать полигон"
    enabled: targetPolygon !== null
    onTriggered: {
      if (polygonManager && targetPolygon) {
        var center = targetPolygon.getVertex(0)
        if (center.isValid) {
          polygonManager.createRectangularPolygon(
            center.latitude + 0.001, 
            center.longitude + 0.001, 
            1000, 1000
          )
        }
      }
    }
  }
  
  MenuSeparator {}
  
  MenuItem {
    text: "Отменить выбор"
    enabled: polygonManager && polygonManager.selectedPolygon !== null
    onTriggered: {
      if (polygonManager) {
        polygonManager.selectedPolygon = null
      }
    }
  }
}
