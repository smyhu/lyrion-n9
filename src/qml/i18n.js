// Wersje językowe. Klucze to teksty polskie (język źródłowy aplikacji),
// tłumaczenia: en, de, es, it, fr. Język wybiera main.py (język telefonu);
// język nieobsługiwany -> angielski.
// Bez ".pragma library", żeby mieć dostęp do obiektu „backend”.

var dict = {
 "Odtwórz": {
  "en": "Play",
  "de": "Abspielen",
  "es": "Reproducir",
  "it": "Riproduci",
  "fr": "Lire"
 },
 "Odtwórz jako następny": {
  "en": "Play next",
  "de": "Als Nächstes abspielen",
  "es": "Reproducir a continuación",
  "it": "Riproduci come successivo",
  "fr": "Lire ensuite"
 },
 "Dodaj do kolejki": {
  "en": "Add to queue",
  "de": "Zur Warteschlange hinzufügen",
  "es": "Añadir a la cola",
  "it": "Aggiungi alla coda",
  "fr": "Ajouter à la file"
 },
 "Szczegóły": {
  "en": "Details",
  "de": "Details",
  "es": "Detalles",
  "it": "Dettagli",
  "fr": "Détails"
 },
 "gra": {
  "en": "playing",
  "de": "spielt",
  "es": "reproduciendo",
  "it": "in riproduzione",
  "fr": "en lecture"
 },
 "wyłączony": {
  "en": "off",
  "de": "aus",
  "es": "apagado",
  "it": "spento",
  "fr": "éteint"
 },
 "zatrzymany": {
  "en": "stopped",
  "de": "gestoppt",
  "es": "detenido",
  "it": "fermo",
  "fr": "arrêté"
 },
 "niepołączony": {
  "en": "not connected",
  "de": "nicht verbunden",
  "es": "no conectado",
  "it": "non connesso",
  "fr": "non connecté"
 },
 "ten telefon": {
  "en": "this phone",
  "de": "dieses Telefon",
  "es": "este teléfono",
  "it": "questo telefono",
  "fr": "ce téléphone"
 },
 "Brak odtwarzaczy": {
  "en": "No players",
  "de": "Keine Player",
  "es": "No hay reproductores",
  "it": "Nessun lettore",
  "fr": "Aucun lecteur"
 },
 "O programie": {
  "en": "About",
  "de": "Über",
  "es": "Acerca de",
  "it": "Informazioni",
  "fr": "À propos"
 },
 "Zamknij": {
  "en": "Close",
  "de": "Schließen",
  "es": "Cerrar",
  "it": "Chiudi",
  "fr": "Fermer"
 },
 "Zaprojektowany i napisany przez Claude (Anthropic) wspólnie ze smyhu dla Nokii N9.\n\nPilot i odtwarzacz dla serwera Lyrion Music Server.\nOdtwarzacz: squeezelite (Ralph Irving, GPL-3).": {
  "en": "Designed and written by Claude (Anthropic) together with smyhu for the Nokia N9.\n\nRemote and player for Lyrion Music Server.\nPlayer: squeezelite (Ralph Irving, GPL-3).",
  "de": "Entworfen und geschrieben von Claude (Anthropic) gemeinsam mit smyhu für das Nokia N9.\n\nFernbedienung und Player für Lyrion Music Server.\nPlayer: squeezelite (Ralph Irving, GPL-3).",
  "es": "Diseñada y escrita por Claude (Anthropic) junto con smyhu para el Nokia N9.\n\nMando y reproductor para Lyrion Music Server.\nReproductor: squeezelite (Ralph Irving, GPL-3).",
  "it": "Progettata e scritta da Claude (Anthropic) insieme a smyhu per il Nokia N9.\n\nTelecomando e lettore per Lyrion Music Server.\nLettore: squeezelite (Ralph Irving, GPL-3).",
  "fr": "Conçue et écrite par Claude (Anthropic) avec smyhu pour le Nokia N9.\n\nTélécommande et lecteur pour Lyrion Music Server.\nLecteur : squeezelite (Ralph Irving, GPL-3)."
 },
 "Wykonawcy": {
  "en": "Artists",
  "de": "Interpreten",
  "es": "Artistas",
  "it": "Artisti",
  "fr": "Artistes"
 },
 "Albumy": {
  "en": "Albums",
  "de": "Alben",
  "es": "Álbumes",
  "it": "Album",
  "fr": "Albums"
 },
 "Utwory": {
  "en": "Songs",
  "de": "Titel",
  "es": "Canciones",
  "it": "Brani",
  "fr": "Morceaux"
 },
 "Listy odtwarzania": {
  "en": "Playlists",
  "de": "Wiedergabelisten",
  "es": "Listas de reproducción",
  "it": "Playlist",
  "fr": "Listes de lecture"
 },
 "Ulubione": {
  "en": "Favourites",
  "de": "Favoriten",
  "es": "Favoritos",
  "it": "Preferiti",
  "fr": "Favoris"
 },
 "Radio": {
  "en": "Radio",
  "de": "Radio",
  "es": "Radio",
  "it": "Radio",
  "fr": "Radio"
 },
 "Moja muzyka": {
  "en": "My Music",
  "de": "Meine Musik",
  "es": "Mi música",
  "it": "La mia musica",
  "fr": "Ma musique"
 },
 "Aplikacje": {
  "en": "Apps",
  "de": "Apps",
  "es": "Aplicaciones",
  "it": "App",
  "fr": "Applications"
 },
 "Szukaj": {
  "en": "Search",
  "de": "Suchen",
  "es": "Buscar",
  "it": "Cerca",
  "fr": "Rechercher"
 },
 "Odtwarzacz": {
  "en": "Player",
  "de": "Player",
  "es": "Reproductor",
  "it": "Lettore",
  "fr": "Lecteur"
 },
 " (niedostępny)": {
  "en": " (unavailable)",
  "de": " (nicht verfügbar)",
  "es": " (no disponible)",
  "it": " (non disponibile)",
  "fr": " (indisponible)"
 },
 "Numer utworu": {
  "en": "Track number",
  "de": "Titelnummer",
  "es": "Número de pista",
  "it": "Numero traccia",
  "fr": "Numéro de piste"
 },
 "Wykonawca": {
  "en": "Artist",
  "de": "Interpret",
  "es": "Artista",
  "it": "Artista",
  "fr": "Artiste"
 },
 "Wykonawca albumu": {
  "en": "Album artist",
  "de": "Albuminterpret",
  "es": "Artista del álbum",
  "it": "Artista album",
  "fr": "Artiste de l'album"
 },
 "Album": {
  "en": "Album",
  "de": "Album",
  "es": "Álbum",
  "it": "Album",
  "fr": "Album"
 },
 "Rok": {
  "en": "Year",
  "de": "Jahr",
  "es": "Año",
  "it": "Anno",
  "fr": "Année"
 },
 "Gatunek": {
  "en": "Genre",
  "de": "Genre",
  "es": "Género",
  "it": "Genere",
  "fr": "Genre"
 },
 "Kompozytor": {
  "en": "Composer",
  "de": "Komponist",
  "es": "Compositor",
  "it": "Compositore",
  "fr": "Compositeur"
 },
 "Format": {
  "en": "Format",
  "de": "Format",
  "es": "Formato",
  "it": "Formato",
  "fr": "Format"
 },
 "Rozmiar": {
  "en": "Size",
  "de": "Größe",
  "es": "Tamaño",
  "it": "Dimensione",
  "fr": "Taille"
 },
 "Długość": {
  "en": "Duration",
  "de": "Dauer",
  "es": "Duración",
  "it": "Durata",
  "fr": "Durée"
 },
 "Jakość transmisji": {
  "en": "Bit rate",
  "de": "Bitrate",
  "es": "Tasa de bits",
  "it": "Bitrate",
  "fr": "Débit"
 },
 "Częstotliwość próbkowania": {
  "en": "Sample rate",
  "de": "Abtastrate",
  "es": "Frecuencia de muestreo",
  "it": "Frequenza di campionamento",
  "fr": "Fréquence d'échantillonnage"
 },
 "Rozdzielczość": {
  "en": "Bit depth",
  "de": "Bittiefe",
  "es": "Profundidad de bits",
  "it": "Profondità di bit",
  "fr": "Résolution"
 },
 "Kanały": {
  "en": "Channels",
  "de": "Kanäle",
  "es": "Canales",
  "it": "Canali",
  "fr": "Canaux"
 },
 "Bezstratny": {
  "en": "Lossless",
  "de": "Verlustfrei",
  "es": "Sin pérdida",
  "it": "Senza perdita",
  "fr": "Sans perte"
 },
 "Data dodania": {
  "en": "Date added",
  "de": "Hinzugefügt am",
  "es": "Fecha de adición",
  "it": "Data aggiunta",
  "fr": "Date d'ajout"
 },
 "Ostatnia zmiana": {
  "en": "Last modified",
  "de": "Zuletzt geändert",
  "es": "Última modificación",
  "it": "Ultima modifica",
  "fr": "Dernière modification"
 },
 "Liczba odtworzeń": {
  "en": "Play count",
  "de": "Wiedergaben",
  "es": "Reproducciones",
  "it": "Riproduzioni",
  "fr": "Nombre de lectures"
 },
 "Ostatnio odtworzono": {
  "en": "Last played",
  "de": "Zuletzt gespielt",
  "es": "Última reproducción",
  "it": "Ultima riproduzione",
  "fr": "Dernière lecture"
 },
 "Adres": {
  "en": "Address",
  "de": "Adresse",
  "es": "Dirección",
  "it": "Indirizzo",
  "fr": "Adresse"
 },
 "Stacja": {
  "en": "Station",
  "de": "Sender",
  "es": "Emisora",
  "it": "Stazione",
  "fr": "Station"
 },
 "Tak": {
  "en": "Yes",
  "de": "Ja",
  "es": "Sí",
  "it": "Sì",
  "fr": "Oui"
 },
 "Nie": {
  "en": "No",
  "de": "Nein",
  "es": "No",
  "it": "No",
  "fr": "Non"
 },
 "Właściwości": {
  "en": "Properties",
  "de": "Eigenschaften",
  "es": "Propiedades",
  "it": "Proprietà",
  "fr": "Propriétés"
 },
 "Brak pozycji": {
  "en": "No items",
  "de": "Keine Einträge",
  "es": "Sin elementos",
  "it": "Nessun elemento",
  "fr": "Aucun élément"
 },
 "Brak list odtwarzania": {
  "en": "No playlists",
  "de": "Keine Wiedergabelisten",
  "es": "No hay listas de reproducción",
  "it": "Nessuna playlist",
  "fr": "Aucune liste de lecture"
 },
 "Utwór": {
  "en": "Song",
  "de": "Titel",
  "es": "Canción",
  "it": "Brano",
  "fr": "Morceau"
 },
 "Nic nie znaleziono": {
  "en": "Nothing found",
  "de": "Nichts gefunden",
  "es": "No se encontró nada",
  "it": "Nessun risultato",
  "fr": "Aucun résultat"
 },
 "Nowa muzyka": {
  "en": "New Music",
  "de": "Neue Musik",
  "es": "Música nueva",
  "it": "Nuova musica",
  "fr": "Nouveautés"
 },
 "Folder muzyki": {
  "en": "Music Folder",
  "de": "Musikordner",
  "es": "Carpeta de música",
  "it": "Cartella musica",
  "fr": "Dossier musique"
 },
 "Gatunki": {
  "en": "Genres",
  "de": "Genres",
  "es": "Géneros",
  "it": "Generi",
  "fr": "Genres"
 },
 "Lata": {
  "en": "Years",
  "de": "Jahre",
  "es": "Años",
  "it": "Anni",
  "fr": "Années"
 },
 "Folder jest pusty": {
  "en": "The folder is empty",
  "de": "Der Ordner ist leer",
  "es": "La carpeta está vacía",
  "it": "La cartella è vuota",
  "fr": "Le dossier est vide"
 },
 "Nieznany": {
  "en": "Unknown",
  "de": "Unbekannt",
  "es": "Desconocido",
  "it": "Sconosciuto",
  "fr": "Inconnu"
 },
 "Brak ulubionych. Dodaj je gwiazdką na ekranie odtwarzania.": {
  "en": "No favourites yet. Add them with the star on the playback screen.",
  "de": "Noch keine Favoriten. Füge sie mit dem Stern im Wiedergabebildschirm hinzu.",
  "es": "Aún no hay favoritos. Añádelos con la estrella en la pantalla de reproducción.",
  "it": "Nessun preferito. Aggiungili con la stella nella schermata di riproduzione.",
  "fr": "Aucun favori. Ajoutez-les avec l'étoile sur l'écran de lecture."
 },
 "Szukaj…": {
  "en": "Search…",
  "de": "Suchen…",
  "es": "Buscar…",
  "it": "Cerca…",
  "fr": "Rechercher…"
 },
 "Odtwarzanie losowe": {
  "en": "Shuffle play",
  "de": "Zufallswiedergabe",
  "es": "Reproducción aleatoria",
  "it": "Riproduzione casuale",
  "fr": "Lecture aléatoire"
 },
 "Nic nie gra": {
  "en": "Nothing playing",
  "de": "Keine Wiedergabe",
  "es": "No se reproduce nada",
  "it": "Nessuna riproduzione",
  "fr": "Aucune lecture"
 },
 "Odtwarzacz niedostępny": {
  "en": "Player unavailable",
  "de": "Player nicht verfügbar",
  "es": "Reproductor no disponible",
  "it": "Lettore non disponibile",
  "fr": "Lecteur indisponible"
 },
 "Kolejka odtwarzania": {
  "en": "Play queue",
  "de": "Warteschlange",
  "es": "Cola de reproducción",
  "it": "Coda di riproduzione",
  "fr": "File de lecture"
 },
 "Szczegóły utworu": {
  "en": "Song details",
  "de": "Titeldetails",
  "es": "Detalles de la canción",
  "it": "Dettagli brano",
  "fr": "Détails du morceau"
 },
 "Wyczyść kolejkę": {
  "en": "Clear queue",
  "de": "Warteschlange leeren",
  "es": "Vaciar la cola",
  "it": "Svuota la coda",
  "fr": "Vider la file"
 },
 "Wybierz odtwarzacz": {
  "en": "Choose player",
  "de": "Player wählen",
  "es": "Elegir reproductor",
  "it": "Scegli lettore",
  "fr": "Choisir le lecteur"
 },
 "Ustawienia": {
  "en": "Settings",
  "de": "Einstellungen",
  "es": "Ajustes",
  "it": "Impostazioni",
  "fr": "Paramètres"
 },
 "Wpisz i naciśnij Enter": {
  "en": "Type and press Enter",
  "de": "Eingeben und Enter drücken",
  "es": "Escribe y pulsa Intro",
  "it": "Digita e premi Invio",
  "fr": "Saisissez puis appuyez sur Entrée"
 },
 "Adres serwera Lyrion": {
  "en": "Lyrion server address",
  "de": "Adresse des Lyrion-Servers",
  "es": "Dirección del servidor Lyrion",
  "it": "Indirizzo del server Lyrion",
  "fr": "Adresse du serveur Lyrion"
 },
 "Port (interfejs WWW)": {
  "en": "Port (web interface)",
  "de": "Port (Weboberfläche)",
  "es": "Puerto (interfaz web)",
  "it": "Porta (interfaccia web)",
  "fr": "Port (interface web)"
 },
 "Nazwa tego odtwarzacza w Lyrion": {
  "en": "Name of this player in Lyrion",
  "de": "Name dieses Players in Lyrion",
  "es": "Nombre de este reproductor en Lyrion",
  "it": "Nome di questo lettore in Lyrion",
  "fr": "Nom de ce lecteur dans Lyrion"
 },
 "Nowa muzyka: liczba ostatnio dodanych albumów": {
  "en": "New Music: number of recently added albums",
  "de": "Neue Musik: Anzahl zuletzt hinzugefügter Alben",
  "es": "Música nueva: número de álbumes añadidos recientemente",
  "it": "Nuova musica: numero di album aggiunti di recente",
  "fr": "Nouveautés : nombre d'albums ajoutés récemment"
 },
 "Zapisz": {
  "en": "Save",
  "de": "Speichern",
  "es": "Guardar",
  "it": "Salva",
  "fr": "Enregistrer"
 },
 "Odtwarzacz w telefonie": {
  "en": "Player on this phone",
  "de": "Player auf diesem Telefon",
  "es": "Reproductor en este teléfono",
  "it": "Lettore su questo telefono",
  "fr": "Lecteur sur ce téléphone"
 },
 "Działa. Telefon jest widoczny w Lyrion jako „%1”.": {
  "en": "Running. The phone appears in Lyrion as “%1”.",
  "de": "Läuft. Das Telefon erscheint in Lyrion als „%1“.",
  "es": "En marcha. El teléfono aparece en Lyrion como «%1».",
  "it": "In funzione. Il telefono appare in Lyrion come «%1».",
  "fr": "En marche. Le téléphone apparaît dans Lyrion sous le nom « %1 »."
 },
 "Zatrzymany. Telefon nie gra muzyki (pilot nadal działa).": {
  "en": "Stopped. The phone does not play music (the remote still works).",
  "de": "Gestoppt. Das Telefon spielt keine Musik (die Fernbedienung funktioniert weiter).",
  "es": "Detenido. El teléfono no reproduce música (el mando sigue funcionando).",
  "it": "Fermo. Il telefono non riproduce musica (il telecomando funziona comunque).",
  "fr": "Arrêté. Le téléphone ne joue pas de musique (la télécommande fonctionne toujours)."
 },
 "Zatrzymaj odtwarzacz": {
  "en": "Stop player",
  "de": "Player stoppen",
  "es": "Detener reproductor",
  "it": "Ferma lettore",
  "fr": "Arrêter le lecteur"
 },
 "Uruchom odtwarzacz": {
  "en": "Start player",
  "de": "Player starten",
  "es": "Iniciar reproductor",
  "it": "Avvia lettore",
  "fr": "Démarrer le lecteur"
 },
 "Uruchamiaj razem z aplikacją": {
  "en": "Start with the app",
  "de": "Mit der App starten",
  "es": "Iniciar con la aplicación",
  "it": "Avvia con l'app",
  "fr": "Démarrer avec l'application"
 },
 "Pokaż dziennik odtwarzacza": {
  "en": "Show player log",
  "de": "Player-Protokoll anzeigen",
  "es": "Mostrar registro del reproductor",
  "it": "Mostra registro del lettore",
  "fr": "Afficher le journal du lecteur"
 },
 "(pusty)": {
  "en": "(empty)",
  "de": "(leer)",
  "es": "(vacío)",
  "it": "(vuoto)",
  "fr": "(vide)"
 },
 "Dziennik": {
  "en": "Log",
  "de": "Protokoll",
  "es": "Registro",
  "it": "Registro",
  "fr": "Journal"
 },
 "Lyrion dla N9 %1 · odtwarzacz: squeezelite 2.0 (GPL-3) · adres MAC: %2": {
  "en": "Lyrion for N9 %1 · player: squeezelite 2.0 (GPL-3) · MAC address: %2",
  "de": "Lyrion für N9 %1 · Player: squeezelite 2.0 (GPL-3) · MAC-Adresse: %2",
  "es": "Lyrion para N9 %1 · reproductor: squeezelite 2.0 (GPL-3) · dirección MAC: %2",
  "it": "Lyrion per N9 %1 · lettore: squeezelite 2.0 (GPL-3) · indirizzo MAC: %2",
  "fr": "Lyrion pour N9 %1 · lecteur : squeezelite 2.0 (GPL-3) · adresse MAC : %2"
 },
 "Brak połączenia z serwerem": {
  "en": "Cannot connect to the server",
  "de": "Keine Verbindung zum Server",
  "es": "No se puede conectar con el servidor",
  "it": "Impossibile connettersi al server",
  "fr": "Connexion au serveur impossible"
 },
 "Błędna odpowiedź serwera": {
  "en": "Invalid server response",
  "de": "Ungültige Serverantwort",
  "es": "Respuesta del servidor no válida",
  "it": "Risposta del server non valida",
  "fr": "Réponse du serveur invalide"
 },
 "Język": {
  "en": "Language",
  "de": "Sprache",
  "es": "Idioma",
  "it": "Lingua",
  "fr": "Langue"
 },
 "Polski": {
  "en": "Polish",
  "de": "Polnisch",
  "es": "Polaco",
  "it": "Polacco",
  "fr": "Polonais"
 }
};

// t("tekst", a1, a2): tłumaczenie z podstawieniem %1 i %2.
function t(s, a1, a2) {
    var lang = backend.language;
    var r = s;
    if (lang !== "pl") {
        var e = dict[s];
        if (e !== undefined)
            r = e[lang] !== undefined ? e[lang] : e["en"];
    }
    if (a1 !== undefined)
        r = r.replace("%1", a1);
    if (a2 !== undefined)
        r = r.replace("%2", a2);
    return r;
}
