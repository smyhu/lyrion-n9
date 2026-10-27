#!/bin/sh
# Builds dist/lyrion-n9_<version>_armel.deb from this tree (any Linux with dpkg-deb).
set -e
cd "$(dirname "$0")"
VERSION=$(sed -n 's/^Version: //p' packaging/DEBIAN/control)
P=$(mktemp -d)
chmod 755 $P
mkdir -p $P/DEBIAN $P/opt/lyrion-n9/bin $P/usr/share/applications
cp packaging/DEBIAN/control $P/DEBIAN/
cp src/main.py src/lyrion-n9.png $P/opt/lyrion-n9/
cp -r src/qml $P/opt/lyrion-n9/
cp squeezelite/squeezelite-n9 squeezelite/LICENSE-squeezelite.txt $P/opt/lyrion-n9/bin/
cp packaging/lyrion-n9.desktop $P/usr/share/applications/
chmod 755 $P/opt/lyrion-n9/bin/squeezelite-n9
mkdir -p dist
dpkg-deb -Zgzip --root-owner-group -b $P dist/lyrion-n9_${VERSION}_armel.deb
rm -rf $P
