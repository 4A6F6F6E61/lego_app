import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.lego.app 1.0

Kirigami.Page {
    id: authPage
    
    title: isLogin ? "Login" : "Register"
    
    property bool isLogin: true
    
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, 500)
        spacing: Kirigami.Units.largeSpacing
        
        Kirigami.Heading {
            Layout.alignment: Qt.AlignHCenter
            text: authPage.isLogin ? "Login" : "Register"
            level: 1
        }
        
        Kirigami.FormLayout {
            Layout.fillWidth: true
            
            Controls.TextField {
                id: emailField
                Kirigami.FormData.label: "Email:"
                placeholderText: "your.email@example.com"
            }
            
            Controls.TextField {
                id: passwordField
                Kirigami.FormData.label: "Password:"
                echoMode: Controls.TextField.Password
                placeholderText: "Password"
                onAccepted: submitButton.clicked()
            }
        }
        
        Controls.Button {
            id: submitButton
            Layout.fillWidth: true
            text: authPage.isLogin ? "Login" : "Register"
            highlighted: true
            onClicked: {
                if (authPage.isLogin) {
                    AuthManager.login(emailField.text, passwordField.text)
                } else {
                    AuthManager.registerUser(emailField.text, passwordField.text)
                }
            }
        }
        
        Controls.Button {
            Layout.fillWidth: true
            text: authPage.isLogin ? "Need an account? Register" : "Have an account? Login"
            flat: true
            onClicked: {
                authPage.isLogin = !authPage.isLogin
            }
        }
        
        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: AuthManager.errorMessage !== ""
            type: Kirigami.MessageType.Error
            text: AuthManager.errorMessage
        }
    }
    
    Connections {
        target: AuthManager
        function onRegistrationSuccessful() {
            applicationWindow().showPassiveNotification("Registration successful! Please check your email.")
        }
    }
}
