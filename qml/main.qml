import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.lego.app 1.0

Controls.ApplicationWindow {
    id: root
    
    title: "Lego App"
    
    width: 1280
    height: 720
    minimumWidth: 400
    minimumHeight: 300
    
    visible: true
    
    property int currentPage: 0
    
    Connections {
        target: AuthManager
        function onAuthenticationChanged() {
            if (AuthManager.isAuthenticated) {
                currentPage = 0 // Dashboard
                legoSetModel.refresh()
            } else {
                stackView.push(authPageComponent)
            }
        }
    }
    
    Component.onCompleted: {
        if (AuthManager.isAuthenticated) {
            stackView.push(navigationComponent)
            legoSetModel.refresh()
        } else {
            stackView.push(authPageComponent)
        }
    }
    
    // Model for LEGO sets
    LegoSetModel {
        id: legoSetModel
    }
    
    Controls.StackView {
        id: stackView
        anchors.fill: parent
        initialItem: Item {}
    }
    
    // Auth page component
    Component {
        id: authPageComponent
        AuthPage {}
    }
    
    // Navigation component with drawer
    Component {
        id: navigationComponent
        Item {
            Controls.Drawer {
                id: drawer
                width: Math.min(root.width * 0.66, 300)
                height: root.height
                
                modal: root.width < 800
                interactive: root.width < 800
                visible: root.width >= 800
                position: root.width >= 800 ? 1 : 0
                
                Column {
                    anchors.fill: parent
                    spacing: 0
                    
                    Controls.Pane {
                        width: parent.width
                        
                        ColumnLayout {
                            width: parent.width
                            
                            Controls.Label {
                                text: "Lego App"
                                font.pixelSize: 20
                                font.bold: true
                            }
                        }
                    }
                    
                    Controls.ItemDelegate {
                        width: parent.width
                        text: "Dashboard"
                        highlighted: currentPage === 0
                        onClicked: {
                            currentPage = 0
                            if (root.width < 800) drawer.close()
                        }
                    }
                    
                    Controls.ItemDelegate {
                        width: parent.width
                        text: "Sets"
                        highlighted: currentPage === 1
                        onClicked: {
                            currentPage = 1
                            if (root.width < 800) drawer.close()
                        }
                    }
                    
                    Controls.ItemDelegate {
                        width: parent.width
                        text: "Settings"
                        highlighted: currentPage === 2
                        onClicked: {
                            currentPage = 2
                            if (root.width < 800) drawer.close()
                        }
                    }
                }
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: drawer.visible && !drawer.modal ? drawer.width : 0
                spacing: 0
                
                Controls.ToolBar {
                    Layout.fillWidth: true
                    visible: root.width < 800
                    
                    RowLayout {
                        anchors.fill: parent
                        
                        Controls.ToolButton {
                            text: "☰"
                            onClicked: drawer.open()
                        }
                        
                        Controls.Label {
                            text: currentPage === 0 ? "Dashboard" : currentPage === 1 ? "Sets" : "Settings"
                            font.pixelSize: 18
                            Layout.fillWidth: true
                        }
                    }
                }
                
                Controls.StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: currentPage
                    
                    DashboardPage {
                        model: legoSetModel
                    }
                    
                    SetsPage {
                        model: legoSetModel
                    }
                    
                    SettingsPage {}
                }
            }
        }
    }
}
