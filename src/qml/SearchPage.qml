import QtQuick 1.1
import com.nokia.meego 1.0
import "i18n.js" as T
import "lyrion.js" as Lyrion

// Wyszukiwanie z wyborem kategorii: najpierw hasło, potem gdzie szukać
// (biblioteka: wykonawcy / albumy / utwory, albo usługi z „Szukaj wszędzie” Lyrion:
// radio, SoundCloud itd.).
Page {
    id: search
    objectName: "search"
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: pageStack.pop() }
        MiniPlayer { }
        ToolIcon { iconId: "toolbar-view-menu"; onClicked: mainMenu.open() }
    }

    property string term: ""
    property bool loading: false

    ListModel { id: cats }

    function run() {
        cats.clear();
        if (term === "")
            return;
        loading = true;
        // Biblioteka: liczba wyników w każdej kategorii.
        appWindow.call(["search", 0, 1, "term:" + term], function(res) {
            var n = function(k) { return res && res[k] ? Number(res[k]) : 0; };
            cats.insert(0, { title: T.t("Utwory"), sub: T.t("Moja muzyka"), extra: String(n("tracks_count")), kind: "lib", value: "tracks" });
            cats.insert(0, { title: T.t("Albumy"), sub: T.t("Moja muzyka"), extra: String(n("albums_count")), kind: "lib", value: "albums" });
            cats.insert(0, { title: T.t("Wykonawcy"), sub: T.t("Moja muzyka"), extra: String(n("contributors_count")), kind: "lib", value: "artists" });
        });
        // Pozostałe źródła z wyszukiwania globalnego Lyrion.
        appWindow.call(["globalsearch", "items", 0, 50, "search:" + term], function(res) {
            search.loading = false;
            var l = res && res.loop_loop ? res.loop_loop : [];
            for (var i = 0; i < l.length; i++) {
                var name = l[i].name || l[i].title || "";
                if (name === "" || l[i].hasitems != 1)
                    continue;
                cats.append({ title: name, sub: "", extra: "", kind: "global", value: String(l[i].id) });
            }
        });
    }

    Background { }

    ListView {
        id: view
        anchors.fill: parent
        model: cats
        clip: true
        header: Column {
            width: view.width
            PageHeader { text: T.t("Szukaj") }
            Item { width: 1; height: 8 }
            TextField {
                id: field
                x: 16
                width: parent.width - 32
                placeholderText: T.t("Wpisz i naciśnij Enter")
                inputMethodHints: Qt.ImhNoPredictiveText
                Keys.onReturnPressed: {
                    search.term = text;
                    platformCloseSoftwareInputPanel();
                    search.run();
                }
                Component.onCompleted: forceActiveFocus()
            }
            Item { width: 1; height: 12 }
        }
        delegate: ListRow {
            title: model.title
            subtitle: model.sub
            extra: model.extra
            arrow: true
            onClicked: {
                if (model.kind === "lib")
                    appWindow.openList({ kind: "search", heading: model.title + ": " + search.term,
                                         term: search.term, searchType: model.value });
                else
                    appWindow.openList({ kind: "opml", heading: model.title, cmd: "globalsearch", itemId: model.value });
            }
        }
    }

    BusyIndicator {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 300
        running: search.loading
        visible: running
        platformStyle: BusyIndicatorStyle { size: "large" }
    }
}
