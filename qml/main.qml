import QtQuick
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.lego.app 1.0

Kirigami.ApplicationWindow {
    id: root
    
    title: "Lego App"
    
    width: 1280
    height: 720
    minimumWidth: 400
    minimumHeight: 300
    
    pageStack.initialPage: AuthManager.isAuthenticated ? dashboardPage : authPage
    
    Connections {
        target: AuthManager
        function onAuthenticationChanged() {
            if (AuthManager.isAuthenticated) {
                root.pageStack.replace(dashboardPage)
                // Load sets data
                legoSetModel.refresh()
            } else {
                root.pageStack.replace(authPage)
            }
        }
    }
    
    // Global drawer for navigation when authenticated
    globalDrawer: Kirigami.GlobalDrawer {
        id: drawer
        title: "Lego App"
        titleIcon: "applications-games"
        
        enabled: AuthManager.isAuthenticated
        modal: !root.wideScreen
        
        actions: [
            Kirigami.Action {
                text: "Dashboard"
                icon.name: "dashboard-show"
                onTriggered: {
                    root.pageStack.clear()
                    root.pageStack.push(dashboardPage)
                }
            },
            Kirigami.Action {
                text: "Sets"
                icon.name: "view-list-icons"
                onTriggered: {
                    root.pageStack.clear()
                    root.pageStack.push(setsPage)
                }
            },
            Kirigami.Action {
                text: "Settings"
                icon.name: "settings-configure"
                onTriggered: {
                    root.pageStack.clear()
                    root.pageStack.push(settingsPage)
                }
            }
        ]
    }
    
    // Model for LEGO sets
    LegoSetModel {
        id: legoSetModel
    }
    
    // Page components
    Component {
        id: authPage
        AuthPage {}
    }
    
    Component {
        id: dashboardPage
        DashboardPage {
            model: legoSetModel
        }
    }
    
    Component {
        id: setsPage
        SetsPage {
            model: legoSetModel
        }
    }
    
    Component {
        id: settingsPage
        SettingsPage {}
    }
}
