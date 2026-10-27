import QtQuick 1.1
import com.nokia.meego 1.0
import "i18n.js" as T
import "lyrion.js" as Lyrion

// Ekran „Teraz gra” wzorowany na natywnej Muzyce.
// Dotknięcie okładki: okładka odjeżdża w górę, opis w dół, pojawia się lista utworów.
Page {
    id: page
    objectName: "nowPlaying"
    orientationLock: PageOrientation.LockPortrait

    property bool queueMode: false
    property bool seeking: false
    property real seekValue: 0

    tools: ToolBarLayout {
        ToolIcon {
            iconId: "toolbar-back"
            onClicked: page.queueMode ? page.queueMode = false : pageStack.pop()
        }
        ToolIcon {
            iconId: player.favorite ? "toolbar-favorite-mark" : "toolbar-favorite-unmark"
            enabled: player.url !== ""
            onClicked: player.toggleFavorite()
        }
        ToolIcon {
            iconId: "toolbar-shuffle"
            opacity: player.shuffle > 0 ? 1.0 : 0.4
            onClicked: appWindow.call(["playlist", "shuffle", player.shuffle > 0 ? 0 : 1])
        }
        ToolIcon {
            iconId: "toolbar-repeat"
            opacity: player.repeat > 0 ? 1.0 : 0.4
            // 0 = wyłączone, 2 = cała lista, 1 = jeden utwór
            onClicked: appWindow.call(["playlist", "repeat", player.repeat === 0 ? 2 : (player.repeat === 2 ? 1 : 0)])
            Label {
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                text: "1"
                font.pixelSize: 16
                font.bold: true
                visible: player.repeat === 1
            }
        }
        ToolIcon { iconId: "toolbar-view-menu"; onClicked: npMenu.open() }
    }

    Rectangle { anchors.fill: parent; color: "black" }

    // --- kolejka (lista utworów bieżącego odtwarzania) ---
    ListModel { id: queue }

    function loadQueue() {
        appWindow.call(["status", 0, 500, "tags:adl"], function(res) {
            queue.clear();
            var l = res && res.playlist_loop ? res.playlist_loop : [];
            for (var i = 0; i < l.length; i++)
                queue.append({ title: l[i].title || "", subtitle: l[i].artist || "",
                               extra: l[i].duration ? Lyrion.formatTime(l[i].duration) : "",
                               idx: Number(l[i]["playlist index"]) });
            queueView.positionViewAtIndex(Math.max(0, player.index - 1), ListView.Beginning);
        });
    }

    Connections {
        target: player
        onQueueVersionChanged: if (page.queueMode) page.loadQueue()
    }

    ListView {
        id: queueView
        width: page.width
        anchors.top: parent.top
        anchors.bottom: controlsBox.top
        model: queue
        clip: true
        opacity: page.queueMode ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        header: PageHeader { text: player.album !== "" ? player.album : T.t("Kolejka odtwarzania") }
        delegate: ListRow {
            title: model.title
            subtitle: model.subtitle
            extra: model.extra
            current: model.idx === player.index
            onClicked: {
                appWindow.call(["playlist", "index", model.idx]);
                page.queueMode = false;
            }
        }
    }
    ScrollDecorator { flickableItem: queueView; visible: page.queueMode }

    // --- okładka na całą szerokość ---
    Item {
        id: coverBox
        width: page.width
        height: page.width
        y: page.queueMode ? -height : 0
        Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }

        Rectangle {
            anchors.fill: parent
            color: "#141414"
            visible: cover.status !== Image.Ready
            Image { anchors.centerIn: parent; source: "../lyrion-n9.png" }
        }
        Image {
            id: cover
            anchors.fill: parent
            source: player.cover
            sourceSize.width: 480
            sourceSize.height: 480
            fillMode: Image.PreserveAspectCrop
            clip: true
            asynchronous: true
            smooth: true
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                page.loadQueue();
                page.queueMode = true;
            }
        }
    }

    // --- dolna część: przyciski, postęp i czasy (zawsze na miejscu) ---
    Rectangle {
        id: controlsBox
        z: 2
        width: page.width
        height: 150
        anchors.bottom: parent.bottom
        color: "black"

        Item {
            id: controls
            width: parent.width
            height: 80
            y: 0
            ControlButton {
                x: 44 - width / 2
                icon: "icon-m-toolbar-mediacontrol-previous"
                onClicked: appWindow.call(["button", "jump_rew"])
            }
            ControlButton {
                x: page.width / 2 - width / 2
                icon: player.mode === "play" ? "icon-m-toolbar-mediacontrol-pause" : "icon-m-toolbar-mediacontrol-play"
                onClicked: {
                    if (player.mode === "play")
                        appWindow.call(["pause", "1"]);
                    else if (player.mode === "pause")
                        appWindow.call(["pause", "0"]);
                    else
                        appWindow.call(["play"]);
                }
            }
            ControlButton {
                x: page.width - 44 - width / 2
                icon: "icon-m-toolbar-mediacontrol-next"
                onClicked: appWindow.call(["button", "jump_fwd"])
            }
        }

        ProgressBar {
            id: progressBar
            x: 24
            width: parent.width - 48
            anchors.bottom: timeRow.top
            anchors.bottomMargin: 8
            minimumValue: 0
            maximumValue: player.duration > 0 ? player.duration : 1
            value: page.seeking ? page.seekValue : (player.duration > 0 ? player.time : 0)
            MouseArea {
                anchors.fill: parent
                anchors.margins: -20
                enabled: player.duration > 0
                onPressed: {
                    page.seekValue = Math.max(0, Math.min(1, (mouse.x - 20) / progressBar.width)) * player.duration;
                    page.seeking = true;
                }
                onPositionChanged: page.seekValue = Math.max(0, Math.min(1, (mouse.x - 20) / progressBar.width)) * player.duration
                onReleased: {
                    var t = Math.max(0, Math.min(1, (mouse.x - 20) / progressBar.width)) * player.duration;
                    appWindow.call(["time", Math.floor(t)]);
                    page.seeking = false;
                }
            }
        }
        Item {
            id: timeRow
            x: 24
            width: parent.width - 48
            height: 26
            anchors.bottom: parent.bottom
            // ten sam odstęp nad czasami (do paska postępu) i pod nimi (do paska narzędzi)
            anchors.bottomMargin: 8
            Label {
                text: Lyrion.formatTime(page.seeking ? page.seekValue : player.time)
                font.family: "Nokia Pure Text Light"
                font.pixelSize: 20
                color: "#8c8c8c"
            }
            Label {
                anchors.right: parent.right
                text: player.duration > 0 ? Lyrion.formatTime(player.duration) : ""
                font.family: "Nokia Pure Text Light"
                font.pixelSize: 20
                color: "#8c8c8c"
            }
        }
    }

    // --- górna część opisu: tytuł, wykonawca, album, „…” ---
    // W trybie listy zjeżdża w dół i chowa się za dolną częścią.
    Rectangle {
        id: infoBox
        z: 1
        width: page.width
        height: controlsBox.y - page.width
        y: page.queueMode ? controlsBox.y : page.width
        color: "black"
        Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }

        Label {
            id: titleLabel
            x: 16
            y: 10
            width: parent.width - 32 - indexLabel.width - 12
            text: player.title !== "" ? player.title : (player.found ? T.t("Nic nie gra") : T.t("Odtwarzacz niedostępny"))
            font.pixelSize: 26
            font.bold: true
            elide: Text.ElideRight
        }
        Label {
            id: indexLabel
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.baseline: titleLabel.baseline
            text: player.count > 0 ? (player.index + 1) + "/" + player.count : ""
            font.family: "Nokia Pure Text Light"
            font.pixelSize: 24
            color: "#8c8c8c"
        }
        Column {
            anchors.top: titleLabel.bottom
            anchors.topMargin: 4
            x: 16
            width: parent.width - 32 - 56
            Label {
                width: parent.width
                text: player.artist
                font.family: "Nokia Pure Text Light"
                font.pixelSize: 24
                color: "#8c8c8c"
                elide: Text.ElideRight
                visible: text !== ""
            }
            Label {
                width: parent.width
                text: player.album
                font.family: "Nokia Pure Text Light"
                font.pixelSize: 24
                color: "#8c8c8c"
                elide: Text.ElideRight
                visible: text !== ""
            }
        }
        // Przycisk „…” – szczegóły utworu
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 16
            y: titleLabel.y + titleLabel.height + 8
            width: 32
            height: 32
            radius: 16
            color: infoMouse.pressed ? "#8c8c8c" : "white"
            visible: player.title !== ""
            Row {
                anchors.centerIn: parent
                spacing: 3
                Repeater {
                    model: 3
                    Rectangle { width: 5; height: 5; radius: 2.5; color: "black" }
                }
            }
            MouseArea {
                id: infoMouse
                anchors.fill: parent
                anchors.margins: -12
                onClicked: pageStack.push(Qt.resolvedUrl("InfoPage.qml"))
            }
        }
    }

    Menu {
        id: npMenu
        MenuLayout {
            MenuItem { text: T.t("Szczegóły utworu"); onClicked: pageStack.push(Qt.resolvedUrl("InfoPage.qml")) }
            MenuItem { text: T.t("Wyczyść kolejkę"); onClicked: appWindow.call(["playlist", "clear"]) }
            MenuItem { text: T.t("Wybierz odtwarzacz"); onClicked: appWindow.choosePlayer() }
            MenuItem { text: T.t("Ustawienia"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
            MenuItem { text: T.t("O programie"); onClicked: appWindow.about() }
        }
    }
}
