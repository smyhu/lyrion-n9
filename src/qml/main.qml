import QtQuick 1.1
import com.nokia.meego 1.0
import "i18n.js" as T
import "lyrion.js" as Lyrion

PageStackWindow {
    id: appWindow

    // Pasek stanu tylko na ekranie „Teraz gra” (jak w natywnej Muzyce).
    showStatusBar: pageStack.currentPage !== null && pageStack.currentPage.objectName === "nowPlaying"

    property string errorText: ""

    function call(cmd, callback) {
        Lyrion.request(player.playerId, cmd, function(result, error) {
            appWindow.errorText = error;
            if (callback)
                callback(result);
            if (cmd[0] !== "status")
                pollSoon.restart();
        });
    }

    function applyServer() {
        Lyrion.setServer(backend.server, backend.port);
    }

    function openNowPlaying() {
        if (pageStack.currentPage.objectName !== "nowPlaying")
            pageStack.push(Qt.resolvedUrl("NowPlayingPage.qml"));
    }

    function openList(props) {
        pageStack.push(Qt.resolvedUrl("ListPage.qml"), props);
    }

    // Stan wybranego odtwarzacza, odświeżany co sekundę.
    QtObject {
        id: player
        property string playerId: backend.macAddress
        property string playerName: backend.playerName
        property bool found: false
        property string mode: "stop"
        property real time: 0
        property real duration: 0
        property string title: ""
        property string shortTitle: Lyrion.shorten(title, 18)
        property string artist: ""
        property string album: ""
        property string cover: ""
        property string trackId: ""
        property string url: ""
        property bool remote: false
        property int index: 0
        property int count: 0
        property int shuffle: 0
        property int repeat: 0
        property bool favorite: false
        property string favoriteIndex: ""
        property int queueVersion: 0
        // Obraz pozycji (np. stacji radiowej) wybranej z listy; zastępuje
        // ogólną ikonę radia, gdy strumień nie podaje własnej okładki.
        property string streamImage: ""

        function refresh() {
            appWindow.call(["status", "-", 1, "tags:acdlKNuJ"], function(res) {
                if (!res || res.mode === undefined) {
                    player.found = false;
                    return;
                }
                player.found = true;
                player.mode = res.mode;
                player.time = res.time || 0;
                player.duration = res.duration || 0;
                player.index = Number(res.playlist_cur_index || 0);
                if (Number(res.playlist_tracks || 0) !== player.count) {
                    player.count = Number(res.playlist_tracks || 0);
                    player.queueVersion++;
                }
                player.shuffle = Number(res["playlist shuffle"] || 0);
                player.repeat = Number(res["playlist repeat"] || 0);
                var t = (res.playlist_loop && res.playlist_loop.length) ? res.playlist_loop[0] : null;
                var title = t ? (t.title || "") : "";
                if (res.remote && res.current_title)
                    title = res.current_title;
                player.title = title;
                player.artist = t ? (t.artist || t.remote_title || "") : "";
                player.album = t ? (t.album || "") : "";
                player.remote = res.remote == 1;
                var id = t ? String(t.id) : "";
                var cover = Lyrion.coverForTrack(t, player.playerId, 480);
                if (res.remote == 1 && player.streamImage !== "" && Lyrion.isGenericArtwork(t ? t.artwork_url : ""))
                    cover = player.streamImage;
                if (cover !== player.cover)
                    player.cover = cover;
                if (id !== player.trackId) {
                    player.trackId = id;
                    player.queueVersion++;
                }
                var url = t ? (t.url || "") : "";
                if (url !== player.url) {
                    player.url = url;
                    player.checkFavorite();
                }
            });
        }

        function checkFavorite() {
            if (player.url === "") {
                player.favorite = false;
                return;
            }
            Lyrion.request("", ["favorites", "exists", player.url], function(res) {
                player.favorite = res && res.exists == 1;
                player.favoriteIndex = res && res.index !== undefined ? String(res.index) : "";
            });
        }

        function toggleFavorite() {
            if (player.url === "")
                return;
            var cmd = player.favorite ? ["favorites", "delete", "item_id:" + player.favoriteIndex]
                                      : ["favorites", "add", "url:" + player.url, "title:" + player.title];
            Lyrion.request("", cmd, function() { player.checkFavorite(); });
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: Qt.application.active
        triggeredOnStart: true
        onTriggered: player.refresh()
    }
    Timer {
        id: pollSoon
        interval: 300
        onTriggered: player.refresh()
    }

    Component.onCompleted: {
        theme.inverted = true;
        applyServer();
    }

    Connections {
        target: backend
        onSettingsChanged: {
            applyServer();
            if (player.playerId === backend.macAddress)
                player.playerName = backend.playerName;
        }
    }

    initialPage: HomePage { }

    // Wybór odtwarzacza (telefon, Yamaha, ...)
    ListModel { id: playersModel }

    SelectionDialog {
        id: playersDialog
        titleText: T.t("Odtwarzacz")
        model: playersModel
        onAccepted: {
            var p = playersModel.get(selectedIndex);
            player.playerId = p.playerid;
            player.playerName = p.name;
            player.trackId = "";
            player.url = "";
            player.refresh();
        }
    }

    function choosePlayer() {
        Lyrion.request("", ["players", 0, 50], function(res) {
            playersModel.clear();
            if (!res || !res.players_loop)
                return;
            for (var i = 0; i < res.players_loop.length; i++) {
                var p = res.players_loop[i];
                playersModel.append({ name: p.name, playerid: p.playerid });
                if (p.playerid === player.playerId)
                    playersDialog.selectedIndex = i;
            }
            playersDialog.open();
        });
    }

    Menu {
        id: mainMenu
        MenuLayout {
            MenuItem { text: T.t("Wybierz odtwarzacz"); onClicked: appWindow.choosePlayer() }
            MenuItem { text: T.t("Ustawienia"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
            MenuItem { text: T.t("O programie"); onClicked: aboutDialog.open() }
        }
    }

    function about() { aboutDialog.open() }

    QueryDialog {
        id: aboutDialog
        icon: "file:///opt/lyrion-n9/lyrion-n9.png"
        titleText: "Lyrion 0.5.0"
        message: T.t("Zaprojektowany i napisany przez Claude (Anthropic) wspólnie ze smyhu dla Nokii N9.\n\nPilot i odtwarzacz dla serwera Lyrion Music Server.\nOdtwarzacz: squeezelite (Ralph Irving, GPL-3).")
        acceptButtonText: T.t("Zamknij")
    }
}
