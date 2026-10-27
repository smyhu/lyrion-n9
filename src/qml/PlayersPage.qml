import QtQuick 1.1
import com.nokia.meego 1.0
import "i18n.js" as T
import "lyrion.js" as Lyrion

// Wybór odtwarzacza: wszystkie odtwarzacze widoczne w Lyrion.
Page {
    id: players
    objectName: "players"
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: pageStack.pop() }
        ToolIcon { iconId: "toolbar-refresh"; onClicked: players.load() }
    }

    property bool loading: false
    property string message: ""

    ListModel { id: items }

    function load() {
        items.clear();
        message = "";
        loading = true;
        Lyrion.request("", ["players", 0, 50], function(res, error) {
            players.loading = false;
            var l = res && res.players_loop ? res.players_loop : [];
            for (var i = 0; i < l.length; i++) {
                var p = l[i];
                var state = p.isplaying == 1 ? T.t("gra") : (p.power == 0 ? T.t("wyłączony") : T.t("zatrzymany"));
                if (p.connected == 0)
                    state = T.t("niepołączony");
                var kind = p.playerid === backend.macAddress ? T.t("ten telefon") : (p.modelname || "");
                items.append({ name: p.name || p.playerid, playerid: p.playerid,
                               info: (kind !== "" ? kind + " | " : "") + state });
            }
            if (!res)
                players.message = T.t(error);
            else if (items.count === 0)
                players.message = T.t("Brak odtwarzaczy");
        });
    }

    Component.onCompleted: load()

    Background { }

    ListView {
        id: view
        anchors.fill: parent
        model: items
        clip: true
        header: PageHeader { width: view.width; text: T.t("Wybierz odtwarzacz") }
        delegate: ListRow {
            title: model.name
            subtitle: model.info
            current: model.playerid === player.playerId
            onClicked: {
                appWindow.selectPlayer(model.playerid, model.name);
                pageStack.pop();
            }
        }
    }
    ScrollDecorator { flickableItem: view }

    BusyIndicator {
        anchors.centerIn: parent
        running: players.loading
        visible: running
        platformStyle: BusyIndicatorStyle { size: "large" }
    }
    Label {
        anchors.centerIn: parent
        width: parent.width - 60
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: players.message
        visible: !players.loading && text !== ""
        color: "#c0c0c0"
    }
}
