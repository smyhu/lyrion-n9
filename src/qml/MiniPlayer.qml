import QtQuick 1.1
import com.nokia.meego 1.0

// Przycisk „teraz gra” na dolnym pasku (jak w natywnej Muzyce).
ToolButton {
    visible: player.title !== ""
    width: 230
    iconSource: player.mode === "play" ? "image://theme/icon-m-toolbar-mediacontrol-pause-white"
                                       : "image://theme/icon-m-toolbar-mediacontrol-play-white"
    text: player.shortTitle
    onClicked: appWindow.openNowPlaying()
}
