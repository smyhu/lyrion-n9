#!/usr/bin/python
# -*- coding: utf-8 -*-
# Lyrion dla N9: lokalny odtwarzacz (squeezelite) + pilot serwera Lyrion.
# Python 2.6 + PySide 1.0 (Harmattan). Interfejs w qml/.

import os
import sys
import signal
import subprocess

from PySide.QtCore import QObject, Slot, Signal, Property, QSettings, QUrl, QTimer
from PySide.QtGui import QApplication
from PySide.QtDeclarative import QDeclarativeView

APP_DIR = os.path.dirname(os.path.abspath(__file__))
SQUEEZELITE = os.path.join(APP_DIR, 'bin', 'squeezelite-n9')
LOG_FILE = '/tmp/lyrion-n9-squeezelite.log'


def wlan_mac():
    """Adres MAC karty Wi-Fi; Lyrion rozpoznaje po nim odtwarzacz."""
    for iface in ('wlan0', 'wlan1', 'eth0'):
        try:
            mac = open('/sys/class/net/%s/address' % iface).read().strip()
            if mac and mac != '00:00:00:00:00:00':
                return mac
        except IOError:
            pass
    return '00:4e:39:00:00:01'


LANGUAGES = ('pl', 'en', 'de', 'es', 'it', 'fr')


def phone_language():
    """Jezyk ustawiony w telefonie (MeeGo: gconf /meegotouch/i18n/language)."""
    code = os.environ.get('LYRION_LANG', '')  # do testow: LYRION_LANG=de
    try:
        if code:
            raise OSError
        p = subprocess.Popen(['gconftool-2', '-g', '/meegotouch/i18n/language'],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        code = p.communicate()[0].strip()
    except OSError:
        pass
    if not code:
        code = os.environ.get('LANG', '')
    code = code[:2].lower()
    if code in LANGUAGES:
        return code
    return 'en'


class Backend(QObject):
    """Ustawienia i uruchamianie squeezelite (squeezelite -o - | aplay)."""

    def __init__(self):
        QObject.__init__(self)
        self._settings = QSettings('lyrion-n9', 'lyrion-n9')
        self._mac = wlan_mac()
        self._language = phone_language()
        self._sq = None
        self._aplay = None
        self._watch = QTimer()
        self._watch.setInterval(2000)
        self._watch.timeout.connect(self._check)
        self._watch.start()

    # --- ustawienia ---
    def _get(self, key, default):
        value = self._settings.value(key, default)
        if value is None:
            return default
        return value

    settingsChanged = Signal()

    def _server(self):
        return unicode(self._get('server', '192.168.1.10'))

    def _set_server(self, value):
        self._settings.setValue('server', value.strip())
        self.settingsChanged.emit()

    def _port(self):
        return unicode(self._get('port', '9000'))

    def _set_port(self, value):
        self._settings.setValue('port', value.strip())
        self.settingsChanged.emit()

    def _name(self):
        return unicode(self._get('name', 'Nokia N9'))

    def _set_name(self, value):
        self._settings.setValue('name', value.strip())
        self.settingsChanged.emit()

    def _newcount(self):
        return unicode(self._get('newcount', '100'))

    def _set_newcount(self, value):
        self._settings.setValue('newcount', value.strip())
        self.settingsChanged.emit()

    def _autostart(self):
        return unicode(self._get('autostart', 'true')) == 'true'

    def _set_autostart(self, value):
        if value:
            self._settings.setValue('autostart', 'true')
        else:
            self._settings.setValue('autostart', 'false')
        self.settingsChanged.emit()

    server = Property(unicode, _server, _set_server, notify=settingsChanged)
    port = Property(unicode, _port, _set_port, notify=settingsChanged)
    playerName = Property(unicode, _name, _set_name, notify=settingsChanged)
    newCount = Property(unicode, _newcount, _set_newcount, notify=settingsChanged)
    autostart = Property(bool, _autostart, _set_autostart, notify=settingsChanged)

    # Ostatnio wybrany odtwarzacz ("" = ten telefon).
    lastPlayerChanged = Signal()

    def _last_id(self):
        return unicode(self._get('lastplayer', ''))

    def _last_name(self):
        return unicode(self._get('lastplayername', ''))

    lastPlayerId = Property(unicode, _last_id, notify=lastPlayerChanged)
    lastPlayerName = Property(unicode, _last_name, notify=lastPlayerChanged)

    @Slot(unicode, unicode)
    def rememberPlayer(self, playerid, name):
        self._settings.setValue('lastplayer', playerid)
        self._settings.setValue('lastplayername', name)
        self._settings.sync()
        self.lastPlayerChanged.emit()

    def _macaddr(self):
        return self._mac

    macChanged = Signal()
    macAddress = Property(unicode, _macaddr, notify=macChanged)

    languageChanged = Signal()

    def _lang(self):
        return self._language

    language = Property(unicode, _lang, notify=languageChanged)

    # --- lokalny odtwarzacz ---
    runningChanged = Signal()

    def _running(self):
        return self._sq is not None and self._sq.poll() is None

    running = Property(bool, _running, notify=runningChanged)

    @Slot()
    def startPlayer(self):
        if self._running():
            return
        self.stopPlayer()
        log = open(LOG_FILE, 'w')
        cmd = [SQUEEZELITE, '-s', self._server(), '-n', self._name().encode('utf-8'),
               '-m', self._mac, '-o', '-', '-a', '16', '-r', '44100']
        try:
            self._sq = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=log)
            self._aplay = subprocess.Popen(['aplay', '-q', '-t', 'raw', '-f', 'cd'],
                                           stdin=self._sq.stdout, stderr=log)
            self._sq.stdout.close()
        except OSError, e:
            log.write('Blad uruchomienia: %s\n' % e)
            self._sq = None
            self._aplay = None
        log.close()
        self.runningChanged.emit()

    @Slot()
    def stopPlayer(self):
        for p in (self._sq, self._aplay):
            if p is not None and p.poll() is None:
                try:
                    os.kill(p.pid, signal.SIGTERM)
                except OSError:
                    pass
        for p in (self._sq, self._aplay):
            if p is not None:
                try:
                    p.wait()
                except OSError:
                    pass
        self._sq = None
        self._aplay = None
        self.runningChanged.emit()

    @Slot(result=unicode)
    def playerLog(self):
        try:
            return unicode(open(LOG_FILE).read()[-2000:], 'utf-8', 'replace')
        except IOError:
            return u''

    def _check(self):
        # Zglasza do QML, gdy odtwarzacz sam sie zakonczyl.
        if self._sq is not None and self._sq.poll() is not None:
            self.stopPlayer()


def main():
    app = QApplication(sys.argv)
    backend = Backend()
    view = QDeclarativeView()
    view.rootContext().setContextProperty('backend', backend)
    view.setSource(QUrl.fromLocalFile(os.path.join(APP_DIR, 'qml', 'main.qml')))
    view.showFullScreen()
    if backend.autostart:
        backend.startPlayer()
    app.aboutToQuit.connect(backend.stopPlayer)
    signal.signal(signal.SIGTERM, lambda *a: app.quit())
    # Pozwala Pythonowi obsluzyc SIGTERM w trakcie petli Qt.
    tick = QTimer()
    tick.timeout.connect(lambda: None)
    tick.start(500)
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
