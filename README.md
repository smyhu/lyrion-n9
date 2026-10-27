# Lyrion for the Nokia N9

*Opis po polsku poniżej.*

A [Lyrion Music Server](https://lyrion.org) (formerly Logitech Media Server) client for the
Nokia N9 (MeeGo Harmattan PR1.3), written in 2026. The phone becomes both a player and a remote,
with the look of the N9's own Music app. Designed and written by Claude (Anthropic) together
with smyhu.

- **Player in the phone:** a bundled, statically built [squeezelite](https://github.com/ralph-irving/squeezelite)
  plays MP3, FLAC, Ogg Vorbis, Opus and AAC streams from the server (`squeezelite -o - | aplay`).
- **Remote:** choose any player on the server (e.g. a network amplifier) and control it from the N9.
- **Now playing:** cover, track info, seek, volume and queue.
- **Library:** artists, albums, songs, playlists, favourites, new music, folders, genres and
  years. Global search across the library and server apps (radio, SoundCloud and others).
- **Server apps (SoundCloud, Spotty, radio):** tap a track to play it; press and hold for
  Play / Play next / Add to queue / Details. Covers from these services are fetched and
  resized by the server, so the phone never needs HTTPS.
- **Players:** a list of all players on the server; the app remembers the last one and, on
  start, switches to a player that is already playing.
- **Languages:** Polish, English, German, Spanish, Italian and French, following the phone
  language. Any other language falls back to English.

SoundCloud needs the [SqueezeCloud](https://github.com/danielvijge/SqueezeCloud) plugin and
ffmpeg on the server. In the official Docker image ffmpeg can be added with a `custom-init.sh`
in `/config` (`apt-get update && apt-get install -y ffmpeg`).

The server address and player name are set in Settings. The app talks to the server over plain
HTTP JSON-RPC on the home network (port 9000).

## Install

Copy `dist/lyrion-n9_0.6.1_armel.deb` to `/home/developer` on the phone (`/tmp` on the N9 has
only 4 MB), then as root (developer mode):

```
aegis-dpkg -i /home/developer/lyrion-n9_0.6.1_armel.deb
```

Requirements: PySide and alsa-utils, both present on a standard PR1.3 phone.

## Layout

| Part | What it does |
|---|---|
| `src/main.py` | PySide launcher: settings, language, starts and stops squeezelite |
| `src/qml/` | UI (Harmattan Qt Components), JSON-RPC client (`lyrion.js`), translations (`i18n.js`) |
| `squeezelite/` | prebuilt static `squeezelite-n9` (ARMv7 hard-float, musl), its licence and build notes |
| `packaging/` | Debian control file and launcher entry |

`./build-deb.sh` builds the package into `dist/`.

## Licences and sources

- Lyrion for N9 (everything outside `squeezelite/`): MIT (`LICENSE`).
- squeezelite: GPL-3.0 (`squeezelite/LICENSE-squeezelite.txt`). The binary was built from
  [ralph-irving/squeezelite](https://github.com/ralph-irving/squeezelite) at commit
  `4e0ec3188320da7de059c571499e626ff8b3712f` with static libogg, libvorbis, flac, opus, opusfile,
  libmad, faad2 and alsa-lib. The exact recipe is in `squeezelite/BUILDING-pl.md` (Polish).
- The waveform in the icon comes from the Lyrion logo.

---

## Po polsku

Aplikacja dla Nokii N9 (MeeGo Harmattan PR1.3), napisana w 2026 r. Zamienia telefon w
odtwarzacz i pilot serwera Lyrion Music Server, w wyglądzie natywnej aplikacji Muzyka.
Zaprojektowana i napisana przez Claude (Anthropic) wspólnie ze smyhu.

- **Odtwarzacz w telefonie:** wbudowany squeezelite odtwarza MP3, FLAC, Ogg, Opus i AAC.
- **Pilot:** sterowanie dowolnym odtwarzaczem na serwerze, np. wzmacniaczem sieciowym.
- **Biblioteka:** wykonawcy, albumy, utwory, listy, ulubione, nowości, foldery, gatunki i lata.
- **Wyszukiwanie** w bibliotece i w aplikacjach serwera (radio, SoundCloud).
- **Aplikacje serwera (SoundCloud, Spotty, radio):** stuknięcie utworu go odtwarza,
  przytrzymanie otwiera menu (Odtwórz, Odtwórz jako następny, Dodaj do kolejki, Szczegóły).
  Okładki pobiera i zmniejsza serwer, więc telefon nie potrzebuje HTTPS.
- **Odtwarzacze:** lista wszystkich odtwarzaczy; aplikacja pamięta ostatni wybrany.
- **Sześć języków**, zależnie od języka telefonu.

Instalacja: skopiuj `dist/lyrion-n9_0.6.1_armel.deb` do `/home/developer` w telefonie i jako
root wpisz `aegis-dpkg -i /home/developer/lyrion-n9_0.6.1_armel.deb`.

Licencja: MIT (plik `LICENSE`); wbudowany squeezelite jest na licencji GPL-3.0.
