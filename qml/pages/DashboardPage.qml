import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.lego.app 1.0

Kirigami.ScrollablePage {
    id: dashboardPage
    
    title: "Dashboard"
    
    required property var model
    
    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        
        // Stats Section
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing
            
            // Total Sets Card
            Kirigami.Card {
                Layout.fillWidth: true
                
                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.smallSpacing
                    
                    Kirigami.Icon {
                        source: "view-list-icons"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.large
                        Layout.preferredHeight: Kirigami.Units.iconSizes.large
                        color: Kirigami.Theme.linkColor
                    }
                    
                    Kirigami.Heading {
                        text: model.count
                        level: 2
                    }
                    
                    Controls.Label {
                        text: "Total Sets"
                        color: Kirigami.Theme.disabledTextColor
                    }
                }
            }
            
            // Built Sets Card
            Kirigami.Card {
                Layout.fillWidth: true
                
                contentItem: ColumnLayout {
                    spacing: Kirigami.Units.smallSpacing
                    
                    Kirigami.Icon {
                        source: "checkmark"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.large
                        Layout.preferredHeight: Kirigami.Units.iconSizes.large
                        color: Kirigami.Theme.positiveTextColor
                    }
                    
                    Kirigami.Heading {
                        text: model.countByStatus(2)
                        level: 2
                    }
                    
                    Controls.Label {
                        text: "Built Sets"
                        color: Kirigami.Theme.disabledTextColor
                    }
                }
            }
        }
        
        // Actions Section
        Kirigami.Heading {
            text: "Actions"
            level: 3
        }
        
        Kirigami.Card {
            Layout.fillWidth: true
            
            contentItem: RowLayout {
                Kirigami.Icon {
                    source: "list-add"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    
                    Controls.Label {
                        text: "Add missing parts to Rebrickable"
                        font.bold: true
                    }
                    
                    Controls.Label {
                        text: "Sync missing parts from your sets to your Rebrickable wanted list"
                        color: Kirigami.Theme.disabledTextColor
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
            
            onClicked: {
                applicationWindow().showPassiveNotification("This feature is coming soon!")
            }
        }
        
        // Currently Building Section
        ColumnLayout {
            Layout.fillWidth: true
            visible: buildingRepeater.count > 0
            
            RowLayout {
                Layout.fillWidth: true
                
                Kirigami.Heading {
                    text: "Currently Building"
                    level: 3
                    Layout.fillWidth: true
                }
                
                Controls.Button {
                    text: "View All Sets"
                    flat: true
                    onClicked: {
                        applicationWindow().pageStack.clear()
                        applicationWindow().pageStack.push("qrc:/qml/pages/SetsPage.qml", {model: model})
                    }
                }
            }
            
            Flow {
                Layout.fillWidth: true
                spacing: Kirigami.Units.largeSpacing
                
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
        
        // No active builds message
        ColumnLayout {
            Layout.fillWidth: true
            visible: buildingRepeater.count === 0
            
            RowLayout {
                Layout.fillWidth: true
                
                Kirigami.Heading {
                    text: "No active builds"
                    level: 3
                    Layout.fillWidth: true
                }
                
                Controls.Button {
                    text: "View All Sets"
                    flat: true
                    onClicked: {
                        applicationWindow().pageStack.clear()
                        applicationWindow().pageStack.push("qrc:/qml/pages/SetsPage.qml", {model: model})
                    }
                }
            }
        }
    }
}
