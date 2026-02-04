import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.lego.app 1.0

Controls.ScrollView {
    id: settingsPage
    
    contentWidth: availableWidth
    
    ColumnLayout {
        width: Math.min(settingsPage.availableWidth - 32, 600)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 24
        
        Controls.Pane {
            Layout.fillWidth: true
            Layout.topMargin: 16
            
            Controls.Label {
                text: "Settings"
                font.pixelSize: 24
                font.bold: true
            }
        }
        
        Controls.Pane {
            Layout.fillWidth: true
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                Controls.Label {
                    text: "Account"
                    font.pixelSize: 18
                    font.bold: true
                }
                
                GridLayout {
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8
                    Layout.fillWidth: true
                    
                    Controls.Label {
                        text: "Status:"
                        font.bold: true
                    }
                    
                    Controls.Label {
                        text: AuthManager.isAuthenticated ? "Logged in" : "Not logged in"
                    }
                }
                
                Controls.Button {
                    text: "Logout"
                    onClicked: {
                        AuthManager.logout()
                    }
                }
            }
        }
        
        Controls.Pane {
            Layout.fillWidth: true
            Layout.bottomMargin: 16
            
            ColumnLayout {
                width: parent.width
                spacing: 16
                
                Controls.Label {
                    text: "About"
                    font.pixelSize: 18
                    font.bold: true
                }
                
                GridLayout {
                    columns: 2
                    columnSpacing: 16
                    rowSpacing: 8
                    Layout.fillWidth: true
                    
                    Controls.Label {
                        text: "Application:"
                        font.bold: true
                    }
                    
                    Controls.Label {
                        text: "Lego App"
                    }
                    
                    Controls.Label {
                        text: "Version:"
                        font.bold: true
                    }
                    
                    Controls.Label {
                        text: "0.1.6"
                    }
                    
                    Controls.Label {
                        text: "Description:"
                        font.bold: true
                        Layout.alignment: Qt.AlignTop
                    }
                    
                    Controls.Label {
                        text: "A cross-platform LEGO set rebuilding application"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
