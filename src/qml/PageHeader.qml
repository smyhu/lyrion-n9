import QtQuick 1.1
import com.nokia.meego 1.0

// Nagłówek strony: duży, lekki tytuł i linia pod nim.
Item {
    property alias text: label.text
    width: parent ? parent.width : 480
    height: 62
    Label {
        id: label
        x: 16
        width: parent.width - 32
        height: 58
        verticalAlignment: Text.AlignVCenter
        font.family: "Nokia Pure Text Light"
        font.pixelSize: 32
        elide: Text.ElideRight
        color: "white"
    }
    Separator { x: 16; y: 58; width: parent.width - 32 }
}
