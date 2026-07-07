import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.lego.app 1.0

Controls.ScrollView {
    id: dashboardPage
    
    required property var model
    
    contentWidth: availableWidth
    
    ColumnLayout {
        width: dashboardPage.availableWidth
        spacing: 24
        
        Controls.Pane {
            Layout.fillWidth: true
            Layout.topMargin: 16
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                Controls.Label {
                    text: "Dashboard"
                    font.pixelSize: 24
                    font.bold: true
                }
                
                // Stats Section
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    // Total Sets Card
                    Controls.Pane {
                        Layout.fillWidth: true
                        background: Rectangle {
                            color: "#f0f0f0"
                            radius: 8
                        }
                        
                        ColumnLayout {
                            width: parent.width
                            spacing: 8
                            
                            Controls.Label {
                                text: "📦"
                                font.pixelSize: 32
                            }
                            
                            Controls.Label {
                                text: model.count
                                font.pixelSize: 32
                                font.bold: true
                            }
                            
                            Controls.Label {
                                text: "Total Sets"
                                opacity: 0.6
                            }
                        }
                    }
                    
                    // Built Sets Card
                    Controls.Pane {
                        Layout.fillWidth: true
                        background: Rectangle {
                            color: "#f0f0f0"
                            radius: 8
                        }
                        
                        ColumnLayout {
                            width: parent.width
                            spacing: 8
                            
                            Controls.Label {
                                text: "✓"
                                font.pixelSize: 32
                            }
                            
                            Controls.Label {
                                text: model.countByStatus(2)
                                font.pixelSize: 32
                                font.bold: true
                            }
                            
                            Controls.Label {
                                text: "Built Sets"
                                opacity: 0.6
                            }
                        }
                    }
                }
            }
        }
        
        // Actions Section
        Controls.Pane {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                Controls.Label {
                    text: "Actions"
                    font.pixelSize: 20
                    font.bold: true
                }
                
                Controls.ItemDelegate {
                    Layout.fillWidth: true
                    
                    contentItem: RowLayout {
                        Controls.Label {
                            text: "➕"
                            font.pixelSize: 24
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Controls.Label {
                                text: "Add missing parts to Rebrickable"
                                font.bold: true
                            }
                            
                            Controls.Label {
                                text: "Sync missing parts from your sets to your Rebrickable wanted list"
                                opacity: 0.6
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    onClicked: {
                        messageLabel.text = "This feature is coming soon!"
                        messageLabel.visible = true
                        messageTimer.start()
                    }
                }
            }
        }
        
        // Currently Building Section
        Controls.Pane {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 16
            visible: buildingRepeater.count > 0
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Controls.Label {
                        text: "Currently Building"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Controls.Button {
                        text: "View All Sets"
                        flat: true
                        onClicked: {
                            applicationWindow().currentPage = 1
                        }
                    }
                }
                
                Flow {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    Repeater {
                        id: buildingRepeater
                        model: dashboardPage.model.getSetsByStatus(1)
                        
                        SetCard {
                            width: 280
                            setData: modelData
                        }
                    }
                }
            }
        }
        
        // No active builds message
        Controls.Pane {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 16
            visible: buildingRepeater.count === 0
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Controls.Label {
                        text: "No active builds"
                        font.pixelSize: 20
                        font.bold: true
                        Layout.fillWidth: true
                    }
                    
                    Controls.Button {
                        text: "View All Sets"
                        flat: true
                        onClicked: {
                            applicationWindow().currentPage = 1
                        }
                    }
                }
            }
        }
    }
    
    Controls.Label {
        id: messageLabel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        visible: false
        text: ""
        padding: 12
        background: Rectangle {
            color: "#e0e0e0"
            radius: 4
        }
        
        Timer {
            id: messageTimer
            interval: 3000
            onTriggered: messageLabel.visible = false
        }
    }
}
