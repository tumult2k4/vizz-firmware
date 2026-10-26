# vizz-firmware

Zutaten für **Vizz**, einen persönlichen Fork der Skiff-Firmware (<https://github.com/illuminus5/skiff>, GPL-3.0)
für die M-VAVE FM-1, abgestimmt auf den Browser-Visualizer VIZZ. Dieser Branch: **Vizz 2.0** auf Skiff 2.0.1.

- **SEQ MIDI OUT**: der Sequencer spielt über USB-MIDI mit (Noten je Spur auf ihrem Kanal, auch mit eigenen Längen,
  Überlappungen, Ties und Ketten; CC 102 = Step-Index im spielenden Teil; MIDI Clock, Start/Stop) – `patches/0001`
- **Mute/Solo über CC 103**: stumme Spuren (MUTE getippt oder gehalten, SOLO) senden keine Noten, ihr Zustand kommt als
  CC 103 – `patches/0002`, Spezifikation `docs/FIRMWARE-MUTE.md`
- **Name**: Vizz statt Skiff (Splash, ABOUT, Loader), Version 2.0, Paket `vizz-2.0.fwsc` mit der Kennung `FM-1_820`,
  Installer als eine HTML-Datei mit Skiffs Backup und Konvertierung beim Update von Vizz 1.x – `patches/0003`
- **Tests**: der Installer gegen ein simuliertes Gerät mit Vizz 1.0 (`patches/0004`), die Gegenprobe (`patches/0005`)

`patches/` ist die vollständige Serie ab Skiff `v2.0.1` (`git format-patch v2.0.1..vizz-2.0`), anzuwenden mit
`git am -3 patches/*.patch` auf einem Branch ab dem Tag `v2.0.1`. Was sich ändert, was getestet ist und wie man von
Vizz 1.0 aktualisiert (und zurückkommt): [CHANGES.md](CHANGES.md).

Bauen: `./build-vizz.sh` (Linux x86-64 oder WSL; braucht github.com, gitee.com, pkgman.jieliapp.com und dessen
Download-Host jl-update.oss-cn-shenzhen.aliyuncs.com, für Emscripten storage.googleapis.com) klont Skiff, wendet die
Patches an, holt Toolchain, SDK und Emscripten, baut das Release und den Konverter, lässt alle Tests laufen und legt
`out/vizz-2.0.fwsc`, `out/vizz-installer.html` und `out/SHA256SUMS` (mit den Lizenztexten) ab.

| Version | Basis | Auftrag | Ergebnis |
| --- | --- | --- | --- |
| Vizz 1.0 | Skiff 1.4 | [BRIEF.md](BRIEF.md) | Branch `vizz-1.0`, `out/vizz-1.0.fwsc` |
| Vizz 2.0 | Skiff 2.0.1 | [BRIEF-2.0.md](BRIEF-2.0.md) | Branch `vizz-2.0`, `out/vizz-2.0.fwsc` |
