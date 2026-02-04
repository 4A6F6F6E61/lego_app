import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Card {
    id: setCard
    
    required property var setData
    
    banner {
        source: setData.imgUrl || ""
        title: setData.name
        titleIcon: "games-highscores"
    }
    
    contentItem: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing
        
        Controls.Label {
            text: "Set #: " + setData.setNum
            color: Kirigami.Theme.disabledTextColor
        }
        
        Controls.Label {
            text: "Year: " + (setData.year || "Unknown")
            color: Kirigami.Theme.disabledTextColor
        }
        
        Controls.Label {
            text: {
                switch (setData.status) {
                    case 0: return "Status: Backlog"
                    case 1: return "Status: Currently Building"
                    case 2: return "Status: Built"
                    default: return "Status: Unknown"
                }
            }
            font.bold: true
        }
    }
    
    // Add click handler to navigate to details (if implemented)
    // onClicked: {
    //     applicationWindow().pageStack.push("qrc:/qml/pages/DetailsPage.qml", {setId: setData.id})
    // }
}
