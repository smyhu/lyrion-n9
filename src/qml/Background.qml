import QtQuick 1.1

// Tło jak w natywnej aplikacji Muzyka: czarne z promienistym, szarym rozjaśnieniem.
// Ekran N9 pracuje w 16 bitach (RGB565), więc obraz jest już przygotowany
// w tej palecie z ditheringiem; nie skalujemy go ani nie wygładzamy.
Image {
    anchors.fill: parent
    source: "tlo.png"
    fillMode: Image.Stretch
    smooth: false
}
