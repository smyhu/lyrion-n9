import QtQuick 1.1
import com.nokia.meego 1.0
import "i18n.js" as T
import "lyrion.js" as Lyrion

Page {
    id: home
    objectName: "home"
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        Item { width: 80; height: 64 }
        MiniPlayer { }
        ToolIcon { iconId: "toolbar-view-menu"; onClicked: mainMenu.open() }
    }

    ListModel { id: recent }

    function loadRecent() {
        appWindow.call(["albums", 0, 6, "sort:new", "tags:laj"], function(res) {
            recent.clear();
            var l = res && res.albums_loop ? res.albums_loop : [];
            for (var i = 0; i < l.length; i++)
                recent.append({ id: String(l[i].id), album: l[i].album || "",
                                cover: Lyrion.coverById(l[i].artwork_track_id, i === 0 ? 320 : 160) });
        });
    }

    // Strona startowa powstaje przed resztą okna, więc adres serwera
    // ustawiamy tu sami; pustą mozaikę wczytujemy ponownie przy powrocie.
    Component.onCompleted: {
        appWindow.applyServer();
        loadRecent();
    }
    onStatusChanged: {
        if (status === PageStatus.Active && recent.count === 0)
            loadRecent();
    }

    Connections {
        target: backend
        onSettingsChanged: home.loadRecent()
    }

    Background { }

    ListModel {
        id: menu
        ListElement { name: "Wykonawcy"; kind: "artists" }
        ListElement { name: "Albumy"; kind: "albums" }
        ListElement { name: "Utwory"; kind: "tracksall" }
        ListElement { name: "Listy odtwarzania"; kind: "playlists" }
        ListElement { name: "Ulubione"; kind: "favorites" }
        ListElement { name: "Radio"; kind: "radios" }
        ListElement { name: "Moja muzyka"; kind: "mymusic" }
        ListElement { name: "Aplikacje"; kind: "apps" }
        ListElement { name: "Szukaj"; kind: "search" }
    }

    // Kafelek okładki w mozaice.
    Component {
        id: tile
        Item {
            property int n: 0
            Rectangle { anchors.fill: parent; color: "#141414" }
            Image {
                anchors.fill: parent
                source: n < recent.count ? recent.get(n).cover : ""
                sourceSize.width: parent.width
                sourceSize.height: parent.height
                fillMode: Image.PreserveAspectCrop
                clip: true
                asynchronous: true
                smooth: true
            }
            MouseArea {
                anchors.fill: parent
                enabled: n < recent.count
                onClicked: appWindow.openList({ kind: "tracks", heading: recent.get(n).album,
                                                param: "album_id:" + recent.get(n).id })
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: content.height
        clip: true

        Column {
            id: content
            width: parent.width

            // Mozaika ostatnio dodanych albumów (jak w natywnej Muzyce).
            Item {
                width: parent.width
                height: 482
                Loader { sourceComponent: tile; x: 0; y: 0; width: 318; height: 320; onLoaded: item.n = 0 }
                Loader { sourceComponent: tile; x: 320; y: 0; width: 160; height: 159; onLoaded: item.n = 1 }
                Loader { sourceComponent: tile; x: 320; y: 161; width: 160; height: 159; onLoaded: item.n = 2 }
                Loader { sourceComponent: tile; x: 0; y: 322; width: 159; height: 160; onLoaded: item.n = 3 }
                Loader { sourceComponent: tile; x: 161; y: 322; width: 157; height: 160; onLoaded: item.n = 4 }
                Loader { sourceComponent: tile; x: 320; y: 322; width: 160; height: 160; onLoaded: item.n = 5 }
            }

            Repeater {
                model: menu
                ListRow {
                    width: content.width
                    large: true
                    title: T.t(model.name)
                    arrow: true
                    onClicked: {
                        if (model.kind === "search")
                            pageStack.push(Qt.resolvedUrl("SearchPage.qml"));
                        else
                            appWindow.openList({ kind: model.kind, heading: model.name });
                    }
                }
            }

            ListRow {
                width: content.width
                large: true
                title: T.t("Odtwarzacz")
                subtitle: player.playerName + (player.found ? "" : T.t(" (niedostępny)"))
                arrow: true
                onClicked: appWindow.choosePlayer()
            }
            Item { width: 1; height: 16 }
        }
    }
}
