# Auftrag: Vizz 2.0 – alle MIDI-OUT-Funktionen von Vizz 1.0 auf Skiff 2.0 bringen

Vizz 1.0 (Branch `vizz-1.0` dieses Repos, `CHANGES.md` dort) ist Skiff 1.4 plus SEQ MIDI OUT, Mute/Solo über CC 103
und der Name Vizz. Der Nutzer hat es installiert und es läuft. Jetzt soll dasselbe auf **Skiff 2.0** aufsetzen:
**Vizz 2.0**.

## 1. Basis

```
git clone https://github.com/illuminus5/skiff.git skiff
cd skiff
git checkout -b vizz-2.0 v2.0.1        # die neueste 2.0 (2.0 + Fixes; Kennung bei Skiff FM-1_720)
```

Die sechs Patches von `vizz-1.0` (`patches/0001`–`0006`) sind die Vorlage. Skiff 2.0 hat einen **neuen Sequencer**
(NOTES/FEEL, Noten mit eigener Länge, die sich überlappen, Ties, Ketten/CHAIN auf SONG, SONG ONCE, Sounds auf
Song-Einträgen) und **ein gemeinsames MUTE** in GLO, FX und PERFORM (Tippen = an/aus, Halten = nur solange gehalten).
Die Patches werden daher nicht einfach angewendet, sondern **portiert**: gleiches Verhalten nach außen, an den neuen
Stellen im Code. Wo 2.0 etwas schon selbst kann, das nutzen statt doppeln.

## 2. Was Vizz 2.0 über USB-MIDI senden muss

Alles wie in Vizz 1.0 (Details: `CHANGES.md` auf `vizz-1.0`, `docs/FIRMWARE-MUTE.md`):

- **SEQ MIDI OUT** (MENU › MIDI › SEQ MIDI OUT, Standard ON): jede Spur spielt auf ihrem Kanal (T1..T6 CHANNEL) mit –
  Noten und Drum-Treffer (GM-Noten der Lanes, auch bei den neuen eigenen Kits USR1–3) mit Velocity (Akzent 127),
  Ratchets, Flams und Slides wie gespielt; **CC 102** = Step-Index beim Betreten eines Steps; mit INT-Clock **MIDI
  Clock** (24 ppq), **Start**, **Stop**; **CC 123** bei einer Panik.
- **CC 103 = Mute-Status** (127 stumm, 0 hörbar) auf dem Spurkanal: bei jeder Änderung (Vergleich pro Audio-Block),
  für alle sechs nach Start, einmal pro Takt beim Spielen, beim Einschalten von SEQ MIDI OUT und beim USB-Verbinden;
  stumme Spuren senden keine Note-Ons (Note-Offs und CC 102 weiter), beim Stummwerden mit klingenden Noten zuerst
  CC 123. Nichts davon bei SEQ MIDI OUT OFF.

Neu durch Skiff 2.0, festgelegt:

- **Effektiv stumm** ist, was den Klang der Spur stummschaltet – genau dieselbe Auswertung wie die Audio-Seite: das
  gemeinsame MUTE (getippt), **auch das gehaltene MUTE** (nur solange gehalten – in 2.0 ist das kein FX-Effekt mehr,
  sondern das MUTE selbst) und **SOLO**, falls 2.0 es noch hat (sonst entfällt es; im Code prüfen und in `CHANGES.md`
  sagen).
- **Noten mit eigener Länge / Überlappung**: jede Note bekommt ihr Note-Off zu ihrem eigenen Ende. Klingt auf einem
  Kanal dieselbe Tonhöhe noch, wenn sie neu anschlägt, zuerst ihr Note-Off, dann das Note-On (MIDI kennt keine
  zwei gleichen Noten auf einem Kanal). Ein **Tie** ist eine durchgehende Note (kein neues Note-On).
- **Ketten (CHAIN)**: CC 102 ist der Step-Index **im gerade spielenden Teil** (0..63, beginnt in jedem Teil bei 0),
  damit der Visualizer jeden Teil als eigenen Loop mit seiner LENGTH sieht. Eine Note, die von einem Teil in den
  nächsten weiterklingt, bleibt eine Note.
- **SONG ONCE**: hält der Sequencer am Ende an, kommen die Note-Offs und **Stop** wie bei einem normalen Stopp.

## 3. Name Vizz 2.0

Wie in Vizz 1.0 (Patch 0005), angepasst an 2.0:

- Startbildschirm, ABOUT, Absturzbild, Update-Loader, MENU › THEME: **Vizz** statt Skiff; Version **v2.0**; ABOUT
  „based on Skiff 2.0.1 / Felucca"; Credits beginnen mit VIZZ, alle Credits und Lizenzen von Skiff 2.0.1 bleiben.
- **USB-Namen und -Deskriptoren unverändert.**
- Kennung **`FM-1_820`** (Vizz-Schema `FM-1_8XY`, Begründung in `CHANGES.md` von 1.0), Entwicklungs-Builds `FM-1_800`.
- Paket `vizz-2.0.fwsc`, Installer `vizz-installer.html` als **eine** Datei mit eingebettetem Paket.
- Code-Bezeichner, Kommentare und Dateinamen im Quellbaum bleiben Skiffs.

## 4. Update von Vizz 1.0 auf Vizz 2.0 – wichtig

Skiff 2.0 speichert in **neuen Formaten**. Skiffs 2.0-Installer sichert vor dem Installieren alles
(`…-backup-DATUM.json`) und konvertiert danach, was 2.0 so nicht lesen kann. Der Nutzer hat **Vizz 1.0** drauf
(Kennung `FM-1_810`, Version `v1.0`, Daten im Format von Skiff 1.4):

- Der Vizz-Installer muss **Skiffs komplette 2.0-Installer-Logik** übernehmen (Backup vorher, Konvertierung nachher,
  Liste des Konvertierten, Rückweg zur Original-Firmware V15) – `web/make_vizz_installer.py` entsprechend auf die
  2.0-Seite und ihre Skripte umstellen.
- Er muss ein Gerät mit **`FM-1_8XY` / Vizz 1.x wie Skiff 1.4** behandeln (also sichern und konvertieren). Prüfen, wie
  Skiffs Installer und die Firmware die Herkunft erkennen (Kennung, Version, Formatkennungen) und Vizz 1.0 dort
  ausdrücklich abdecken; mit einem Test belegen (simuliertes Gerät mit Vizz-1.0-Kennung und 1.4-Daten → Backup +
  Konvertierung).
- In `CHANGES.md` eine kurze **Update-Anleitung** von Vizz 1.0: Backup-Datei aufheben, wie man zurück auf Vizz 1.0
  kommt.

## 5. Bauen und testen

Wie bei Vizz 1.0 (`build-vizz.sh` auf `vizz-1.0` anpassen): JieLi-Toolchain, AC79-SDK, `./build.sh --release 2.0`,
`tests/run_tests.sh` komplett grün.

- **Zweiter Kern:** Skiff 2.0 ist rund 30 KB kleiner als 1.4. Vizz 2.0 deshalb **mit** Skiffs Standard-Konfiguration
  bauen (zweiter Kern wie bei Skiff 2.0.1). Nur wenn es nicht passt: mit Zahlen begründen und wie in 1.0 vorgehen.
  Die freien Bytes im App-Bereich in `CHANGES.md` angeben.
- `tests/seqmidi_test.c` auf 2.0 portieren, alle Fälle von Vizz 1.0 (Noten, Kanäle, CC 102, Clock, Start/Stop,
  CC 103 Fälle 1–8) **plus**: Noten mit eigener Länge enden einzeln; überlappende gleiche Tonhöhe → Note-Off vor
  Note-On; Tie = eine Note; CHAIN: CC 102 beginnt in jedem Teil bei 0; gehaltenes MUTE → CC 103 = 127 solange
  gehalten, danach 0; SONG ONCE am Ende → Note-Offs und Stop.
- Gegenprobe wie in 1.0: absichtliche Verfälschungen lassen Tests fehlschlagen.
- Klang: die Regressions-Renders müssen Skiff 2.0.1 bit für bit entsprechen.

## 6. Ergebnis

Auf Branch **`vizz-2.0`** in diesem Repo committen und pushen:

- `out/vizz-2.0.fwsc`, `out/vizz-installer.html`, `out/SHA256SUMS`, Lizenzen und Attributionen wie bei 1.0
- `patches/` = alle Commits ab `v2.0.1` (`git format-patch v2.0.1..vizz-2.0`), durchnummeriert
- `build-vizz.sh` für 2.0
- `CHANGES.md`: was Vizz 2.0 gegenüber Skiff 2.0.1 ändert, die Festlegungen aus Abschnitt 2, Kennung, freier Platz,
  Testergebnis, Update-Anleitung von Vizz 1.0

Fertig ist es, wenn Build und alle Tests grün sind und `vizz-2.0` gepusht ist. Falls etwas nicht geht, genau sagen,
was fehlt, statt abzukürzen.
