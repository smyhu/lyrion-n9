import QtQuick 1.1

// Duży przycisk sterowania odtwarzaniem (poprzedni / odtwórz / następny).
Item {
    id: btn
    property string icon: ""
    signal clicked
    width: 96
    height: 80
    Image {
        anchors.centerIn: parent
        source: "image://theme/" + btn.icon + "-white"
        opacity: mouse.pressed ? 0.5 : 1.0
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: btn.clicked()
    }
}
