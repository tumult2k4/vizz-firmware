# Auftrag: die Vizz-Firmware für die M-VAVE FM-1 bauen

Vizz ist ein persönlicher Fork der Skiff-Firmware (<https://github.com/illuminus5/skiff>, GPL-3.0) für die M-VAVE
FM-1, gebaut für den Browser-Visualizer VIZZ. Dieses Repo enthält nur die Zutaten; gebaut wird gegen einen Klon von
Skiff.

## 1. Basis

```
git clone https://github.com/illuminus5/skiff.git skiff
cd skiff
git checkout -b vizz v1.4            # Basis ist Skiff v1.4, NICHT main (main ist schon v2.0.x)
git am -3 ../patches/0001-*.patch ../patches/0002-*.patch
```

Die beiden Patches (SEQ MIDI OUT: Noten, CC 102 = Step-Index, MIDI Clock, Start/Stop über USB-MIDI, und die
angepassten Tests) wurden auf v1.4 gebaut und getestet. Falls `git am` hakt: dreifach mergen und den Sinn erhalten.

## 2. Mute- und Solo-Status über SEQ MIDI OUT

Vollständige Spezifikation: [docs/FIRMWARE-MUTE.md](docs/FIRMWARE-MUTE.md). Kurz:

- Ist eine Spur **effektiv stumm** (ihr MUTE gesetzt, **oder** eine andere Spur ist SOLO und sie nicht), sendet SEQ
  MIDI OUT für sie **keine Note-Ons**; Note-Offs weiter. Beim Stummwerden mit klingenden Noten zuerst **CC 123** auf
  ihrem Kanal. **CC 102 läuft weiter.**
- **CC 103** auf dem Kanal der Spur (`trk_midi_ch`) meldet den effektiven Zustand: **127 = stumm, 0 = hörbar**.
  Gesendet: bei jeder Änderung (Mute, Solo, Pattern-/Songwechsel, Laden …), für alle sechs Spuren nach Start (nach
  `FA`), einmal pro Takt während der Wiedergabe, und beim Einschalten von SEQ MIDI OUT. Nichts davon bei SEQ MIDI OUT OFF.
- Änderungen pro Audio-Block per Vergleich mit dem zuletzt gesendeten Zustand erkennen (deckt jede Quelle ab).
- Skiff hat Solo: im Code nachsehen, wie MUTE (`p[P_MUTE]`) und SOLO gespeichert und ausgewertet werden, und genau
  diese Auswertung für den effektiven Zustand benutzen (dieselbe, die auch den Klang stummschaltet).
- `tests/seqmidi_test.c` um die Fälle 1–8 der Spezifikation erweitern (inkl. Solo).

Der Visualizer wertet das schon aus (CC 103 ≥ 64 = stumm; seine Noten werden dann ignoriert, die Figuren der Spur
dimmen ab).

## 3. Umbenennen: Skiff → Vizz

Nur, was man **sieht**, und die Dateinamen der Ergebnisse – kein Umbenennen von Code-Bezeichnern, Kommentaren
oder Dateien im Quellbaum (kleiner Diff, spätere Skiff-Updates bleiben übertragbar):

- Name auf dem Gerät: Startbildschirm/Splash, ABOUT und jede andere Stelle, an der die Firmware „SKIFF"/„Skiff"
  anzeigt → **VIZZ** / **Vizz**.
- Version **Vizz 1.0**. ABOUT nennt die Herkunft, z. B. „VIZZ 1.0 · based on Skiff 1.4 / Felucca".
- **USB-Gerätenamen und -Deskriptoren nicht ändern** (die FM-1 muss sich weiter als FM-1 melden: der Visualizer
  erkennt MIDI- und Audio-Eingang am Namen, und der Original-Updater soll das Gerät weiter finden).
- Paket: `vizz-1.0.fwsc`. Die Paketkennung muss das Präfix `FM-1_` behalten. Eigener Nummernraum (z. B. `FM-1_810`)
  nur, wenn Loader/Updater/Tests das zulassen – sonst Skiffs Schema beibehalten. Kurz begründen, was gewählt wurde.
- Browser-Installer: eine einzelne, selbständige HTML-Datei wie Skiffs Installer (`web/make_site.py`), Titel und
  Texte „Vizz", mit eingebettetem `vizz-1.0.fwsc` → `vizz-installer.html`.
- Lizenz und Urheberhinweise (GPL-3.0, Skiff, Felucca, SDK-Lizenzen) bleiben vollständig erhalten; README bzw.
  ABOUT sagen, dass Vizz eine geänderte Fassung von Skiff ist.
- Tests, die Namen oder Bildschirme prüfen, entsprechend anpassen.

## 4. Bauen und testen

Nach `BUILDING.md` von Skiff (Linux x86-64, ohne Docker):

```
tools/get_toolchain.sh                                  # JieLi-Toolchain nach ~/.jieli
git clone --depth 1 --branch AC79NN_SDK_V1.2.1_2023-12-13 https://gitee.com/Jieli-Tech/fw-AC79_AIoT_SDK.git ~/fw-AC79_AIoT_SDK
pip install Pillow fonttools
python3 tools/fetch_cc0.py                              # die CC0-Samples, damit SAMPLE/SLICE nicht "NO SAMPLE" zeigen
./build.sh --release …                                  # als Release bauen wie Skiffs offizielle Pakete
tests/run_tests.sh                                      # alles grün, auch die neuen Fälle
```

Plausibilität: das bisherige `skiff-1.4-seqmidi.fwsc` war 610 337 Bytes; das neue Paket sollte in der Größe ähnlich
sein (mit Samples).

## 5. Ergebnis

Auf einen Branch `vizz-1.0` in **diesem** Repo (tumult2k4/vizz-firmware) committen und pushen:

- `out/vizz-1.0.fwsc`, `out/vizz-installer.html`, `out/SHA256SUMS`
- `patches/` ergänzt um die neuen Commits (`git format-patch v1.4..vizz`, alle Patches ab v1.4, durchnummeriert)
- `CHANGES.md`: was Vizz 1.0 gegenüber Skiff 1.4 ändert (SEQ MIDI OUT, Mute/Solo über CC 103, Name), die gewählte
  Paketkennung, und die Testergebnisse (Anzahl bestanden)

Fertig ist es, wenn Build und alle Tests grün sind und der Branch gepusht ist.
