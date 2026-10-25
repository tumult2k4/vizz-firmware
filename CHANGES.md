# Vizz 1.0 – Änderungen gegenüber Skiff 1.4

Vizz 1.0 ist eine geänderte Fassung von Skiff 1.4 (illuminus5, <https://github.com/illuminus5/skiff>, GPL-3.0; Skiff
baut auf Felucca von Leo Kuroshita / Hügelton Instruments auf). Basis ist der Tag `v1.4` (`c01fa1e`). Die Änderungen
sind die fünf Commits in `patches/` (`git format-patch v1.4..vizz`); `git am -3 patches/*.patch` auf einem Branch ab
`v1.4` ergibt genau den geprüften Baum (nachgeprüft: identisch).

| Patch | Inhalt |
| --- | --- |
| 0001 | SEQ MIDI OUT: Noten, CC 102 = Step-Index, MIDI Clock, Start/Stop über USB-MIDI; MENU > MIDI > SEQ MIDI OUT |
| 0002 | Tests: MIDI-Tab mit elf Zeilen, FX-Tasten-Test zählt nur die MIDI-Nachrichten der Taste |
| 0003 | Mute und Solo über SEQ MIDI OUT (CC 103), stumme Spuren ohne Note-On; `tests/seqmidi_test.c` Fälle 1–8 |
| 0004 | Tests: drei bestehende Tests zählen die neuen CC-103-Meldungen nicht mehr mit |
| 0005 | Name Vizz auf dem Gerät, Version 1.0, Kennung `FM-1_8XY`, Paket `vizz-X.Y.fwsc`, Installer als eine Datei |

0001 und 0002 sind inhaltlich unverändert (nur neu nummeriert und mit neuer Commit-ID erzeugt).

## Stand: Quellen und Host-Tests fertig, das Paket ist NOCH NICHT gebaut

Die Cloud-Umgebung dieser Session durfte zwei Hosts nicht erreichen (Netzwerk-Policy, HTTP 403 auf CONNECT):

- `pkgman.jieliapp.com` – die JieLi-Toolchain (`tools/get_toolchain.sh`, Clang für pi32v2)
- `gitee.com` – das JieLi-AC79-SDK (`AC79NN_SDK_V1.2.1_2023-12-13`; das Paket enthält daraus `uboot.boot`,
  `cfg_tool.bin`, `cfg/eq_cfg_hw.bin`)

Ohne beide gibt es kein `.fwsc`. Deshalb fehlen noch `out/vizz-1.0.fwsc`, `out/vizz-installer.html` und
`out/SHA256SUMS`, und die Teile von `tests/run_tests.sh`, die das gebaute Paket brauchen, liefen nicht (Liste unten).
Der Branch `vizz-1.0` wurde deshalb nicht angelegt. Nachholen: `./build-vizz.sh` auf einem Rechner (oder in einer
Umgebung), der die beiden Hosts erreicht – das Skript macht Klon, Patches, Toolchain, SDK, Release, alle Tests,
Installer und `out/` in einem Lauf.

## 1. SEQ MIDI OUT (0001, 0002)

Wie bisher als `skiff-1.4-seqmidi.fwsc` installiert: jede Spur spielt auf ihrem Kanal (T1..T6 CHANNEL) mit, CC 102 =
Step-Index beim Betreten eines Steps, mit INT-Clock MIDI Clock (24 ppq), Start und Stop; MENU > MIDI > SEQ MIDI OUT
(Standard ON).

## 2. Mute und Solo über CC 103 (0003, 0004)

Nach `docs/FIRMWARE-MUTE.md`, in `firmware/src/seq.c`:

- **Effektiv stumm** ist eine Spur, wenn ihr MUTE gesetzt ist (`p[P_MUTE]`) **oder** im GLO-Layer eine andere Spur
  SOLO ist (`perf_solo`, GLO + weiße Taste F3..D4 gehalten) und sie nicht. Das ist genau die Auswertung, die den
  Klang stummschaltet: `trk_note_on` spielt bei MUTE nichts, `perform.c perf_begin` dämpft bei Solo die anderen
  Spuren – außer solange `perf_kill` die Layer-Effekte abschaltet (Menü, Dialog); dann zählt Solo auch hier nicht.
  Dieselbe Formel benutzt die UI für ihre LEDs (`ui_layer.c glo_sounding`).
- Eine stumme Spur sendet **keine Note-Ons**; **Note-Offs** und **CC 102** laufen weiter. Wird eine Spur stumm,
  während von ihr gesendete Noten klingen, kommt zuerst **CC 123** auf ihrem Kanal, dann CC 103 = 127. Wird sie wieder
  hörbar, kommt CC 103 = 0 vor ihrem nächsten Note-On (auch wenn ein Launch das MUTE mitten im Block umstellt).
- **CC 103** auf dem Kanal der Spur (`trk_midi_ch`): **127 = stumm, 0 = hörbar**. Gesendet
  - bei jeder Änderung: einmal pro Audio-Block wird der Zustand jeder Spur mit dem zuletzt gesendeten verglichen
    (deckt jede Quelle ab: Tasten, Solo, Launches, Laden, Undo, Editor …), auch im Stopp; ebenso, wenn sich der
    Kanal einer Spur ändert,
  - für alle sechs Spuren beim Start (direkt nach `FA`; mit externer Clock beim Start ohne `FA`),
  - für alle sechs einmal pro Takt während der Wiedergabe (16 Sechzehntel, gezählt wie Skiffs BAR-Launches,
    `launch_steps`; funktioniert auch mit externer Clock),
  - für alle sechs, wenn SEQ MIDI OUT eingeschaltet wird, und wenn USB verbunden wird (`usb.config`).
  - Bei SEQ MIDI OUT OFF nichts davon.
- Nicht als „stumm" gezählt: die schwarzen Tasten im **FX-Layer** (Gate-Mute, nur solange gehalten). Das ist ein
  Performance-Effekt (in Skiff als GATE gezeichnet), weder MUTE noch SOLO.
- Last: 6 Vergleiche pro Block, 6 Controller pro Takt plus Änderungen.
- `tests/seqmidi_test.c`, Fälle der Spezifikation: (1) T2 stumm per GLO + schwarze Taste, während ihre Note klingt:
  CC 123 vor genau einem CC 103 = 127, danach keine Note-Ons, Note-Offs und CC 102 weiter; (2) wieder hörbar: CC 103 =
  0 vor dem nächsten Note-On; (3) direkt nach `FA` sechs CC 103 mit dem Zustand je Spur auf ihrem Kanal; (4) sechs CC
  103 pro Takt über zwei Takte; (5) SEQ MIDI OUT OFF: kein CC 103 (Mute, Solo, Start, Taktgrenze), beim
  Wiedereinschalten sofort sechs; (6) T2 CHANNEL 10: CC 103 auf Kanal 10; (7) Solo T1 per GLO + F3: sofort 127 für
  T2 T3 T5 T6 (T4 war schon stumm), nur T1-Noten, nach einem Takt T1 = 0 und T2..T6 = 127; losgelassen: 0 für alle
  nicht stummen, ihre Noten kommen wieder; (8) eine stumme Spur sendet weiter 16 CC 102 pro Takt. Dazu: eine
  Änderung im Stopp wird sofort gemeldet. Gegenprobe: jede von sechs absichtlichen Verfälschungen der Umsetzung
  (Block-Vergleich, Note-On-Sperre, CC 123, Solo, Takt-Wiederholung, Start-Meldung) lässt Tests fehlschlagen.
- 0004: `ui_test` (Taste vor FX) und `perform_test` (Tasten im FX-Layer) zählten jede MIDI-Nachricht; die
  CC-103-Meldungen beim USB-Verbinden bzw. Wiedereinschalten gehen dort jetzt vor dem Zählen hinaus. `smk_ui_test`
  (SMK-Build, nicht für Vizz) prüft „keine Clock auf TRS bei externer Clock" jetzt an den Clock-Bytes, weil beim SMK
  SEQ MIDI OUT auch auf die TRS-Buchse geht.

## 3. Name Vizz (0005)

Nur Sichtbares und die Dateinamen der Ergebnisse; Code-Bezeichner, Kommentare und Dateien behalten Skiffs Namen.

- Startbildschirm: „Vizz / v1.0 / on Skiff 1.4 / Hügelton + community" (statt „Skiff / v1.4 / on Felucca 1.1.5").
- ABOUT: „VIZZ", „based on Skiff 1.4 / Felucca", „v1.0"; die Credits beginnen mit VIZZ („A modified version of
  Skiff 1.4 for the VIZZ visualizer …") und SKIFF (illuminus5, GPL-3.0, Link); alle bisherigen Credits und Lizenzen
  (Felucca, Hügelton, CrispyZebra, Fukiai, Klattsch, DaisySP, Dexed/msfa, JIANT FM, Rings, clk320-probe, Fonts,
  Samples, SDK) bleiben, ebenso „Skiff: illuminus5" und der QR-Code zu Skiffs Quellen.
- Absturzbild „VIZZ CRASH"; Update-Loader „WAITING FOR THE VIZZ INSTALLER" / „THE VIZZ INSTALLER" (seine
  5×7-Schrift bekam V und Z).
- MENU > THEME zeigt das Standard-Theme als „VIZZ". Die Theme-Liste, die der Web-Editor über das Protokoll liest
  (`ED_UI_PALETTES`), behält „SKIFF", weil Skiffs Editor daran sein Aussehen wählt.
- Die große Schrift L bekam das „Z" (für „VIZZ" im ABOUT), in beiden Schriftvarianten.
- Version `v1.0` (`FELUCCA_VERSION`; der Editor bekommt „FELUCCA v1.0", er nutzt den Text nur zur Anzeige).
- **USB-Gerätenamen und -Deskriptoren unverändert** (`usb.c` nicht angefasst): das Gerät meldet sich weiter als
  FM-1, der Loader weiter als „Felucca Update".
- Angepasste Tests: die Zeilen des Startbildschirms (`ui_render`), die Texte der L-Schrift (`ui_test`), die Namen
  von MENU > THEME (`editor_test`, `web/test_web.mjs`: VIZZ statt SKIFF) und die Kennung des Entwicklungs-Pakets
  (`web/test_web.mjs`: `FM-1_8xx`).
- `README.md` (Hinweis ganz oben) und `BUILDING.md` sagen, dass Vizz eine geänderte Fassung von Skiff 1.4 ist und wie
  Release und Installer entstehen. `LICENSE`, `LICENSING.md`, `LICENSES/` und alle Urheberhinweise unverändert.
- `web/make_vizz_installer.py`: macht aus Skiffs Installer-Seite (`web/index_pkg.html` mit `fm1pkg.js`,
  `fm1ota.js`, `fm1backup.js`, wie `web/make_site.py`) **eine** HTML-Datei, das Paket als data:-URL eingebettet; Titel
  und Texte „Vizz", nur FM-1; Hinweis, dass Vizz eine geänderte Fassung von Skiff ist und nicht an Skiff gemeldet
  werden soll; Credits wie bei Skiff; Lizenz-Links auf `LICENSE`, `LICENSING.md`, `LICENSES/` neben der Datei (das
  Build-Skript legt sie mit nach `out/`); Editor- und Learn-Link auf Skiffs Online-Seiten. Probelauf mit einem
  synthetischen Testpaket in Chromium: Seite lädt ohne Fehler, zeigt „Vizz 1.0", das eingebettete Paket wird gelesen.
  Hinweis: Web MIDI braucht einen sicheren Kontext – falls Chrome für die direkt geöffnete Datei kein MIDI anbietet,
  den Ordner mit `python3 -m http.server` ausliefern und über `localhost` öffnen.

## Paketkennung: `FM-1_810`

Gewählt: eigener Nummernraum `FM-1_8XY` – Vizz 1.0 = **`FM-1_810`**, Entwicklungs-Builds `FM-1_800` (Skiff ist
`FM-1_7XY`, Felucca `FM-1_9XY`). Begründung: Keiner der Leser der Kennung wertet mehr aus als das Modell vor dem
`_`:

- App (`ota.c`, M-UPGRADE-Einstieg) und Update-Loader melden die Kennung nur, vergleichen sie nicht;
- der Web-Updater (`web/fm1ota.js`) prüft das Modell (`FM-1`) und nach der Installation, dass das Gerät genau die
  Kennung des Pakets meldet; die Versionsnummer zählt nur bei SMK-Geräten unter V016;
- `tools/fm1_install.py` verlangt `Modell_Ziffern`;
- Tests: nur `web/test_web.mjs` prüfte `FM-1_7\d\d` für das Entwicklungs-Paket (angepasst auf `FM-1_8\d\d`);
  `web/make_site.py` (Skiffs Pages-Site) verlangt `7xx` – Vizz benutzt stattdessen `make_vizz_installer.py`, das
  `FM-1_8xx` verlangt.

Skiffs Schema hätte für Vizz 1.0 `FM-1_710` ergeben – die Kennung von Skiff 1.0. Präfix `FM-1_` bleibt, damit
M-VAVEs Updater das Gerät weiter als FM-1 behandelt (wie bei Skiffs `7XY`).

## Testergebnis

Host-Tests (`tests/run_tests.sh`) auf dem Endstand, ohne die Teile, die das gebaute Paket brauchen:

(Der vollständige Lauf auf dem Endstand läuft noch; das Ergebnis wird hier eingetragen. Vorab grün: `seqmidi_test` mit allen neuen Fällen, `ui_test`, `ui_render` (0 Lint-Befunde), `perform_test`, `smk_ui_test`, `ldr_screen_test`.)

Nicht gelaufen, weil sie `build/felucca.fwsc`, `felucca.bin`, `loader/ota.bin` oder `felucca.dis` aus dem
Toolchain-Build brauchen: M-UPGRADE-Einstieg (`ota_test`, auch SMK-Varianten und ASan), Update-Loader
(`ldr_test`, auch SMK und ASan), SMK-Paket-Layout (`smk_pkg_test.py`), Ziel-Kosten der Render-Schleifen
(`target_budget.py`), der Paket-Vergleich JS = Python in `web/test_web.mjs` (dort als „skipped" vermerkt), sowie die
statischen Prüfungen des Builds selbst (`tools/build.py`: Größen, RAM-Code, HAL-Zugriffe). Nicht installiert waren
Emscripten (Browser-Emulator, optional) und DaisySP (PHYS-Vergleich, optional) – wie in Skiffs eigener Anleitung
übersprungen.

## Hinweise

- `tools/fetch_cc0.py` wurde nicht ausgeführt: die drei Sets, die der Build benutzt (PIANO, FLUTE, SAX), liegen in
  Skiffs Baum (`assets/samples-cc0/`), und das Skript würde `ATTRIBUTION.txt` mit neuem Datum überschreiben. SAMPLE
  und SLICE haben damit ihre Samples (kein „NO SAMPLE"). `build-vizz.sh` ruft es nur auf, wenn sie fehlen.
- Die Paketgröße kann erst nach dem Build mit `skiff-1.4-seqmidi.fwsc` (610 337 Bytes) verglichen werden; erwartet
  wird fast dieselbe Größe (ein Glyph mehr in L und im Loader, etwas mehr Code in `seq.c`).
- Skiffs SMK-37-Build ist nicht Ziel von Vizz; seine Kennung und sein Paketname sind unverändert (`skiff-smk37`).
