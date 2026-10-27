import QtQuick 1.1
import com.nokia.meego 1.0

// Nagłówek sekcji listy: linia i litera po prawej.
Item {
    property string text: ""
    width: parent ? parent.width : 480
    height: 40
    Separator {
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 80
    }
    Label {
        anchors.right: parent.right
        anchors.rightMargin: 24
        anchors.verticalCenter: parent.verticalCenter
        text: parent.text
        font.pixelSize: 18
        font.bold: true
        color: "#737373"
    }
}
