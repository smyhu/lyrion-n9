import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.1
import "i18n.js" as T
import "lyrion.js" as Lyrion

PageStackWindow {
    id: appWindow

    // Pasek stanu tylko na ekranie „Teraz gra” (jak w natywnej Muzyce).
    showStatusBar: pageStack.currentPage !== null && pageStack.currentPage.objectName === "nowPlaying"

    property string errorText: ""

    function call(cmd, callback) {
        if (!Lyrion.isConfigured())
            applyServer();
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
        // Ostatnio wybrany odtwarzacz (zapamiętany), domyślnie telefon.
        property string playerId: backend.lastPlayerId !== "" ? backend.lastPlayerId : backend.macAddress
        property string playerName: backend.lastPlayerId !== "" ? backend.lastPlayerName : backend.playerName
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
        pickActivePlayer();
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

    // Wybór odtwarzacza (telefon, Yamaha, ...) na osobnej stronie.
    function choosePlayer() {
        pageStack.push(Qt.resolvedUrl("PlayersPage.qml"));
    }

    function selectPlayer(id, name) {
        player.playerId = id;
        player.playerName = name;
        player.trackId = "";
        player.url = "";
        player.title = "";
        player.cover = "";
        player.streamImage = "";
        backend.rememberPlayer(id === backend.macAddress ? "" : id, name);
        player.refresh();
    }

    // Przy starcie: jeśli wybrany odtwarzacz nie gra, a inny gra,
    // pokaż ten grający (żeby tytuł na dole był aktualny).
    function pickActivePlayer() {
        Lyrion.request("", ["players", 0, 50], function(res) {
            var l = res && res.players_loop ? res.players_loop : [];
            var mine = null, playing = null;
            for (var i = 0; i < l.length; i++) {
                if (l[i].playerid === player.playerId)
                    mine = l[i];
                else if (l[i].isplaying == 1 && playing === null)
                    playing = l[i];
            }
            if (playing !== null && (mine === null || mine.isplaying != 1))
                selectPlayer(playing.playerid, playing.name);
        });
    }

    // --- Dodawanie całej listy (np. SoundCloud Likes/Hot) utwór po utworze ---
    // Każdy utwór to osobne polecenie, więc kolejność jest zachowana, muzyka
    // rusza od razu po pierwszym, a dodawanie można przerwać z menu.
    QtObject {
        id: bulk
        property bool running: false
        property bool cancelled: false
        property string playerId: ""
        property string cmd: ""
        property string mode: ""      // "play" albo "add"
        property string title: ""
        property variant ids: []
        property int pos: 0
        property int total: 0         // ile pozycji ma lista na serwerze
        property int limit: 0
        property int added: 0
        property int failed: 0
    }
    property bool bulkRunning: bulk.running
    property string bulkProgress: bulk.pos + "/" + bulk.ids.length

    function notify(text) {
        banner.text = text;
        banner.show();
    }

    // Pobiera listę (najwyżej tyle pozycji, ile wynosi limit) i dodaje jej utwory.
    function bulkFromList(cmd, itemId, mode, title) {
        if (bulk.running) {
            notify(T.t("Trwa dodawanie (%1). Przerwij je w menu.", bulkProgress));
            return;
        }
        var limit = Lyrion.limitOf(backend.queueLimit);
        var q = [cmd, "items", 0, limit, "want_url:0"];
        if (itemId !== "")
            q.push("item_id:" + itemId);
        notify(T.t("Wczytywanie: %1…", title));
        call(q, function(res) {
            var l = res && res.loop_loop ? res.loop_loop : [];
            var ids = [];
            for (var i = 0; i < l.length; i++)
                if (Lyrion.isTrackItem(l[i]))
                    ids.push(String(l[i].id));
            var total = res && res.count !== undefined ? Number(res.count) : l.length;
            if (!res)
                notify(T.t(appWindow.errorText || "Brak połączenia z serwerem"));
            else
                bulkRun(cmd, ids, mode, title, total);
        });
    }

    // ids: identyfikatory utworów w kolejności odtwarzania.
    function bulkRun(cmd, ids, mode, title, total) {
        if (bulk.running) {
            notify(T.t("Trwa dodawanie (%1). Przerwij je w menu.", bulkProgress));
            return;
        }
        var limit = Lyrion.limitOf(backend.queueLimit);
        if (ids.length === 0) {
            notify(T.t("Brak utworów do dodania"));
            return;
        }
        if (ids.length > limit)
            ids = ids.slice(0, limit);
        bulk.playerId = player.playerId;
        bulk.cmd = cmd;
        bulk.mode = mode;
        bulk.title = title;
        bulk.ids = ids;
        bulk.pos = 0;
        bulk.total = Math.max(total || 0, ids.length);
        bulk.limit = limit;
        bulk.added = 0;
        bulk.failed = 0;
        bulk.cancelled = false;
        bulk.running = true;
        var what = bulk.total > ids.length ? T.t("%1 z %2", ids.length, bulk.total) : String(ids.length);
        notify((mode === "play" ? T.t("Odtwarzanie: %1", title) : T.t("Dodawanie do kolejki: %1", title)) + "\n" +
               T.t("Utwory: %1 (limit %2). Przerwij w menu.", what, limit));
        if (mode === "play") {
            player.streamImage = "";
            openNowPlaying();
        }
        bulkStep();
    }

    function bulkStep() {
        if (bulk.cancelled || bulk.pos >= bulk.ids.length) {
            bulkFinish();
            return;
        }
        var how = bulk.mode === "play" && bulk.pos === 0 ? "play" : "add";
        Lyrion.request(bulk.playerId, [bulk.cmd, "playlist", how, "item_id:" + bulk.ids[bulk.pos]], function(res, error) {
            if (error !== "")
                bulk.failed++;
            else
                bulk.added++;
            bulk.pos++;
            if (bulk.pos === 1 || bulk.pos % 10 === 0)
                pollSoon.restart();
            // Serwer nie odpowiada: nie męczymy go dalej.
            if (bulk.failed >= 3 && bulk.added === 0)
                bulk.cancelled = true;
            bulkStep();
        });
    }

    function bulkCancel() {
        if (bulk.running)
            bulk.cancelled = true;
    }

    function bulkFinish() {
        var text;
        if (bulk.cancelled && bulk.pos < bulk.ids.length)
            text = T.t("Przerwano. Dodano %1 z %2.", bulk.added, bulk.ids.length);
        else if (bulk.total > bulk.ids.length)
            text = T.t("Dodano %1 z %2 utworów.", bulk.added, bulk.total) + " " + T.t("Limit: %1 (Ustawienia).", bulk.limit);
        else
            text = T.t("Dodano utwory: %1.", bulk.added);
        if (bulk.failed > 0)
            text += " " + T.t("Błędy: %1.", bulk.failed);
        bulk.running = false;
        bulk.ids = [];
        player.queueVersion++;
        pollSoon.restart();
        notify(text);
    }

    InfoBanner {
        id: banner
        topMargin: 46
        timerShowTime: 4000
    }

    Menu {
        id: mainMenu
        MenuLayout {
            MenuItem {
                text: T.t("Przerwij dodawanie (%1)", appWindow.bulkProgress)
                visible: appWindow.bulkRunning
                onClicked: appWindow.bulkCancel()
            }
            MenuItem { text: T.t("Wybierz odtwarzacz"); onClicked: appWindow.choosePlayer() }
            MenuItem { text: T.t("Ustawienia"); onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
            MenuItem { text: T.t("O programie"); onClicked: aboutDialog.open() }
        }
    }

    function about() { aboutDialog.open() }

    QueryDialog {
        id: aboutDialog
        icon: "file:///opt/lyrion-n9/lyrion-n9.png"
        titleText: "Lyrion 0.6.3"
        message: T.t("Zaprojektowany i napisany przez Claude (Anthropic) wspólnie ze smyhu dla Nokii N9.\n\nPilot i odtwarzacz dla serwera Lyrion Music Server.\nOdtwarzacz: squeezelite (Ralph Irving, GPL-3).")
        acceptButtonText: T.t("Zamknij")
    }
}
