import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
  id: errorDialog
  
  property string errorMessage: ""
  
  title: "Ошибка"
  modal: true
  anchors.centerIn: parent
  width: 300
  height: 150
  
  background: Rectangle {
    color: "#ffffff"
    border.color: "#e74c3c"
    border.width: 2
    radius: 8
  }
  
  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 16
    
    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 40
      color: "#ffeaea"
      border.color: "#e74c3c"
      border.width: 1
      radius: 4
      
      RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8
        
        Rectangle {
          Layout.preferredWidth: 24
          Layout.preferredHeight: 24
          color: "#e74c3c"
          radius: 12
          
          Text {
            anchors.centerIn: parent
            text: "!"
            color: "#ffffff"
            font.bold: true
            font.pixelSize: 14
          }
        }
        
        Text {
          Layout.fillWidth: true
          text: errorDialog.errorMessage
          color: "#c0392b"
          font.pixelSize: 12
          wrapMode: Text.WordWrap
        }
      }
    }
    
    Item {
      Layout.fillHeight: true
    }
    
    Button {
      Layout.alignment: Qt.AlignRight
      text: "OK"
      
      background: Rectangle {
        color: parent.pressed ? "#c0392b" : "#e74c3c"
        border.color: "#c0392b"
        border.width: 1
        radius: 4
      }
      
      contentItem: Text {
        text: parent.text
        color: "#ffffff"
        font.pixelSize: 12
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
      
      onClicked: errorDialog.close()
    }
  }
}
