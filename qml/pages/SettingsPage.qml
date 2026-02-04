import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.lego.app 1.0

Kirigami.ScrollablePage {
    id: settingsPage
    
    title: "Settings"
    
    Kirigami.FormLayout {
        width: Math.min(parent.width, 600)
        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Account"
        }
        
        Controls.Label {
            Kirigami.FormData.label: "Status:"
            text: AuthManager.isAuthenticated ? "Logged in" : "Not logged in"
        }
        
        Controls.Button {
            text: "Logout"
            onClicked: {
                AuthManager.logout()
            }
        }
        
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "About"
        }
        
        Controls.Label {
            Kirigami.FormData.label: "Application:"
            text: "Lego App"
        }
        
        Controls.Label {
            Kirigami.FormData.label: "Version:"
            text: "0.1.6"
        }
        
        Controls.Label {
            Kirigami.FormData.label: "Description:"
            text: "A cross-platform LEGO set rebuilding application"
            wrapMode: Text.WordWrap
        }
    }
}
