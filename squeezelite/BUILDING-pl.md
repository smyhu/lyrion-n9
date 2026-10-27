# Jak zbudowano squeezelite-n9 (26.10.2026, kontener w chmurze, Linux x86_64)

- Kompilator: zig 0.17.0 (`pip install ziglang`), cel `-target arm-linux-musleabihf -mcpu=cortex_a8 -fno-sanitize=all` (WAŻNE: bez tej flagi zig cc dokleja kontrolę UBSan i libmad przerywa odtwarzanie MP3 błędem „index out of bounds”), linkowanie statyczne.
- Biblioteki statyczne (źródła z deb.debian.org pool, *.orig.tar.*): libogg 1.3.5, libvorbis 1.3.7, flac 1.4.2, opus 1.5.2, opusfile 0.12 (--disable-http), libmad 0.15.1b (--host=arm-linux-gnueabi --enable-fpm=arm, z Makefile usunięte flagi gcc -fthread-jumps itd.), faad2 2.11.2 (cmake), alsa-lib 1.2.12 (alsa-project.org).
- squeezelite: github.com/ralph-irving/squeezelite commit 4e0ec3188320da7de059c571499e626ff8b3712f
  `LDADD="-lpthread -lm -lrt" make CC=cc CFLAGS="-O2 -I$P/include -I$P/include/opus" OPTS="-DLINKALL -DOPUS -DNO_MPG123 -DDSD" LDFLAGS="-static -L$P/lib"`, potem `llvm-strip`.
- ALSA w środku jest statyczna i nie wczyta wtyczki „pulse”, dlatego wyjście `-o -` przez potok do systemowego `aplay`.
