# Vizzbox 1.0 – Änderungen gegenüber Skiff 2.0.1

> **Zwischenstand: Etappe 1 von 8** (BRIEF-VIZZBOX.md, Abschnitt 10). Vizz 2.0 ist nachgebaut und grün, der Platz im
> Flash ist gemessen. Der Produzent existiert noch nicht. Was steht, was getestet ist und was als Nächstes kommt: unten,
> „Stand“.

Vizzbox ist eine geänderte Fassung von Skiff 2.0.1 (illuminus5, <https://github.com/illuminus5/skiff>, GPL-3.0; Skiff
baut auf Felucca von Leo Kuroshita / Hügelton Instruments auf) und baut auf **Vizz 2.0** auf (Branch `vizz-2.0` dieses
Repos: Skiff `v2.0.1` + fünf Patches). Basis ist der Tag `v2.0.1` (`b03d98a`); die Änderungen sind die Commits in
`patches/` (`git format-patch v2.0.1..vizzbox-1.0`), anzuwenden mit `git am -3 patches/*.patch` auf einem Branch ab
`v2.0.1`.

| Patch | Inhalt |
| --- | --- |
| 0001–0005 | **Vizz 2.0**, unverändert von `origin/vizz-2.0` (SEQ MIDI OUT, CC 103, Name Vizz, Installer-Test, Gegenprobe) – siehe `CHANGES.md` dort |
| 0006 | `tools/size_report.py`: wohin der Flash geht, je Quelldatei und Symbol (Messwerkzeug für Abschnitt 7) |

## Stand

### Erledigt

1. **Vizz 2.0 nachgebaut.** Frischer Klon von Skiff, Branch `vizzbox-1.0` ab `v2.0.1`, die fünf Patches von
   `origin/vizz-2.0` mit `git am -3` angewendet (ohne Konflikt; die neu erzeugten Patches 0001–0005 sind bis auf die
   Commit-Kennung und die Nummerierung „/6“ bytegleich mit denen auf `vizz-2.0`).
   - Werkzeuge wie bei Vizz 2.0: JieLi-Toolchain `jieli-linux-toolchains-20260730.1` (clang 4.0.1), AC79-SDK
     `AC79NN_SDK_V1.2.1_2023-12-13`, Emscripten 6.0.13, Pillow 12.3, fontTools 4.68.
   - `./build.sh --release 2.0` ergibt `vizz-2.0.fwsc` mit **610 442 Bytes**, Kennung `FM-1_820`, App **553 052 Bytes** –
     genau die Werte von Vizz 2.0. Gegen das veröffentlichte `out/vizz-2.0.fwsc` unterscheiden sich 15 Bytes: das
     Build-Datum (ABOUT zeigt `__DATE__`) und die Prüfsummen, die es einschließen.
   - Alle Prüfungen von `build.py` „ok“: RAM `.data`+`.bss` 79 924 von 98 304 Bytes, Pool 346 500 von 356 352 Bytes,
     RAM-Code + `.ramx` 24 200 von 24 576 Bytes, Registerzugriffe nur in `hal/`.
2. **Tests von Vizz 2.0:** `tests/run_tests.sh` auf diesem Stand (Entwicklungs-Build): **`ALL HOST TESTS PASSED`**,
   126 Test-Schritte, 8 280 Einzelprüfungen „ok“, 0 Fehler – darunter `seqmidi_test` (alle Fälle von Vizz 2.0), die
   **176 Regressions-Renders mit 0 Änderungen** gegen `tests/golden.txt` von Skiff 2.0.1, die UI-Goldens (3 388 Bilder,
   0 geändert), der zweite Kern bitgleich, ASan/UBSan und Fuzzer, die Web-Tests.
   Der vollständige Lauf mit `./build-vizzbox.sh` (Emscripten 6.0.13: Browser-Emulator, Konverter als WebAssembly,
   Release `vizz-2.0.fwsc`, Ein-Datei-Installer, `tests/run_tests.sh` mit Web-, Backup- und Konverter-Tests, Neubau
   von `tests/vizz10_unit.json` aus Vizz 1.0, Installer-Test in Chromium, Gegenprobe `tests/vizz_mutants.py`):
   **`ALL HOST TESTS PASSED`**, „install tests passed“, „web tests passed“, „backup web tests passed“, „converter
   (wasm) test passed“, „vizz installer: all ok“ (Entwicklungs-Build, Vizz 2.0, Skiff 2.0.1 und Vizz 1.0 als
   Ausgangsstand), „vizz_mutants: every fault caught“, Rückgabewert 0. Der erste Lauf scheiterte an
   `emsdk_env.sh`, das unter `dash` keinen Pfad setzt; `build-vizzbox.sh` setzt ihn jetzt selbst.
3. **Platz im Flash gemessen** (Abschnitt „Platz im Flash“ unten).

### Als Nächstes

Etappe 2: der Produzent auf dem Host – Generatoren, Arrangement, Determinismus, `tools/vizzbox_render`, erste Renders.
Die Architektur steht fest (Abschnitt „Plan“ unten).

## Platz im Flash

Der App-Bereich des FM-1 ist **581 564 Bytes** groß (XIP, `0x8DFBC`). Vizz 2.0 (Release, mit zweitem Kern) belegt
**553 052 Bytes**, frei sind **28 512 Bytes**. Ziel nach Abschnitt 7: Produzent, Tabellen und Bildschirm darin, mit
mindestens 2 KB Reserve, also **höchstens rund 26 500 Bytes** für alles Neue.

Gemessen mit `tools/size_report.py build/felucca.elf` am Release-Build (ELF von `./build.sh --release 2.0`): die
Bytes im Abbild (`.text` + `.ram_text` + `.data`) nach der Datei, die ein Symbol definiert; was der Compiler
eingebettet hat, zählt dort, wo es landet. 540 191 der 553 052 Bytes sind Symbolen zugeordnet (der Rest: Ausrichtung,
Literal-Pools).

| Bytes | Modul | Inhalt |
| ---: | --- | --- |
| 124 387 | `gen/felucca_samples.h` | Samples (IMA-ADPCM): SAMPLE-Sets PIANO (5 Zonen, ~41 KB), FLUTE (3, ~22 KB), SAX (3, ~22 KB); SLICE-Breaks BREAK (~22 KB) und FUNK (~15 KB) |
| 40 422 | `ui_graph.c` | die Seitengrafiken (`draw_graph` allein 30 018) |
| 33 244 | `ui_input.c` | Tasten und Regler der Oberfläche (`ui_input` 23 878, `edit_param` 4 924) |
| 23 373 | `ui_draw.c` | Seiten zeichnen (`ui_draw_page` 15 374) |
| 21 469 | `gen/ui_fonts.h` | die vier Schriften |
| 16 842 | `main.c` | Start, Hauptschleife, Tasten-/LED-Interrupt (`fm1_main` 11 418, `fm1_timer5_irq` 4 766) |
| 14 014 | `ui.c` | Oberfläche: Zustand, Laden von Sounds, Undo |
| 13 923 | `editor.c` | Editor-Protokoll (Backup, Installer) – **nie streichen** |
| 12 923 | `bank.c` | Pattern-Pool, Listen, SONG |
| 11 560 | `gen/felucca_tables.h` | Tabellen (FM6-Exponent, Sinus …) |
| 11 445 | `fx.c` | Mix, Delay, Reverbs, Chorus, Insert |
| 10 855 | `ui_fm6.c` | FM6 LAB (Operator-Seiten) |
| 10 650 | `seq.c` | Sequencer, Tastatur, Arp, SEQ MIDI OUT |
| 10 129 | `eng_drum.c` | DRUM-Engine (`drum_render` 7 042) |
| 8 784 | `gen/ui_icons.h` | Icons |
| 7 736 | `ui_blocks.c` | Karten, Kopf- und Fußzeile |
| 7 424 | `project.c` | Projekte, Autosave |
| 6 572 | `params.c` | Parameterbeschreibungen (`TP` 2 288) |
| 6 358 | `phys_dsp.c` | PHYS-Modelle |
| 6 116 | `perform.c` | FX-Layer (REPEAT, TAPE STOP, FREEZE …) |
| 5 730 | `drum_voice.c` | die Drum-Stimmen |
| 5 582 | `gfx.c` | Zeichnen |
| 4 916 | `audio.c` | Audio-Interrupt |
| 4 798 / 4 728 | `eng_grain.c` / `eng_fm6.c` | Engines GRAIN, FM6 |
| 3 966 … 1 996 | übrige Engines | ANALOG 3 966, SLICE 3 794, PHASE 3 608, TRIO 3 418, SAMPLE 3 128, FORMANT 2 845, DRUM-X 2 010 (+ `drumx_voice.c` 2 694), WHEEL 2 310, NOISE 2 140, LOFI 1 996, PHYS 1 853 (+ `phys_symp.c` 1 010) |
| 3 521 / 2 453 / 2 048 / 1 730 / 1 550 | `ui_tools.c` / `ui_dx.c` / `ui_neon.c` / `ui_quark.c` / `ui_crypt.c` | SEQ TOOLS, DRUM-X-Seiten, Grafik-Stile NEON, QUARK, CRYPT |

Die vollständige Liste (je Datei und die größten Symbole) erzeugt `python3 tools/size_report.py build/felucca.elf 80`.

**Einschätzung.** Der Produzent ist im Kern Logik, die einmal pro Takt läuft, und Tabellen: geschätzt 10–14 KB Code
(Hauptschleife, auf Größe kompiliert wie Skiffs übrige Oberfläche), 3–5 KB Tabellen für 37 Subgenres (gemeinsame
Drum-Raster statt je Subgenre eines) und 3–5 KB für Bildschirm und Bedienung. Das passt in die 26,5 KB, aber knapp.
Reicht es nicht, wird nach Abschnitt 7 vorgegangen (erst den eigenen Code verkleinern, dann in der GROOVEBOX streichen,
mit gemessener Ersparnis je Posten). Kandidaten, die kein Genre braucht, mit ihrer heutigen Größe als Obergrenze der
Ersparnis: die SAMPLE-Sets FLUTE oder SAX (je ~22 KB, falls kein Genre sie wählt), FM6 LAB (`ui_fm6.c` 10 855), die
Grafik-Stile NEON / QUARK / CRYPT (zusammen 5 328), WHEEL (2 310). Gemessen wird erst, wenn eine Streichung nötig ist:
dann je Posten ein Build ohne ihn und der Vergleich mit `tools/size_diff.py`.

RAM: `.data`+`.bss` sind fest (neue Variablen wie bei Vizz in den Pool, `.pool`, beim Start genullt); im Pool sind
9 852 Bytes frei.

## Plan (Architektur des Produzenten)

Festgelegt nach dem Lesen von Skiffs Code; die Begründungen kommen mit dem Code in die Abschnitte unten.

- **Eigene Dateien** `producer.c` (Generatoren, Arrangement, Steuerung), `producer_tables.c` (Genres, Subgenres,
  Raster, Akkordfolgen, Sound-Listen), `ui_vizzbox.c` (Bildschirm, Bedienung, Favoriten); in Skiffs Quellen nur kleine
  Haken.
- **In Skiffs normalen Strukturen:** jede Spur spielt ein Pattern von 16 Steps zu 1/16. Der Produzent schreibt in der
  Hauptschleife den nächsten Takt jeder Spur in Skiffs Launch-Warteschlange (`launch.c`, wie PERFORM: `launch_q`,
  Modus LOOP) und der Audio-Interrupt tauscht ihn an der Taktgrenze ein. Klang, SEQ MIDI OUT, CC 102 und CC 103 laufen
  dadurch genau wie bei einem von Hand programmierten Pattern; lange Noten (Pads) gehen über die Taktgrenze weiter.
- **Erzeugt im Steuertakt:** pro Takt einmal, in der Hauptschleife, spätestens einen Takt im Voraus; nie im
  Audio-Interrupt. Dort nur ein kleiner Haken je 1/16-Step, der vorbereitete Werte anwendet (Tempo, Filterfahrten,
  FX-Layer, CC 104–109) – so ist das Ergebnis unabhängig davon, wann die Hauptschleife läuft, und bitgleich.
- **Arrangement über eigene Steuerung:** pausierte Spuren bekommen leere Patterns; `P_MUTE` und SOLO bleiben dem Nutzer,
  CC 103 meldet weiter nur sie.
- **Die Projekte des Nutzers bleiben unberührt:** Beim ersten PLAY im VIZZBOX-Modus hält Skiff erst die geänderten
  Patterns des Nutzers fest (wie das Autosave es ohnehin tut) und der Produzent merkt sich die GROOVEBOX-Sitzung im RAM;
  solange er die Spuren hat, schreiben weder Autosave noch Pattern-Pool. Zurück in der GROOVEBOX kommt die Sitzung
  zurück.
- **36 Subgenres, nicht 37.** Die Tabelle in Abschnitt 4 des Auftrags (und das Konzept, `docs/VIZZBOX.md` 5) hat
  10 Genres mit 6 + 6 + 3 + 4 + 3 + 4 + 2 + 3 + 3 + 2 = **36** Zeilen; die Zahl 37 im Text ist verzählt. Gebaut werden
  alle 36, keine fehlt und keine wird erfunden.
- **SELECT hat keinen Taster** (die FM-1 hat 14 Tasten und sieben Drehgeber ohne Druckfunktion, `panel.c`). LÄNGE
  liegt deshalb auf einem anderen Bedienelement; die Belegung wird mit der Bedienung (Etappe 4) festgelegt und
  begründet.
