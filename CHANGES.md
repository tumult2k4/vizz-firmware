# Vizz 1.0 – Änderungen gegenüber Skiff 1.4

Vizz 1.0 ist eine geänderte Fassung von Skiff 1.4 (illuminus5, <https://github.com/illuminus5/skiff>, GPL-3.0; Skiff
baut auf Felucca von Leo Kuroshita / Hügelton Instruments auf). Basis ist der Tag `v1.4` (`c01fa1e`). Die Änderungen
sind die sechs Commits in `patches/` (`git format-patch v1.4..vizz`); `git am -3 patches/*.patch` auf einem Branch ab
`v1.4` ergibt genau den gebauten und getesteten Baum.

| Patch | Inhalt |
| --- | --- |
| 0001 | SEQ MIDI OUT: Noten, CC 102 = Step-Index, MIDI Clock, Start/Stop über USB-MIDI; MENU > MIDI > SEQ MIDI OUT |
| 0002 | Tests: MIDI-Tab mit elf Zeilen, FX-Tasten-Test zählt nur die MIDI-Nachrichten der Taste |
| 0003 | Mute und Solo über SEQ MIDI OUT (CC 103), stumme Spuren ohne Note-On; `tests/seqmidi_test.c` Fälle 1–8 |
| 0004 | Tests: drei bestehende Tests zählen die neuen CC-103-Meldungen nicht mehr mit |
| 0005 | Name Vizz auf dem Gerät, Version 1.0, Kennung `FM-1_8XY`, Paket `vizz-X.Y.fwsc`, Installer als eine Datei |
| 0006 | Platz im Flash: verlustfreie Einsparungen, FM-1-Build ohne zweiten Kern (`FELUCCA_CPU2=0`) |

0001 und 0002 sind inhaltlich unverändert (nur neu nummeriert und mit neuer Commit-ID erzeugt).

## Ergebnis (`out/`)

| Datei | |
| --- | --- |
| `vizz-1.0.fwsc` | 610 350 Bytes, Kennung `FM-1_810`, Version `v1.0`; App 579 380 Bytes (2 184 Bytes frei im App-Bereich) |
| `vizz-installer.html` | Browser-Installer als eine Datei, das Paket eingebettet (bitgenau `vizz-1.0.fwsc`) |
| `SHA256SUMS` | Prüfsummen der beiden |
| `LICENSE`, `LICENSING.md`, `LICENSES/`, `ATTRIBUTION*.txt` | wie in Skiffs Release-Ordner; der Installer verlinkt sie |

Gebaut mit `./build-vizz.sh` nach Skiffs `BUILDING.md`: JieLi-Toolchain `jieli-linux-toolchains-20260730.1`
(clang 4.0.1, `tools/get_toolchain.sh`), AC79-SDK `AC79NN_SDK_V1.2.1_2023-12-13` von gitee (die drei Dateien, die ins
Paket gehen, stimmen mit Skiffs SHA-256 in `tools/build.py` überein), `./build.sh --release 1.0`; alle Prüfungen von
`build.py` „ok" (RAM-Code ohne Aufrufe ins XIP, Registerzugriffe nur in `hal/`, RAM 79 936 von 98 304 Bytes, Pool mit
10 020 Bytes Reserve). Die Paketgröße ist bei Skiff fest (aufgefülltes Flash-Image): reines Skiff 1.4 ergibt 610 337
Bytes; Vizz hat 13 Bytes mehr, das sind die Buchstaben V und Z in der Schrift des Update-Loaders.

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
- Last: 6 Vergleiche pro Block, 6 Controller pro Takt plus Änderungen. Kostenmaß der Render-Schleifen im
  Audio-Interrupt: +1,1 % gegenüber reinem Skiff 1.4 in derselben Konfiguration.
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
- ABOUT: „VIZZ", „based on Skiff 1.4 / Felucca", „v1.0"; die Credits beginnen mit VIZZ („Skiff 1.4 by illuminus5,
  modified: SEQ MIDI OUT for VIZZ / GPL-3.0"); alle bisherigen Credits und Lizenzen (Felucca, Hügelton, CrispyZebra,
  Fukiai, Klattsch, DaisySP, Dexed/msfa, JIANT FM, Rings, clk320-probe, Fonts, Samples, SDK) bleiben, ebenso
  „Skiff: illuminus5", der Link und der QR-Code zu Skiffs Quellen.
- Absturzbild „VIZZ CRASH"; Update-Loader „WAITING FOR THE VIZZ INSTALLER" / „THE VIZZ INSTALLER" (seine
  5×7-Schrift bekam V und Z).
- MENU > THEME zeigt das Standard-Theme als „VIZZ". Die Theme-Liste, die der Web-Editor über das Protokoll liest
  (`ED_UI_PALETTES`), behält „SKIFF", weil Skiffs Editor daran sein Aussehen wählt.
- Version `v1.0` (`FELUCCA_VERSION`; der Editor bekommt „FELUCCA v1.0", er nutzt den Text nur zur Anzeige).
- **USB-Gerätenamen und -Deskriptoren unverändert** (`usb.c` nicht angefasst): das Gerät meldet sich weiter als
  FM-1, der Loader weiter als „Felucca Update".
- `README.md` (Hinweis ganz oben) und `BUILDING.md` sagen, dass Vizz eine geänderte Fassung von Skiff 1.4 ist und wie
  Release und Installer entstehen. `LICENSE`, `LICENSING.md`, `LICENSES/` und alle Urheberhinweise unverändert.
- `web/make_vizz_installer.py`: macht aus Skiffs Installer-Seite (`web/index_pkg.html` mit `fm1pkg.js`,
  `fm1ota.js`, `fm1backup.js`, wie `web/make_site.py`) **eine** HTML-Datei, das Paket als data:-URL eingebettet; Titel
  und Texte „Vizz", nur FM-1; Hinweis, dass Vizz eine geänderte Fassung von Skiff ist und nicht an Skiff gemeldet
  werden soll; Credits wie bei Skiff; Lizenz-Links auf `LICENSE`, `LICENSING.md`, `LICENSES/` neben der Datei;
  Editor- und Learn-Link auf Skiffs Online-Seiten. Geprüft in Chromium: lädt ohne Fehler, zeigt „Vizz 1.0", das
  eingebettete Paket ist bitgenau `vizz-1.0.fwsc`. Web MIDI braucht einen sicheren Kontext: falls Chrome für die
  direkt geöffnete Datei kein MIDI anbietet, den Ordner mit `python3 -m http.server` ausliefern und über `localhost`
  öffnen.
- Angepasste Tests: die Zeilen des Startbildschirms (`ui_render`), die Namen von MENU > THEME (`editor_test`,
  `web/test_web.mjs`: VIZZ statt SKIFF) und die Kennung des Entwicklungs-Pakets (`web/test_web.mjs`: `FM-1_8xx`).

## 4. Platz im Flash (0006)

Der App-Bereich des FM-1 ist 581 564 Bytes groß (XIP, `0x8DFBC`). Reines Skiff 1.4 belegt mit dieser Toolchain
581 352 davon – **212 Bytes frei**. Schon SEQ MIDI OUT allein (0001) braucht mehr: v1.4 + 0001 + 0002 läuft mit
dieser Toolchain um 504 Bytes über. Das bisher installierte `skiff-1.4-seqmidi.fwsc` muss also mit einer anderen
Toolchain oder anderen Einstellungen gebaut worden sein; das ließ sich nicht mehr nachvollziehen.

Verlustfrei eingespart:

- Die neuen globalen Variablen (`seq_clk_acc`, der CC-103-Zustand) liegen in `.pool` (beim Start genullt). Unter den
  vom Compiler zusammengefassten globalen Variablen schoben sie andere über die kurzen Adress-Offsets hinaus und
  verlängerten Code überall (`fm1_main`, `ui_input`, Zeichnen, Editor: rund 2 KB).
- „VIZZ" im ABOUT in der Schrift V, die das Z hat (L behält Skiffs Zeichensatz); kürzere VIZZ-Zeile in den Credits.
- `tools/size_fns.py`: „minsize" für die Hauptschleifen-Funktionen von `midi_learn.c`, `master.c`, `throw.c`,
  `mod.c`, `perform.c`, `launch.c`, `fx.c`, `audio.c` (alles, was ein Interrupt erreicht, bleibt `-Os`; keine
  Klangerzeuger-Datei, weil deren Render-Funktionen über `ENGINES[]` erreicht werden, was die Prüfung nicht sieht).

Danach fehlten noch 712 Bytes. Auf Stefans Entscheidung baut `build.py` den FM-1 deshalb **ohne zweiten Kern**
(`FELUCCA_CPU2=0`, Skiffs eigene, getestete Build-Option): MENU > SYSTEM > CPU „2 CORES (BETA)" entfällt, das Gerät
läuft wie im Standard („1 CORE"). Danach bleiben 2 184 Bytes frei. `FELUCCA_CPU2=1` baut den zweiten Kern wieder ein
(und passt nicht).

Tests dazu: `run_tests.sh` prüft SEQ MIDI OUT, die UI-Tests und die UI-Renders zusätzlich in der Konfiguration ohne
zweiten Kern. Die Kosten der Render-Schleifen (`target_budget.py`) werden bei einem Build ohne zweiten Kern gegen
`tests/target_budget_cpu1.txt` geprüft – erzeugt aus **reinem Skiff 1.4** ohne zweiten Kern, denn dort bettet `fx.c`
`mix_part` in `mix_block` ein und die Schleifen im Audio-Interrupt liegen tiefer (Skiffs Budget gilt für den Build
mit zweitem Kern; reines Skiff 1.4 ohne zweiten Kern überschreitet es genauso). Vizz liegt darauf +1,1 %.

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

**`ALL HOST TESTS PASSED`** – abschließender Lauf von `./build-vizz.sh` auf genau dem veröffentlichten Stand (frischer
Klon von Skiff `v1.4`, alle sechs Patches, Release- und Entwicklungs-Build, `tests/run_tests.sh` komplett **mit** den
Tests, die das gebaute Paket brauchen): 114 Test-Schritte, 6 586 Einzelprüfungen „ok", 0 Fehler. Der Neubau ergab
`vizz-1.0.fwsc` und `vizz-installer.html` bitgleich (gleiche SHA-256 wie in `SHA256SUMS`).

Darin u. a.:

- **mit dem echten Paket:** M-UPGRADE-Einstieg (auch unter ASan/UBSan), Update-Loader „andere App → dieser Build",
  SMK-Paket-Layout, `fm1pkg.js` liest das Paket wie Python, der Loader-Bildschirm;
- `seqmidi_test` mit den Fällen 1–8 (32 Prüfungen), auch in der Konfiguration ohne zweiten Kern;
- UI-Tests und UI-Renders (219 Bildschirme × 6 Paletten, 0 Lint-Befunde, Ausrichtung 0 Abweichungen), auch ohne
  zweiten Kern;
- Regression: 176 Golden-Renders unverändert, 0 Health-/Stimmen-Fehler – der Klang ist bit für bit der von Skiff 1.4;
- Kosten der Render-Schleifen (`tests/target_budget_cpu1.txt`): alle im Budget, Audio-Interrupt 34 330 bei 33 951
  für reines Skiff 1.4 (+1,1 %);
- Editor-Protokoll (Tabellen = Firmware: 0 Abweichungen), Projekte, Backup, alle Engines, ASan/UBSan und Fuzzer,
  Installer-CLI gegen ein simuliertes FM-1, Web-Tests, der zweite Kern unter ThreadSanitizer (Host-Test).

Übersprungen, wie bei Skiff ohne diese Dateien bzw. Werkzeuge: M-VAVEs Original-Pakete (V15, SMK V016), der
PHYS-Vergleich mit DaisySP, der Browser-Emulator (Emscripten) und – mangels Instruktionszähler auf diesem Host – die
Kostenmessung in `mod_test`.

## Hinweise

- `tools/fetch_cc0.py` wurde nicht ausgeführt: die drei Sets, die der Build benutzt (PIANO, FLUTE, SAX), liegen in
  Skiffs Baum (`assets/samples-cc0/`), und das Skript würde `ATTRIBUTION.txt` mit neuem Datum überschreiben. SAMPLE
  und SLICE haben damit ihre Samples (kein „NO SAMPLE"). `build-vizz.sh` ruft es nur auf, wenn sie fehlen.
- Wer „2 CORES (BETA)" eingeschaltet hatte: Die Einstellung bleibt gespeichert, Vizz läuft trotzdem auf einem Kern.
- Skiffs SMK-37-Build ist nicht Ziel von Vizz; seine Kennung und sein Paketname sind unverändert (`skiff-smk37`).
