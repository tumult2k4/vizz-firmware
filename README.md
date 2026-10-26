# vizz-firmware

Zutaten für **Vizz**, einen persönlichen Fork der Skiff-Firmware (<https://github.com/illuminus5/skiff>, GPL-3.0)
für die M-VAVE FM-1, abgestimmt auf den Browser-Visualizer VIZZ:

- **SEQ MIDI OUT**: der Sequencer spielt über USB-MIDI mit (Noten je Spur auf ihrem Kanal, CC 102 = Step-Index,
  MIDI Clock, Start/Stop) – `patches/0001`, `patches/0002`
- **Mute/Solo über CC 103**: stumme Spuren senden keine Noten, ihr Zustand kommt als CC 103 – `docs/FIRMWARE-MUTE.md`
- **Name**: Vizz statt Skiff

| Version | Basis | Auftrag | Ergebnis |
| --- | --- | --- | --- |
| Vizz 1.0 | Skiff 1.4 | [BRIEF.md](BRIEF.md) | Branch `vizz-1.0`, `out/vizz-1.0.fwsc` |
| Vizz 2.0 | Skiff 2.0.1 | [BRIEF-2.0.md](BRIEF-2.0.md) | Branch `vizz-2.0`, `out/vizz-2.0.fwsc` |
