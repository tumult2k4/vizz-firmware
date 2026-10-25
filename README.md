# vizz-firmware

Zutaten für **Vizz**, einen persönlichen Fork der Skiff-Firmware (<https://github.com/illuminus5/skiff>, GPL-3.0)
für die M-VAVE FM-1, abgestimmt auf den Browser-Visualizer VIZZ:

- **SEQ MIDI OUT**: der Sequencer spielt über USB-MIDI mit (Noten je Spur auf ihrem Kanal, CC 102 = Step-Index,
  MIDI Clock, Start/Stop) – `patches/0001`, `patches/0002`
- **Mute/Solo über CC 103**: stumme Spuren senden keine Noten, ihr Zustand kommt als CC 103 – `patches/0003`,
  `patches/0004`, Spezifikation `docs/FIRMWARE-MUTE.md`
- **Name**: Vizz statt Skiff (Splash, ABOUT, Loader), Version 1.0, Paket `vizz-1.0.fwsc` mit der Kennung `FM-1_810`,
  Installer als eine HTML-Datei – `patches/0005`
- **Platz**: Damit alles in den Flash der FM-1 passt, wird ohne die Beta-Option „2 CORES" gebaut – `patches/0006`

`patches/` ist die vollständige Serie ab Skiff `v1.4` (`git format-patch v1.4..vizz`), anzuwenden mit
`git am -3 patches/*.patch` auf einem Branch ab dem Tag `v1.4`. Was sich ändert und was getestet ist:
[CHANGES.md](CHANGES.md).

Bauen: `./build-vizz.sh` (Linux x86-64 oder WSL; braucht github.com, gitee.com, pkgman.jieliapp.com und dessen
Download-Host jl-update.oss-cn-shenzhen.aliyuncs.com) klont Skiff,
wendet die Patches an, holt Toolchain und SDK, baut das Release, lässt alle Tests laufen und legt `out/vizz-1.0.fwsc`,
`out/vizz-installer.html` und `out/SHA256SUMS` (mit den Lizenztexten) ab. Der Auftrag dazu: [BRIEF.md](BRIEF.md).
Die fertigen Pakete liegen auf dem Branch `vizz-1.0` unter `out/`.
