# vizz-firmware

Zutaten für **Vizz**, einen persönlichen Fork der Skiff-Firmware (<https://github.com/illuminus5/skiff>, GPL-3.0)
für die M-VAVE FM-1, abgestimmt auf den Browser-Visualizer VIZZ. Dieser Branch: **Vizzbox 1.1** (in Arbeit, Stand in
[CHANGES.md](CHANGES.md)) auf Vizzbox 1.0 / Skiff 2.0.1; `patches/` ist die Serie ab Skiff `v2.0.1`, gebaut wird mit
`./build-vizzbox.sh`.

- **SEQ MIDI OUT**: der Sequencer spielt über USB-MIDI mit (Noten je Spur auf ihrem Kanal, CC 102 = Step-Index,
  MIDI Clock, Start/Stop) – `patches/0001`, `patches/0002`
- **Mute/Solo über CC 103**: stumme Spuren senden keine Noten, ihr Zustand kommt als CC 103 – `docs/FIRMWARE-MUTE.md`
- **Name**: Vizz statt Skiff
- **Vizzbox** (eigene Firmware auf Vizz 2.0): ein Produzent, der nach Wahl von Genre und Subgenre selbst Musik
  erzeugt und spielt – mit Aufbau, Drops und Breaks

| Version | Basis | Auftrag | Ergebnis |
| --- | --- | --- | --- |
| Vizz 1.0 | Skiff 1.4 | [BRIEF.md](BRIEF.md) | Branch `vizz-1.0`, `out/vizz-1.0.fwsc` |
| Vizz 2.0 | Skiff 2.0.1 | [BRIEF-2.0.md](BRIEF-2.0.md) | Branch `vizz-2.0`, `out/vizz-2.0.fwsc` |
| Vizzbox 1.0 | Vizz 2.0 | [BRIEF-VIZZBOX.md](BRIEF-VIZZBOX.md), Konzept [docs/VIZZBOX.md](docs/VIZZBOX.md) | Branch `vizzbox-1.0`, `out/vizzbox-1.0.fwsc` |
| Vizzbox 1.1 | Vizzbox 1.0 | [BRIEF-VIZZBOX-1.1.md](BRIEF-VIZZBOX-1.1.md): Live-Kontrolle, mehr Genres | Branch `vizzbox-1.1`, `out/vizzbox-1.1.fwsc` |
