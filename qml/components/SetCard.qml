import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Controls.Pane {
    id: setCard
    
    required property var setData
    
    background: Rectangle {
        color: "#f5f5f5"
        radius: 8
        border.color: "#e0e0e0"
        border.width: 1
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        
        // Image placeholder or actual image
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            color: "#e0e0e0"
            radius: 4
            
            Image {
                anchors.fill: parent
                source: setData.imgUrl || ""
                fillMode: Image.PreserveAspectFit
                visible: setData.imgUrl
            }
            
            Controls.Label {
                anchors.centerIn: parent
                text: "🧱"
                font.pixelSize: 48
                visible: !setData.imgUrl
            }
        }
        
        Controls.Label {
            Layout.fillWidth: true
            text: setData.name
            font.bold: true
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
        
        Controls.Label {
            text: "Set #: " + setData.setNum
            opacity: 0.6
            font.pixelSize: 12
        }
        
        Controls.Label {
            text: "Year: " + (setData.year || "Unknown")
            opacity: 0.6
            font.pixelSize: 12
        }
        
        Controls.Label {
            text: {
                switch (setData.status) {
                    case 0: return "Status: Backlog"
                    case 1: return "Status: Currently Building"
                    case 2: return "Status: Built"
                    default: return "Status: Unknown"
                }
            }
            font.bold: true
            font.pixelSize: 12
        }
    }
}
