import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.lego.app 1.0

Controls.ScrollView {
    id: setsPage
    
    required property var model
    
    contentWidth: availableWidth
    
    ColumnLayout {
        width: setsPage.availableWidth
        spacing: 24
        
        Controls.Pane {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            
            Controls.Label {
                text: "All Sets"
                font.pixelSize: 24
                font.bold: true
            }
        }
        
        // Currently Building Section
        Controls.Pane {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            visible: buildingRepeater.count > 0
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                Controls.Label {
                    text: "Currently Building"
                    font.pixelSize: 20
                    font.bold: true
                }
                
                GridLayout {
                    Layout.fillWidth: true
                    columns: Math.max(1, Math.floor(setsPage.availableWidth / 320))
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    Repeater {
                        id: buildingRepeater
                        model: setsPage.model.getSetsByStatus(1)
                        
                        SetCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            setData: modelData
                        }
                    }
                }
            }
        }
        
        // Backlog Section
        Controls.Pane {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            visible: backlogRepeater.count > 0
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                Controls.Label {
                    text: "Backlog"
                    font.pixelSize: 20
                    font.bold: true
                }
                
                GridLayout {
                    Layout.fillWidth: true
                    columns: Math.max(1, Math.floor(setsPage.availableWidth / 320))
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    Repeater {
                        id: backlogRepeater
                        model: setsPage.model.getSetsByStatus(0)
                        
                        SetCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            setData: modelData
                        }
                    }
                }
            }
        }
        
        // Built Section
        Controls.Pane {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 16
            visible: builtRepeater.count > 0
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                Controls.Label {
                    text: "Built"
                    font.pixelSize: 20
                    font.bold: true
                }
                
                GridLayout {
                    Layout.fillWidth: true
                    columns: Math.max(1, Math.floor(setsPage.availableWidth / 320))
                    columnSpacing: 16
                    rowSpacing: 16
                    
                    Repeater {
                        id: builtRepeater
                        model: setsPage.model.getSetsByStatus(2)
                        
                        SetCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            setData: modelData
                        }
                    }
                }
            }
        }
        
        // Empty state
        Controls.Pane {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 16
            visible: buildingRepeater.count === 0 && backlogRepeater.count === 0 && builtRepeater.count === 0
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16
                
                Controls.Label {
                    text: "📦"
                    font.pixelSize: 64
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Controls.Label {
                    text: "No sets in collection"
                    font.pixelSize: 18
                    opacity: 0.6
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
