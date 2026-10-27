import QtQuick 1.1
import com.nokia.meego 1.0
import "i18n.js" as T
import "lyrion.js" as Lyrion

// Szczegóły bieżącego utworu (jak „Info o utworze” w natywnej Muzyce).
Page {
    id: info
    objectName: "info"
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: pageStack.pop() }
    }

    ListModel { id: tagsModel }    // numer, wykonawca, album, rok, gatunek
    ListModel { id: propsModel }   // format, rozmiar, długość, ...

    // Klucze z odpowiedzi "songinfo" i ich polskie nazwy.
    property variant tagNames: ({
        "tracknum": "Numer utworu", "artist": "Wykonawca", "albumartist": "Wykonawca albumu",
        "album": "Album", "year": "Rok", "genre": "Gatunek", "composer": "Kompozytor"
    })
    property variant propNames: ({
        "type": "Format", "filesize": "Rozmiar", "duration": "Długość", "bitrate": "Jakość transmisji",
        "samplerate": "Częstotliwość próbkowania", "samplesize": "Rozdzielczość", "channels": "Kanały",
        "lossless": "Bezstratny", "addedTime": "Data dodania", "lastUpdated": "Ostatnia zmiana",
        "playcount": "Liczba odtworzeń", "lastplayed": "Ostatnio odtworzono", "url": "Adres", "remote_title": "Stacja"
    })

    function fmt(key, v) {
        if (key === "filesize")
            return (Number(v) / 1048576).toFixed(1).replace(".", ",") + " MB";
        if (key === "duration")
            return Lyrion.formatTime(v);
        if (key === "samplerate")
            return (Number(v) / 1000).toFixed(1).replace(".", ",") + " kHz";
        if (key === "samplesize")
            return v + " bit";
        if (key === "lossless")
            return v == 1 ? T.t("Tak") : T.t("Nie");
        if (key === "addedTime" || key === "lastUpdated" || key === "lastplayed") {
            var d = new Date(Number(v) * 1000);
            return Qt.formatDateTime(d, "dd.MM.yyyy hh:mm");
        }
        return String(v);
    }

    Component.onCompleted: {
        var sel = player.remote || player.trackId === "" || Number(player.trackId) < 0
                ? "url:" + player.url : "track_id:" + player.trackId;
        appWindow.call(["songinfo", 0, 100, sel, "tags:aAlygtdfrTIoXmLu"], function(res) {
            var l = res && res.songinfo_loop ? res.songinfo_loop : [];
            for (var i = 0; i < l.length; i++) {
                for (var k in l[i]) {
                    var v = l[i][k];
                    if (v === "" || v === undefined || v === null)
                        continue;
                    if (info.tagNames[k] !== undefined)
                        tagsModel.append({ label: info.tagNames[k], value: info.fmt(k, v) });
                    else if (info.propNames[k] !== undefined)
                        propsModel.append({ label: info.propNames[k], value: info.fmt(k, v) });
                }
            }
        });
    }

    Background { }

    Flickable {
        anchors.fill: parent
        contentHeight: col.height + 20
        clip: true

        Column {
            id: col
            width: parent.width
            PageHeader { text: player.title }
            Item {
                width: parent.width
                height: Math.max(170, tagsCol.height + 20)
                Image {
                    id: thumb
                    x: 16
                    y: 10
                    width: 150
                    height: 150
                    source: player.cover
                    sourceSize.width: 150
                    sourceSize.height: 150
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                    smooth: true
                }
                Column {
                    id: tagsCol
                    anchors.left: thumb.right
                    anchors.leftMargin: 16
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    y: 8
                    Repeater {
                        model: tagsModel
                        Label {
                            width: tagsCol.width
                            text: T.t(model.label) + ": " + model.value
                            font.family: "Nokia Pure Text Light"
                            font.pixelSize: 24
                            elide: Text.ElideRight
                        }
                    }
                }
            }
            Item {
                width: parent.width
                height: 44
                Separator {
                    x: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 32 - propsLabel.width - 16
                }
                Label {
                    id: propsLabel
                    anchors.right: parent.right
                    anchors.rightMargin: 30
                    anchors.verticalCenter: parent.verticalCenter
                    text: T.t("Właściwości")
                    font.pixelSize: 20
                    font.bold: true
                    color: "#737373"
                }
            }
            Repeater {
                model: propsModel
                Label {
                    x: 16
                    width: col.width - 32
                    text: T.t(model.label) + ": " + model.value
                    font.family: "Nokia Pure Text Light"
                    font.pixelSize: 22
                    wrapMode: Text.WrapAnywhere
                    maximumLineCount: 3
                }
            }
        }
    }
}
