// Zapytania JSON-RPC do serwera Lyrion (http://serwer:9000/jsonrpc.js).
.pragma library

var baseUrl = "";

function setServer(server, port) {
    baseUrl = "http://" + server + ":" + port;
}

// cmd: tablica, np. ["status", "-", 1, "tags:al"]; callback(wynik lub null, blad)
function request(playerId, cmd, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== XMLHttpRequest.DONE)
            return;
        if (!callback)
            return;
        if (xhr.status === 200) {
            try {
                callback(JSON.parse(xhr.responseText).result, "");
            } catch (e) {
                callback(null, "Błędna odpowiedź serwera");
            }
        } else {
            callback(null, "Brak połączenia z serwerem");
        }
    };
    xhr.open("POST", baseUrl + "/jsonrpc.js");
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.send(JSON.stringify({ id: 1, method: "slim.request", params: [playerId, cmd] }));
}

function imageUrl(path) {
    if (!path)
        return "";
    path = String(path);
    if (path.indexOf("http") === 0)
        return path;
    if (path.charAt(0) !== "/")
        path = "/" + path;
    return baseUrl + path;
}

// Okładka utworu z biblioteki (po coverid) w zadanym rozmiarze.
function coverById(coverId, size) {
    if (!coverId)
        return "";
    return baseUrl + "/music/" + coverId + "/cover_" + size + "x" + size + "_o";
}

// Okładka bieżącego utworu w odpowiedzi "status".
function coverForTrack(t, playerId, size) {
    if (!t)
        return "";
    if (t.artwork_url)
        return imageUrl(t.artwork_url);
    if (t.coverid)
        return coverById(t.coverid, size);
    return baseUrl + "/music/current/cover_" + size + "x" + size + "_o?player=" +
           encodeURIComponent(playerId) + "&s=" + encodeURIComponent(String(t.id) + (t.title || ""));
}

function formatTime(seconds) {
    seconds = Math.floor(seconds || 0);
    var h = Math.floor(seconds / 3600);
    var m = Math.floor((seconds % 3600) / 60);
    var s = seconds % 60;
    var ss = (s < 10 ? "0" : "") + s;
    if (h > 0)
        return h + ":" + (m < 10 ? "0" : "") + m + ":" + ss;
    return m + ":" + ss;
}

// Litera sekcji listy (jak w natywnej Muzyce).
function sectionOf(text) {
    if (!text)
        return "";
    return String(text).charAt(0).toUpperCase();
}

function shorten(text, max) {
    text = text || "";
    return text.length > max ? text.substring(0, max - 1) + "…" : text;
}

// Czy okładka strumienia to ogólna ikona (np. wieża radiowa z Lyrion/wtyczki)?
function isGenericArtwork(url) {
    if (!url)
        return true;
    url = String(url);
    return url.indexOf("html/images/") >= 0 || url.indexOf("/plugins/") >= 0 ||
           url.indexOf("plugins/") === 0 || url.indexOf("radio.png") >= 0;
}

// Większa wersja obrazu z serwera (miniatury z listy bywają małe).
function largeImage(url, size) {
    if (!url)
        return "";
    var m = /^(.*\/imageproxy\/.*\/image)(_[0-9x]+[^.]*)?(\.[a-z]+)$/.exec(url);
    if (m)
        return m[1] + "_" + size + "x" + size + "_o" + m[3];
    return url;
}
