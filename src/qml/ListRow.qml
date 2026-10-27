import QtQuick 1.1
import com.nokia.meego 1.0

// Wiersz listy w stylu natywnej Muzyki.
Item {
    id: row
    property string title: ""
    property string subtitle: ""
    property string extra: ""        // np. czas trwania, rok
    property string image: ""
    property bool showImage: false   // rezerwuje miejsce na miniaturę
    property bool arrow: false
    property bool large: false       // większy tekst (menu główne)
    property bool current: false     // bieżący utwór w kolejce
    property string iconSource: ""   // ikona zamiast miniatury
    signal clicked
    signal pressAndHold

    width: ListView.view ? ListView.view.width : (parent ? parent.width : 480)
    height: large ? 74 : 80

    Rectangle {
        anchors.fill: parent
        color: "#3c3c3c"
        opacity: 0.6
        visible: mouse.pressed
    }
    Item {
        id: thumbBox
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        width: row.showImage || row.iconSource !== "" ? 64 : 0
        height: 64
        Rectangle {
            anchors.fill: parent
            color: "#1e1e1e"
            visible: row.showImage && thumb.status !== Image.Ready
        }
        Image {
            id: thumb
            anchors.fill: parent
            source: row.image
            sourceSize.width: 64
            sourceSize.height: 64
            fillMode: Image.PreserveAspectCrop
            clip: true
            asynchronous: true
            smooth: true
        }
        Image {
            anchors.centerIn: parent
            source: row.iconSource
        }
    }
    Label {
        id: titleLabel
        anchors.left: thumbBox.right
        anchors.leftMargin: thumbBox.width > 0 ? 16 : 0
        anchors.right: chevron.left
        anchors.rightMargin: 12
        y: row.subtitle !== "" ? 12 : (row.height - height) / 2
        text: row.title
        font.pixelSize: row.large ? 30 : 26
        font.bold: true
        color: row.current ? "#5ba7e6" : "white"
        elide: Text.ElideRight
    }
    Label {
        anchors.left: titleLabel.left
        anchors.right: extraLabel.left
        anchors.rightMargin: 12
        anchors.top: titleLabel.bottom
        anchors.topMargin: 2
        text: row.subtitle
        font.family: "Nokia Pure Text Light"
        font.pixelSize: 22
        color: "#c0c0c0"
        elide: Text.ElideRight
        visible: text !== ""
    }
    Label {
        id: extraLabel
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: row.subtitle !== "" ? 14 : (row.height - height) / 2
        text: row.extra
        font.family: "Nokia Pure Text Light"
        font.pixelSize: 22
        color: "#c0c0c0"
    }
    Image {
        id: chevron
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        source: row.arrow ? "image://theme/icon-m-common-drilldown-arrow-inverse" : ""
        width: row.arrow ? sourceSize.width : 0
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: row.clicked()
        onPressAndHold: row.pressAndHold()
    }
}
