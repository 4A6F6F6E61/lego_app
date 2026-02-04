import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.lego.app 1.0

Kirigami.ScrollablePage {
    id: setsPage
    
    title: "All Sets"
    
    required property var model
    
    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        
        // Currently Building Section
        ColumnLayout {
            Layout.fillWidth: true
            visible: buildingRepeater.count > 0
            
            Kirigami.Heading {
                text: "Currently Building"
                level: 3
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: Math.max(1, Math.floor(setsPage.width / 320))
                columnSpacing: Kirigami.Units.largeSpacing
                rowSpacing: Kirigami.Units.largeSpacing
                
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
        
        // Backlog Section
        ColumnLayout {
            Layout.fillWidth: true
            visible: backlogRepeater.count > 0
            
            Kirigami.Heading {
                text: "Backlog"
                level: 3
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: Math.max(1, Math.floor(setsPage.width / 320))
                columnSpacing: Kirigami.Units.largeSpacing
                rowSpacing: Kirigami.Units.largeSpacing
                
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
        
        // Built Section
        ColumnLayout {
            Layout.fillWidth: true
            visible: builtRepeater.count > 0
            
            Kirigami.Heading {
                text: "Built"
                level: 3
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: Math.max(1, Math.floor(setsPage.width / 320))
                columnSpacing: Kirigami.Units.largeSpacing
                rowSpacing: Kirigami.Units.largeSpacing
                
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
        
        // Empty state
        Kirigami.PlaceholderMessage {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: buildingRepeater.count === 0 && backlogRepeater.count === 0 && builtRepeater.count === 0
            icon.name: "view-list-icons"
            text: "No sets in collection"
        }
    }
}
