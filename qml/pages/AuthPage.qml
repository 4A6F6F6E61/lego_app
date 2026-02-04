import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.lego.app 1.0

Controls.Page {
    id: authPage
    
    title: isLogin ? "Login" : "Register"
    
    property bool isLogin: true
    
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.9, 500)
        spacing: 16
        
        Controls.Label {
            Layout.alignment: Qt.AlignHCenter
            text: authPage.isLogin ? "Login" : "Register"
            font.pixelSize: 28
            font.bold: true
        }
        
        Controls.TextField {
            id: emailField
            Layout.fillWidth: true
            placeholderText: "Email"
        }
        
        Controls.TextField {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: "Password"
            echoMode: Controls.TextField.Password
            onAccepted: submitButton.clicked()
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
        
        Controls.Label {
            Layout.fillWidth: true
            visible: AuthManager.errorMessage !== ""
            text: AuthManager.errorMessage
            color: "red"
            wrapMode: Text.WordWrap
        }
    }
    
    Connections {
        target: AuthManager
        function onRegistrationSuccessful() {
            // Show a temporary message
            messageLabel.text = "Registration successful! Please check your email."
            messageLabel.visible = true
            messageTimer.start()
        }
    }
    
    Controls.Label {
        id: messageLabel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        visible: false
        text: ""
        color: "green"
        
        Timer {
            id: messageTimer
            interval: 3000
            onTriggered: messageLabel.visible = false
        }
    }
}
