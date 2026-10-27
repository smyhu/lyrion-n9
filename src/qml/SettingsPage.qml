import QtQuick 1.1
import com.nokia.meego 1.0
import "i18n.js" as T

Page {
    objectName: "settings"
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        ToolIcon { iconId: "toolbar-back"; onClicked: pageStack.pop() }
    }

    Background { }
    id: settings

    Flickable {
        anchors.fill: parent
        contentHeight: col.height + header.height + 40
        clip: true

        PageHeader { id: header; text: T.t("Ustawienia") }
        Column {
            id: col
            x: 16
            y: header.height + 12
            width: parent.width - 32
            spacing: 12


            Label { text: T.t("Adres serwera Lyrion"); color: "#a0a0a0"; font.pixelSize: 20 }
            TextField {
                id: serverField
                width: parent.width
                text: backend.server
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhPreferNumbers
            }
            Label { text: T.t("Port (interfejs WWW)"); color: "#a0a0a0"; font.pixelSize: 20 }
            TextField {
                id: portField
                width: parent.width
                text: backend.port
                inputMethodHints: Qt.ImhDigitsOnly
            }
            Label { text: T.t("Nazwa tego odtwarzacza w Lyrion"); color: "#a0a0a0"; font.pixelSize: 20 }
            TextField {
                id: nameField
                width: parent.width
                text: backend.playerName
            }
            Label { text: T.t("Nowa muzyka: liczba ostatnio dodanych albumów"); color: "#a0a0a0"; font.pixelSize: 20 }
            TextField {
                id: newField
                width: parent.width
                text: backend.newCount
                inputMethodHints: Qt.ImhDigitsOnly
            }
            Button {
                width: parent.width
                text: T.t("Zapisz")
                onClicked: {
                    var restart = backend.running && (serverField.text !== backend.server || nameField.text !== backend.playerName);
                    backend.server = serverField.text;
                    backend.port = portField.text;
                    backend.playerName = nameField.text;
                    backend.newCount = newField.text;
                                        if (restart) {
                        backend.stopPlayer();
                        backend.startPlayer();
                    }
                }
            }

            Item { width: 1; height: 16 }
            Label { text: T.t("Odtwarzacz w telefonie"); font.pixelSize: 28; font.bold: true }
            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: backend.running ? T.t("Działa. Telefon jest widoczny w Lyrion jako „%1”.", backend.playerName)
                                      : T.t("Zatrzymany. Telefon nie gra muzyki (pilot nadal działa).")
                color: backend.running ? "#b9f6ca" : "#ff8a80"
            }
            Button {
                width: parent.width
                text: backend.running ? T.t("Zatrzymaj odtwarzacz") : T.t("Uruchom odtwarzacz")
                onClicked: backend.running ? backend.stopPlayer() : backend.startPlayer()
            }
            Item {
                width: parent.width
                height: 64
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: T.t("Uruchamiaj razem z aplikacją")
                }
                Switch {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    checked: backend.autostart
                    onCheckedChanged: backend.autostart = checked
                }
            }
            Button {
                width: parent.width
                text: T.t("Pokaż dziennik odtwarzacza")
                onClicked: {
                    logDialog.message = backend.playerLog() || T.t("(pusty)");
                    logDialog.open();
                }
            }

            Item { width: 1; height: 16 }
            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: 18
                color: "#808080"
                text: T.t("Lyrion dla N9 %1 · odtwarzacz: squeezelite 2.0 (GPL-3) · adres MAC: %2", "0.5", backend.macAddress)
            }
        }
    }

    QueryDialog {
        id: logDialog
        titleText: T.t("Dziennik")
        acceptButtonText: "OK"
    }
}
