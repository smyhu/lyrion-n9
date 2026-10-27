import QtQuick 1.1
import com.nokia.meego 1.0
import "i18n.js" as T
import "lyrion.js" as Lyrion

// Uniwersalna lista w stylu natywnej Muzyki: biblioteka, listy odtwarzania,
// ulubione, radio i aplikacje (menu OPML Lyrion), wyszukiwanie.
Page {
    id: list
    objectName: "list"
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: pageStack.pop() }
        MiniPlayer { }
        ToolIcon { iconId: "toolbar-view-menu"; onClicked: mainMenu.open() }
    }

    property string kind: ""        // artists, albums, tracks, tracksall, playlists, playlisttracks, favorites, radios, apps, opml, search,
                                    // mymusic, newmusic, folder, genres, years
    property string searchType: ""  // search: "artists", "albums", "tracks" albo "" (wszystko)
    property string heading: ""
    property string param: ""       // np. "artist_id:12", "album_id:5", "playlist_id:3"
    property string cmd: ""         // OPML: polecenie (np. "favorites", "radiobrowser")
    property string itemId: ""      // OPML: pozycja w menu
    property bool needsSearch: kind === "search" && term === ""
    property string term: ""
    property bool loading: false
    property string message: ""
    property bool sections: false
    property string shuffleMode: "" // jak odtworzyć losowo: "random", "load"

    ListModel { id: items }

    function add(o) {
        items.append({
            title: o.title || "",
            subtitle: o.subtitle || "",
            extra: o.extra || "",
            image: o.image || "",
            showImage: o.showImage ? true : false,
            action: o.action || "",
            value: String(o.value === undefined ? "" : o.value),
            arrow: o.arrow ? true : false,
            playable: o.playable ? true : false,
            details: o.details ? true : false,
            section: list.sections ? Lyrion.sectionOf(o.title) : ""
        });
    }

    function done(res, emptyText) {
        list.loading = false;
        if (!res && appWindow.errorText !== "")
            list.message = T.t(appWindow.errorText);
        else if (items.count === 0)
            list.message = emptyText || T.t("Brak pozycji");
    }

    function load() {
        items.clear();
        list.message = "";
        if (kind === "favorites")
            cmd = "favorites";
        if (kind === "favorites" || kind === "opml") {
            loadOpml();
            return;
        }
        if (needsSearch && term === "")
            return;
        list.loading = true;
        var i;
        if (kind === "artists") {
            sections = true;
            shuffleMode = "random";
            appWindow.call(["artists", 0, 3000], function(res) {
                var l = res && res.artists_loop ? res.artists_loop : [];
                for (i = 0; i < l.length; i++)
                    add({ title: l[i].artist, action: "artist", value: l[i].id });
                done(res);
            });
        } else if (kind === "albums") {
            sections = param === "";
            shuffleMode = param === "" ? "random" : "";
            var q = ["albums", 0, 3000, "tags:lajy", "sort:album"];
            if (param !== "")
                q.push(param);
            appWindow.call(q, function(res) {
                var l = res && res.albums_loop ? res.albums_loop : [];
                for (i = 0; i < l.length; i++)
                    add({ title: l[i].album, subtitle: l[i].artist, extra: l[i].year && l[i].year != 0 ? String(l[i].year) : "",
                          image: Lyrion.coverById(l[i].artwork_track_id, 64), showImage: true,
                          action: "album", value: l[i].id, playable: true });
                done(res);
            });
        } else if (kind === "tracks" || kind === "playlisttracks") {
            shuffleMode = "load";
            var t = kind === "tracks" ? ["titles", 0, 500, param, "sort:tracknum", "tags:aldt"]
                                      : ["playlists", "tracks", 0, 500, param, "tags:ald"];
            appWindow.call(t, function(res) {
                var l = res ? (res.titles_loop || res.playlisttracks_loop || []) : [];
                for (i = 0; i < l.length; i++)
                    add({ title: l[i].title, subtitle: (l[i].artist || "") + (kind === "playlisttracks" && l[i].album ? " | " + l[i].album : ""),
                          extra: l[i].duration ? Lyrion.formatTime(l[i].duration) : "",
                          action: "trackin", value: i });
                done(res);
            });
        } else if (kind === "tracksall") {
            sections = true;
            shuffleMode = "random";
            appWindow.call(["titles", 0, 3000, "sort:title", "tags:ald"], function(res) {
                var l = res && res.titles_loop ? res.titles_loop : [];
                for (i = 0; i < l.length; i++)
                    add({ title: l[i].title, subtitle: (l[i].artist || "") + (l[i].album ? " | " + l[i].album : ""),
                          extra: l[i].duration ? Lyrion.formatTime(l[i].duration) : "",
                          action: "track", value: l[i].id });
                done(res);
            });
        } else if (kind === "playlists") {
            appWindow.call(["playlists", 0, 500], function(res) {
                var l = res && res.playlists_loop ? res.playlists_loop : [];
                for (i = 0; i < l.length; i++)
                    add({ title: l[i].playlist, action: "playlist", value: l[i].id, playable: true });
                done(res, T.t("Brak list odtwarzania"));
            });
        } else if (kind === "search") {
            appWindow.call(["search", 0, searchType === "" ? 50 : 300, "term:" + term], function(res) {
                var a = res && res.contributors_loop && (searchType === "" || searchType === "artists") ? res.contributors_loop : [];
                for (i = 0; i < a.length; i++)
                    add({ title: a[i].contributor, subtitle: T.t("Wykonawca"), action: "artist", value: a[i].contributor_id });
                var b = res && res.albums_loop && (searchType === "" || searchType === "albums") ? res.albums_loop : [];
                for (i = 0; i < b.length; i++)
                    add({ title: b[i].album, subtitle: T.t("Album"), action: "album", value: b[i].album_id, playable: true });
                var c = res && res.tracks_loop && (searchType === "" || searchType === "tracks") ? res.tracks_loop : [];
                for (i = 0; i < c.length; i++)
                    add({ title: c[i].track, subtitle: T.t("Utwór"), action: "track", value: c[i].track_id });
                done(res, T.t("Nic nie znaleziono"));
            });
        } else if (kind === "mymusic") {
            list.loading = false;
            add({ title: T.t("Nowa muzyka"), action: "sub", value: "newmusic", arrow: true });
            add({ title: T.t("Folder muzyki"), action: "sub", value: "folder", arrow: true });
            add({ title: T.t("Gatunki"), action: "sub", value: "genres", arrow: true });
            add({ title: T.t("Lata"), action: "sub", value: "years", arrow: true });
        } else if (kind === "newmusic") {
            shuffleMode = "";
            appWindow.call(["albums", 0, Number(backend.newCount) || 100, "sort:new", "tags:lajy"], function(res) {
                var l = res && res.albums_loop ? res.albums_loop : [];
                for (i = 0; i < l.length; i++)
                    add({ title: l[i].album, subtitle: l[i].artist, extra: l[i].year && l[i].year != 0 ? String(l[i].year) : "",
                          image: Lyrion.coverById(l[i].artwork_track_id, 64), showImage: true,
                          action: "album", value: l[i].id, playable: true });
                done(res);
            });
        } else if (kind === "folder") {
            shuffleMode = param !== "" ? "load" : "";
            var f = ["musicfolder", 0, 2000, "tags:dcu"];
            if (param !== "")
                f.push(param);
            appWindow.call(f, function(res) {
                var l = res && res.folder_loop ? res.folder_loop : [];
                for (i = 0; i < l.length; i++) {
                    var isDir = l[i].type === "folder";
                    var isTrack = l[i].type === "track";
                    if (!isDir && !isTrack && l[i].type !== "playlist")
                        continue;
                    add({ title: l[i].filename,
                          extra: isTrack && l[i].duration ? Lyrion.formatTime(l[i].duration) : "",
                          action: isDir ? "folder" : (isTrack ? "track" : "folderplaylist"),
                          value: l[i].id, arrow: isDir, playable: isDir });
                }
                done(res, T.t("Folder jest pusty"));
            });
        } else if (kind === "genres") {
            sections = true;
            appWindow.call(["genres", 0, 1000], function(res) {
                var l = res && res.genres_loop ? res.genres_loop : [];
                for (i = 0; i < l.length; i++)
                    add({ title: l[i].genre, action: "genre", value: l[i].id, arrow: true });
                done(res);
            });
        } else if (kind === "years") {
            appWindow.call(["years", 0, 1000], function(res) {
                var l = res && res.years_loop ? res.years_loop : [];
                for (i = l.length - 1; i >= 0; i--)
                    add({ title: l[i].year && l[i].year != 0 ? String(l[i].year) : T.t("Nieznany"), action: "year", value: l[i].year, arrow: true });
                done(res);
            });
        } else if (kind === "radios" || kind === "apps") {
            appWindow.call([kind, 0, 100], function(res) {
                var l = res ? (res.radioss_loop || res.appss_loop || []) : [];
                for (i = 0; i < l.length; i++) {
                    if (!l[i].cmd)
                        continue;
                    add({ title: l[i].name, image: Lyrion.imageUrl(l[i].icon, 80), showImage: true,
                          action: "opmlroot", value: l[i].cmd, arrow: true });
                }
                done(res);
            });
        }
    }

    function loadOpml() {
        if (needsSearch && term === "")
            return;
        list.loading = true;
        var o = [cmd, "items", 0, 300, "want_url:0"];
        if (itemId !== "")
            o.push("item_id:" + itemId);
        if (term !== "")
            o.push("search:" + term);
        appWindow.call(o, function(res) {
            var l = res && res.loop_loop ? res.loop_loop : [];
            var anyImage = false;
            for (var i = 0; i < l.length; i++)
                if (l[i].image || l[i].icon)
                    anyImage = true;
            for (i = 0; i < l.length; i++) {
                var it = l[i];
                var isSearch = it.type === "search";
                var deeper = it.hasitems == 1 || isSearch;
                // Pojedynczy utwór lub stacja (np. SoundCloud): stuknięcie odtwarza,
                // przytrzymanie otwiera menu. Album/lista (type "playlist") się otwiera.
                var single = it.isaudio == 1 && !isSearch && it.type !== "playlist" &&
                             it.type !== "link" && it.type !== "opml";
                add({ title: it.name || it.title || "",
                      image: Lyrion.imageUrl(it.image || it.icon || "", 80), showImage: anyImage,
                      action: isSearch ? "opmlsearch" : (single || !deeper ? (it.isaudio == 1 ? "opmlplay" : "") : "opml"),
                      value: it.id, arrow: deeper && it.isaudio != 1, playable: it.isaudio == 1,
                      details: single && deeper });
            }
            done(res, list.kind === "favorites" ? T.t("Brak ulubionych. Dodaj je gwiazdką na ekranie odtwarzania.") : "");
        });
    }

    function play(q, then, image) {
        player.streamImage = image ? Lyrion.largeImage(image, 480) : "";
        appWindow.call(q, then);
        appWindow.openNowPlaying();
    }

    function open(row) {
        var a = row.action, v = row.value;
        if (a === "artist")
            appWindow.openList({ kind: "albums", heading: row.title, param: "artist_id:" + v });
        else if (a === "album")
            appWindow.openList({ kind: "tracks", heading: row.title, param: "album_id:" + v });
        else if (a === "playlist")
            appWindow.openList({ kind: "playlisttracks", heading: row.title, param: "playlist_id:" + v });
        else if (a === "trackin")
            play(["playlistcontrol", "cmd:load", param], function() {
                appWindow.call(["playlist", "index", Number(v)]);
            });
        else if (a === "track")
            play(["playlistcontrol", "cmd:load", "track_id:" + v]);
        else if (a === "opmlroot")
            appWindow.openList({ kind: "opml", heading: row.title, cmd: v });
        else if (a === "opml")
            appWindow.openList({ kind: "opml", heading: row.title, cmd: list.cmd, itemId: v });
        else if (a === "opmlsearch")
            appWindow.openList({ kind: "opml", heading: row.title, cmd: list.cmd, itemId: v, needsSearch: true });
        else if (a === "opmlplay")
            play([list.cmd, "playlist", "play", "item_id:" + v], undefined, row.image);
        else if (a === "folderplaylist")
            play(["playlistcontrol", "cmd:load", "playlist_id:" + v]);
        else if (a === "sub")
            appWindow.openList({ kind: v, heading: row.title });
        else if (a === "folder")
            appWindow.openList({ kind: "folder", heading: row.title, param: "folder_id:" + v });
        else if (a === "genre")
            appWindow.openList({ kind: "albums", heading: row.title, param: "genre_id:" + v });
        else if (a === "year")
            appWindow.openList({ kind: "albums", heading: row.title, param: "year:" + v });
    }

    // Przytrzymanie palca: album, lista, folder -> odtwórz całość;
    // pozycja z usługi (SoundCloud, radio) -> menu jak w Lyrion.
    function hold(row) {
        if (!row.playable)
            return;
        if (row.action === "album")
            play(["playlistcontrol", "cmd:load", "album_id:" + row.value]);
        else if (row.action === "playlist")
            play(["playlistcontrol", "cmd:load", "playlist_id:" + row.value]);
        else if (row.action === "folder")
            play(["playlistcontrol", "cmd:load", "folder_id:" + row.value]);
        else if (list.cmd !== "") {
            itemMenu.row = { title: row.title, value: row.value, image: row.image, details: row.details };
            itemMenu.open();
        }
    }

    ContextMenu {
        id: itemMenu
        property variant row: ({})
        MenuLayout {
            MenuItem {
                text: T.t("Odtwórz")
                onClicked: list.play([list.cmd, "playlist", "play", "item_id:" + itemMenu.row.value], undefined, itemMenu.row.image)
            }
            MenuItem {
                text: T.t("Odtwórz jako następny")
                onClicked: appWindow.call([list.cmd, "playlist", "insert", "item_id:" + itemMenu.row.value])
            }
            MenuItem {
                text: T.t("Dodaj do kolejki")
                onClicked: appWindow.call([list.cmd, "playlist", "add", "item_id:" + itemMenu.row.value])
            }
            MenuItem {
                text: T.t("Szczegóły")
                visible: itemMenu.row.details === true
                onClicked: appWindow.openList({ kind: "opml", heading: itemMenu.row.title, cmd: list.cmd, itemId: itemMenu.row.value })
            }
        }
    }

    function shufflePlay() {
        if (shuffleMode === "random") {
            play(["randomplay", "tracks"]);
        } else {
            play(["playlistcontrol", "cmd:load", param], function() {
                appWindow.call(["playlist", "shuffle", 1]);
            });
        }
    }

    Component.onCompleted: load()

    Background { }

    ListView {
        id: view
        anchors.fill: parent
        model: items
        clip: true
        cacheBuffer: 400
        header: Column {
            width: view.width
            PageHeader { text: list.heading }
            TextField {
                id: searchField
                visible: list.needsSearch
                x: 16
                width: parent.width - 32
                placeholderText: T.t("Szukaj…")
                inputMethodHints: Qt.ImhNoPredictiveText
                Keys.onReturnPressed: {
                    list.term = text;
                    platformCloseSoftwareInputPanel();
                    list.load();
                }
            }
            Item { width: 1; height: list.needsSearch ? 12 : 0 }
            ListRow {
                visible: list.shuffleMode !== "" && items.count > 0
                height: visible ? 80 : 0
                title: T.t("Odtwarzanie losowe")
                iconSource: "image://theme/icon-m-toolbar-shuffle-white"
                onClicked: list.shufflePlay()
            }
            Separator {
                visible: list.shuffleMode !== "" && items.count > 0 && !list.sections
                x: 16
                width: parent.width - 32
            }
        }
        section.property: "section"
        section.criteria: ViewSection.FullString
        section.delegate: SectionHeader { text: section; visible: section !== ""; height: section !== "" ? 40 : 0 }
        delegate: ListRow {
            title: model.title
            subtitle: model.subtitle
            extra: model.extra
            image: model.image
            showImage: model.showImage
            arrow: model.arrow
            onClicked: list.open(model)
            onPressAndHold: list.hold(model)
        }
    }

    SectionScroller { listView: view; visible: list.sections }
    ScrollDecorator { flickableItem: view }

    BusyIndicator {
        anchors.centerIn: parent
        running: list.loading
        visible: running
        platformStyle: BusyIndicatorStyle { size: "large" }
    }
    Label {
        anchors.centerIn: parent
        width: parent.width - 60
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: list.message
        visible: !list.loading && text !== ""
        color: "#c0c0c0"
    }
}
