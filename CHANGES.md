# Vizz 2.0 – Änderungen gegenüber Skiff 2.0.1

Vizz 2.0 ist eine geänderte Fassung von Skiff 2.0.1 (illuminus5, <https://github.com/illuminus5/skiff>, GPL-3.0; Skiff
baut auf Felucca von Leo Kuroshita / Hügelton Instruments auf). Basis ist der Tag `v2.0.1` (`b03d98a`). Die Änderungen
sind die fünf Commits in `patches/` (`git format-patch v2.0.1..vizz-2.0`); `git am -3 patches/*.patch` auf einem
Branch ab `v2.0.1` ergibt genau den gebauten und getesteten Baum.

Die Patches von Vizz 1.0 wurden **portiert**, nicht angewendet: gleiches Verhalten nach außen, an den Stellen des neuen
Sequencers von Skiff 2.0.

| Patch | Inhalt |
| --- | --- |
| 0001 | SEQ MIDI OUT auf dem Sequencer von 2.0: Noten (eigene Längen, Überlappung, Ties, Ketten, SONG ONCE), CC 102, MIDI Clock, Start/Stop, CC 123; MENU › MIDI › SEQ MIDI OUT; `tests/seqmidi_test.c`; MIDI-Tab mit elf Zeilen |
| 0002 | Mute-Status als CC 103 nach dem gemeinsamen MUTE von 2.0 (getippt, gehalten) und SOLO; stumme Spuren ohne Note-On; Fälle 1–8 und gehaltenes MUTE im Test |
| 0003 | Name Vizz auf dem Gerät, Version v2.0, Kennung `FM-1_820`, Paket `vizz-2.0.fwsc`, Installer als eine Datei mit Skiffs ganzer 2.0-Installer-Logik |
| 0004 | Test: der Installer in Chromium gegen ein simuliertes Gerät mit Vizz 1.0 (Backup → Installation → Konvertierung) |
| 0005 | Gegenprobe: 15 absichtliche Fehler, jeder wird von einem Test erkannt |

Vizz 1.0s Patch 0006 (Platz im Flash, Bau ohne zweiten Kern) entfällt: Skiff 2.0 ist kleiner, Vizz 2.0 wird mit Skiffs
Standard-Konfiguration gebaut, **mit zweitem Kern** (unten, „Platz im Flash“).

## Ergebnis (`out/`)

| Datei | |
| --- | --- |
| `vizz-2.0.fwsc` | 610 442 Bytes, Kennung `FM-1_820`, Version `v2.0`; App 553 052 Bytes (**28 512 Bytes frei** im App-Bereich) |
| `vizz-installer.html` | 1 374 475 Bytes, Browser-Installer als eine Datei: Paket und Konverter (`conv.wasm`) eingebettet |
| `SHA256SUMS` | Prüfsummen der beiden (`816b8967…` das Paket, `62f40be5…` der Installer) |
| `LICENSE`, `LICENSING.md`, `LICENSES/`, `ATTRIBUTION*.txt` | wie in Skiffs Release-Ordner; der Installer verlinkt sie |

Gebaut mit `./build-vizz.sh` nach Skiffs `BUILDING.md`: JieLi-Toolchain `jieli-linux-toolchains-20260730.1`
(clang 4.0.1), AC79-SDK `AC79NN_SDK_V1.2.1_2023-12-13` (die drei Dateien, die ins Paket gehen, stimmen mit Skiffs
SHA-256 in `tools/build.py` überein), `./build.sh --release 2.0`; alle Prüfungen von `build.py` „ok“ (RAM-Code ohne
Aufrufe ins XIP, Registerzugriffe nur in `hal/`, RAM 79 924 von 98 304 Bytes, Pool 346 500 von 356 352 Bytes). Den
Konverter für den Installer baut `web/conv/build.sh` mit Emscripten 6.0.13. Die Paketgröße ist bei Skiff fest
(aufgefülltes Flash-Image): reines Skiff 2.0.1 ergibt 610 429 Bytes, Vizz 13 Bytes mehr (V und Z in der Schrift des
Update-Loaders, wie bei 1.0).

## 1. SEQ MIDI OUT (0001)

Wie in Vizz 1.0 (MENU › MIDI › SEQ MIDI OUT, Standard ON): jede Spur spielt auf ihrem Kanal (T1..T6 CHANNEL) mit –
Noten und Drum-Treffer (GM-Noten der Lanes, auch bei den eigenen Kits USR1–3) mit Velocity (Akzent 127), Ratchets,
Flams und Slides wie gespielt; **CC 102** = Step-Index beim Betreten eines Steps; mit INT-Clock **MIDI Clock**
(24 ppq), **Start**, **Stop**; **CC 123** bei einer Panik. Auch STEP PREVIEW (der Step unter dem Cursor, gestoppt)
geht hinaus, wie in 1.0.

Die Noten kommen dort heraus, wo der Sequencer von 2.0 sie anschlägt und beendet (`seq.c`: `seq_step`, `seq_release`,
`seq_keep_only`), also genau wie der Klang. Festlegungen für 2.0:

- **Noten mit eigener Länge.** NOTES › LENGTH unter einem Step ist ein GATE-Lock des Steps, 2–16 Steps sind Ties pro
  Note (#25). Jede Note bekommt ihr Note-Off zu ihrem eigenen Ende; die Töne eines Akkords enden einzeln.
- **Überlappung, gleiche Tonhöhe.** Klingt auf einem Kanal dieselbe Tonhöhe noch, wenn der Sequencer sie neu
  anschlägt (eine lange Note mit ihrem halben Schritt Ausklang, ein früher Step durch NUDGE), kommt zuerst ihr
  Note-Off, dann das Note-On. Dazu merkt sich SEQ MIDI OUT je Spur, welche gesendeten Noten noch klingen (`seq_mo`, ein
  Bit je Tonhöhe, im Pool); Note-Offs gehen nur für gesendete Noten hinaus. Ein Slide in die noch klingende gleiche
  Note bleibt wie in 1.0 eine Note (kein neues Note-On).
- **Tie** (TIE-Step oder Tie pro Note): eine durchgehende Note, ein Note-On, ein Note-Off.
- **Ketten (CHAIN).** CC 102 ist der Step-Index im gerade spielenden Teil: jeder Teil beginnt bei 0 und zählt bis zu
  seiner LENGTH (`launch_step` setzt den Teil auf seinen ersten Step). Eine Note, die von einem Teil in den nächsten
  weiterklingt (`launch_carry`), bleibt eine Note.
- **SONG ONCE.** Am Ende stoppt Skiffs `song_rewind` den Transport über `seq_stop`: die Note-Offs und **Stop** wie bei
  einem normalen Stopp. Nur mit INT-Clock (mit externer Clock sendet Vizz weder Start, Clock noch Stop).
- **Panik:** CC 123 für die gesendeten Noten einer Spur, wenn Skiff sie ohne Note-Off fallen lässt (MIDI-IN-Überlauf,
  ein empfangenes CC 120 All Sound Off).
- **Einstellung:** Bit 3 des Einstellungsbytes `CPU2_BYTE` (`favorites.factory[15][5]`), wie in Vizz 1.0. 2.0 liest
  die Einstellungen von Vizz 1.0 (PER4 mit Skiffs Marke) als Skiffs eigene und speichert sie als SKS1 mit diesem Byte:
  wer SEQ MIDI OUT in 1.0 ausgeschaltet hatte, hat es nach dem Update weiter aus (getestet, unten).

## 2. Mute-Status über CC 103 (0002)

Nach `docs/FIRMWARE-MUTE.md`. **Effektiv stumm** ist, was den Klang der Spur stummschaltet, mit genau der Auswertung
der Audio-Seite (`perform.c perf_begin` und `perf_mute`; die LEDs in `ui_layer.c glo_sounding` ebenso):

- das gemeinsame **MUTE** (`p[P_MUTE]`): GLO, FX oder PERFORM, schwarze Taste getippt (PERFORM an seinem
  LAUNCH-Punkt), der MIXER;
- das **gehaltene MUTE**, nur solange gehalten: FX ab dem Drücken (`perf_held`), GLO ab dem Drücken und PERFORM,
  sobald es ein Halten ist (MENU › HOLD), über `perf_cut`. Anders als in Vizz 1.0, wo die schwarzen Tasten im
  FX-Layer ein Gate-Effekt waren und nicht zählten: in 2.0 sind sie das MUTE selbst, gehalten nur solange gehalten;
- **SOLO** – 2.0 hat es noch: GLO + weiße Taste F3..D4 gehalten (`perf_solo`), die anderen Spuren stumm;
- gehaltenes MUTE und SOLO zählen nicht, solange `perf_kill` die Layer-Effekte abschaltet (Menü, Dialog) – wie im
  Klang.

Eine stumme Spur sendet **keine Note-Ons**; **Note-Offs** und **CC 102** laufen weiter. Wird sie stumm, während
gesendete Noten klingen, kommt zuerst **CC 123** auf ihrem Kanal, dann CC 103 = 127; wird sie wieder hörbar, kommt
CC 103 = 0 vor ihrem nächsten Note-On (auch wenn ein Launch das MUTE mitten im Block umstellt).

**CC 103** auf dem Kanal der Spur (`trk_midi_ch`): **127 = stumm, 0 = hörbar**. Gesendet

- bei jeder Änderung: einmal pro Audio-Block wird der Zustand jeder Spur mit dem zuletzt gesendeten verglichen (jede
  Quelle: Tasten, gehaltene Tasten, Solo, Launches, Laden, Undo, Editor …), auch im Stopp; ebenso, wenn sich der Kanal
  einer Spur ändert (klingen dabei gesendete Noten: CC 123 auf dem alten Kanal);
- für alle sechs Spuren beim Start (direkt nach `FA`; mit externer Clock beim Start ohne `FA`);
- für alle sechs einmal pro Takt während der Wiedergabe (16 Sechzehntel, gezählt wie Skiffs BAR-Launches,
  `launch_steps`; auch mit externer Clock);
- für alle sechs, wenn SEQ MIDI OUT eingeschaltet wird, und wenn USB verbunden wird (`usb.config`);
- bei SEQ MIDI OUT OFF nichts davon.

Last: 6 Vergleiche pro Block, 6 Controller pro Takt plus Änderungen. Kostenmaß der Render-Schleifen im
Audio-Interrupt (`tests/target_budget.py`): 7 598 gegenüber 7 522 bei reinem Skiff 2.0.1 (+1,0 %, Budget 8 441); der
Interrupt für Tasten und LEDs unverändert (33 530).

## 3. Name Vizz (0003)

Nur Sichtbares und die Dateinamen der Ergebnisse; Code-Bezeichner, Kommentare und Dateien behalten Skiffs Namen.

- Startbildschirm: „Vizz / v2.0 / on Skiff 2.0.1 / Hügelton + community“.
- ABOUT: „VIZZ“, „based on Skiff 2.0.1 / Felucca“, „v2.0“; die Credits beginnen mit VIZZ („A modified version of
  Skiff 2.0.1 for the VIZZ visualizer …“) und SKIFF (illuminus5, GPL-3.0, Link); alle Credits und Lizenzen von
  Skiff 2.0.1 bleiben, ebenso „Skiff: illuminus5“, der Link und der QR-Code zu Skiffs Quellen. Die große Schrift L hat
  dafür ein Z bekommen (Platz ist da).
- Absturzbild „VIZZ CRASH“; Update-Loader „WAITING FOR THE VIZZ INSTALLER“ / „THE VIZZ INSTALLER“ (5×7-Schrift mit V
  und Z).
- MENU › THEME zeigt das Standard-Theme als „VIZZ“; die Theme-Liste des Editors (`ED_UI_PALETTES`) behält „SKIFF“.
- Version `v2.0` (`FELUCCA_VERSION`; der Editor bekommt „FELUCCA v2.0“).
- **USB-Gerätenamen und -Deskriptoren unverändert** (`usb.c` nicht angefasst): das Gerät meldet sich weiter als FM-1,
  der Loader als „Felucca Update“.
- `README.md` (Hinweis oben) und `BUILDING.md` sagen, dass Vizz eine geänderte Fassung von Skiff 2.0.1 ist.
  `LICENSE`, `LICENSING.md`, `LICENSES/` und alle Urheberhinweise unverändert.
- `web/make_vizz_installer.py`: macht aus Skiffs **2.0**-Installer-Seite (`web/index_pkg.html` mit `fm1pkg.js`,
  `fm1ota.js`, `fm1backup.js` und dem Konverter `conv/conv.js`) **eine** HTML-Datei; Paket und `conv.wasm` als
  data:-URLs eingebettet. Skiffs Logik bleibt ganz: über Firmware vor 2.0 erst das komplette Backup
  (`Vizz-backup-DATUM.json`), nach der Installation die Konvertierung dessen, was 2.0 so nicht lesen kann, nur das
  zurückgeschrieben, mit Liste; der Rückweg zur Original-Firmware V15. Titel und Texte „Vizz“, nur FM-1; Hinweis, dass
  Vizz eine geänderte Fassung von Skiff ist; Editor- und Learn-Link auf Skiffs Online-Seiten.
- Angepasste Tests: Startbildschirm (`ui_render`), L-Schrift (`ui_test`), MENU › THEME (`editor_test`,
  `web/test_web.mjs`), Kennung des Entwicklungs-Pakets (`web/test_web.mjs`: `FM-1_8xx`). Skiff 2.0 vergleicht jedes
  UI-Bild mit `tests/ui_golden.txt`: geändert sind genau die beabsichtigten – 28 Bilder des MIDI-Tabs (0001: die neue
  Zeile) und 76 für den Namen (Startbildschirm, die vier ABOUT-Bilder, im Standard-Theme die DISPLAY-Seite mit THEME
  VIZZ), je in allen Paletten; die übrigen 3 284 von 3 388 unverändert.

## 4. Update von Vizz 1.0 (0003, 0004)

Wie Skiff 2.0 die Herkunft der Daten erkennt:

- **Installer-Seite:** Sie fragt die laufende Firmware nach INFO. Meldet sie eine Version vor 2.0 (`FELUCCA v1.x`) und
  kann sie komplette Backups, sichert die Seite erst alles und konvertiert nach der Installation. Die Kennung wertet sie
  nur für das Modell (FM-1) aus.
- **Firmware und Konverter** (`conv.wasm` ist der Code der Firmware selbst) entscheiden an den **Formatkennungen**:
  Projekte SKF1–SKF4 und Feluccas FUN*, User-Sounds nach Version, Einstellungen PER4/SKS1 (mit Skiffs Marke 0xA5 als
  Skiffs eigene gelesen).

Vizz 1.0 ist innen Skiff 1.4: seine Patches haben kein Speicherformat angefasst, es meldet `FELUCCA v1.0` und
schreibt Skiff 1.4s Formate (Einstellungen mit Skiffs Marke). Der Vizz-Installer deckt das zusätzlich **ausdrücklich**
ab: Bei einem Vizz entscheidet die Kennung – `FM-1_8XY` ist Vizz X.Y, Vizz **1.x** (`FM-1_81Y`) wird wie Skiff 1.4
behandelt (Backup + Konvertierung), Vizz 2.x wie Skiff 2.0; Entwicklungs-Builds (`FM-1_80Y`) und andere Firmware nach
ihrer Version wie bei Skiff.

**Test** (`web/test_vizz_installer.mjs`, in `tests/run_tests.sh`): der Installer, wie er ausgeliefert wird, in
Chromium; Web MIDI ist ein simuliertes Gerät. Dessen Inhalt hat **Vizz 1.0s eigener Code** erzeugt
(`tests/vizz10_fixture.sh` in einem Baum Skiff v1.4 + die sechs Patches von `vizz-1.0`; `build-vizz.sh` erzeugt ihn
neu und vergleicht: dieselben Bytes): die INFO-Antwort „FELUCCA v1.0“, Kennung `FM-1_810`, die Musik (SKF3), die
Einstellungen (PER4, SEQ MIDI OUT OFF, T2 auf Kanal 10), Slot 1 von Vizz 1.0 gespeichert (SKF3), Slot 3 ein älteres
Skiff-Projekt, das 1.4 so behielt (SKF2), ein User-Sound, die Patterns. Ergebnis:

- erst das komplette Backup, gespeichert als `Vizz-backup-DATUM.json` – bitgleich mit den 29 Objekten des Geräts;
- dann die Frage (das Backup ist der Rückweg), dann die Installation; das Gerät meldet danach die Kennung des Pakets;
- dann die Konvertierung im Installer: genau das zurückgeschrieben, was der Konverter liefert (Slot 3 SKF2 → SKF4, dazu
  das FM6-Patch-Objekt der User-Sounds, das 2.0 anlegt), Musik, Einstellungen und Slot 1 unverändert; die Liste
  („4: SKF2 -> SKF4 (converted)“) und „Done. What the firmware before saved was converted for 2.0“;
- ein Vizz 1.x mit der Version 2.0 im INFO: wegen seiner Kennung trotzdem Backup + Konvertierung; Skiff 1.4
  (`FM-1_714`) und ein Entwicklungs-Build nach der Version ebenso;
- Vizz 2.0 (`FM-1_820`) und Skiff 2.0.1 (`FM-1_720`): kein Backup, keine Frage, nur die Installation;
- 2.0 liest die Einstellungen von Vizz 1.0 als Skiffs eigene: SEQ MIDI OUT OFF und T2 auf Kanal 10 bleiben.

### Update-Anleitung (von Vizz 1.0 auf Vizz 2.0)

1. Die FM-1 direkt per USB an den Computer, gestoppt. `vizz-installer.html` in Chrome oder Edge öffnen (bietet der
   Browser für die direkt geöffnete Datei kein MIDI an: den Ordner mit `python3 -m http.server` ausliefern und über
   `localhost` öffnen).
2. **Install.** Der Installer erkennt Vizz 1.0 und speichert zuerst ein komplettes Backup:
   **`Vizz-backup-DATUM.json`** im Download-Ordner. **Diese Datei aufheben** – sie ist der Weg zurück.
3. Die Frage bestätigen. Der Installer installiert Vizz 2.0 (nicht abstecken; bricht es ab, nochmals Install: es geht
   weiter), danach konvertiert er, was 2.0 so nicht lesen kann (alte Projekte, alte User-Sounds), schreibt nur das
   zurück und listet es auf. Startbildschirm danach: „Vizz v2.0 on Skiff 2.0.1“.
4. Ab jetzt speichert die FM-1 in den Formaten von 2.0. Projekte, Patterns, User-Sounds und Einstellungen (auch SEQ
   MIDI OUT und die Kanäle) sind übernommen.

- **Schlägt die Konvertierung fehl** (Meldung „Installed, but converting … failed“): im Skiff-Editor
  (<https://illuminus5.github.io/skiff/webapp/editor/>) die Backup-Datei wiederherstellen – der Editor von 2.0
  konvertiert beim Wiederherstellen. Ebenso für ein Projekt, das wegen voller Patterns „OLD FORMAT“ bleibt: Patterns
  freigeben (SAVE › PATTERNS), Backup im Editor ziehen und wiederherstellen.
- **Zurück auf Vizz 1.0:** Vizz 1.0 mit seinem Installer installieren (`out/vizz-installer.html` auf dem Branch
  `vizz-1.0`), dann im Skiff-Editor die Datei `Vizz-backup-DATUM.json` wiederherstellen. Vizz 1.0 liest nicht, was
  2.0 gespeichert hat: solche Projekte und User-Sounds wirken dort leer, die Einstellungen beginnen mit den
  Standardwerten – deshalb das Backup von vor dem Update.
- **Zurück zur Original-Firmware:** im Installer unter „Return to the official firmware“ mit M-VAVEs `FM-1.fwsc`
  (V15).
- `tools/fm1_install.py` (Kommandozeile) konvertiert nichts; dann im Editor Backup ziehen und wiederherstellen.

## Paketkennung: `FM-1_820`

Vizz-Schema `FM-1_8XY` wie in 1.0 (Vizz 1.0 = `FM-1_810`, Vizz 2.0 = **`FM-1_820`**, Entwicklungs-Builds
`FM-1_800`; Skiff ist `FM-1_7XY`, Felucca `FM-1_9XY`). Auch in 2.0 wertet keiner der Leser mehr aus als das Modell vor
dem `_` (die Ziffern nur bei SMK-Geräten unter V016): App und Loader melden die Kennung nur, der Web-Updater prüft das
Modell und nach der Installation, dass das Gerät genau die Kennung des Pakets meldet; `tools/fm1_install.py` verlangt
`Modell_Ziffern`. Skiffs Pages-Site (`web/make_site.py`) verlangt `7xx` – Vizz benutzt `make_vizz_installer.py`, das
`FM-1_8xx` verlangt.

## Platz im Flash

Der App-Bereich des FM-1 ist 581 564 Bytes groß (XIP, `0x8DFBC`). Release-Builds mit dieser Toolchain:

| | App | frei |
| --- | --- | --- |
| Skiff 2.0.1 (`--release 2.0.1`) | 551 372 Bytes | 30 192 Bytes |
| **Vizz 2.0** (`--release 2.0`) | 553 052 Bytes | **28 512 Bytes** |

Vizz 2.0 braucht 1 680 Bytes mehr und passt damit in **Skiffs Standard-Konfiguration**: gebaut **mit zweitem Kern**
(`FELUCCA_CPU2=1`, MENU › SYSTEM › CPU „2 CORES (BETA)“ wie bei Skiff 2.0.1). Keine der Einsparungen von Vizz 1.0s
Patch 0006 ist nötig. Neue globale Variablen liegen wie bei Skiff 2.0 im Pool (`.pool`, beim Start genullt), damit
sie die anderen nicht verschieben: Pool 346 500 von 356 352 Bytes (+108 gegenüber Skiff), RAM `.data`+`.bss`
unverändert.

## Testergebnis

**`ALL HOST TESTS PASSED`** – Lauf von `./build-vizz.sh` auf genau dem veröffentlichten Stand (frischer Klon von Skiff
`v2.0.1`, die fünf Patches, Release- und Entwicklungs-Build, `tests/run_tests.sh` komplett, mit den Tests, die das
gebaute Paket, Emscripten und Playwright brauchen): 132 Test-Schritte, 8 322 Einzelprüfungen „ok“, 0 Fehler.
Zum Vergleich reines Skiff 2.0.1 in derselben Umgebung: 129 Schritte, 8 254 „ok“, alle bestanden (die drei
Schritte mehr: `seqmidi_test`, der Installer und sein Test). Derselbe Lauf hat `tests/vizz10_unit.json` aus Vizz 1.0
neu erzeugt (bitgleich), den Installer-Test auch mit dem Release-Installer aus `out/` ausgeführt (13 Prüfungen „ok“)
und die Gegenprobe (alle erkannt).

Darin u. a.:

- **`seqmidi_test`** (54 Prüfungen): Noten, Kanäle, Drum-Treffer (auch mit den eigenen Kits USR1–3), Ratchet, Slide,
  CC 102, Clock, Start/Stop, externe Clock, das Menü (OFF ist Bit 3 von `CPU2_BYTE`, RESET SETTINGS: ON); neu für
  2.0: Noten eigener Länge enden einzeln (Akkord 1, 2 und 4 Steps; ein Viertel-Step per GATE-Lock), gleiche Tonhöhe neu angeschlagen während sie
  klingt → Note-Off direkt vor dem Note-On, Tie = eine Note (TIE-Kette und Ties pro Note), CHAIN: CC 102 zählt jeden
  Teil ab 0 (A 0..3, B 0..5, A 0..3) und eine Note über die Teilgrenze bleibt eine, SONG ONCE am Ende → Note-Offs, ein
  Stop, danach keine Clock; in jedem Fall wechseln sich Note-On und Note-Off je Tonhöhe ab. CC 103: die Fälle 1–8 von
  Vizz 1.0 (stumm mit klingender Note: CC 123 vor genau einem CC 103 = 127; wieder hörbar; sechs nach `FA`; sechs pro
  Takt; OFF; Kanal 10 und Kanalwechsel mit klingender Note; Solo; CC 102 einer stummen Spur), sechs beim
  USB-Verbinden, dazu das **gehaltene MUTE** in GLO, FX und PERFORM (127 solange gehalten, CC 123 vorher, keine Note-Ons; danach 0, die Noten wieder, das
  MUTE wie vorher) und das getippte MUTE in FX;
- **Installer-Test** (Abschnitt 4) mit dem echten Ein-Datei-Installer in Chromium;
- **Klang:** 176 Regressions-Renders gegen `tests/golden.txt` von Skiff 2.0.1 – **0 geändert**, auch mit dem zweiten
  Kern (jede Aufteilung der Spuren); 0 Health-/Stimmen-Fehler: der Klang ist bit für bit der von Skiff 2.0.1;
- UI-Renders: 241 Bildschirme × 6 Paletten, 0 Lint-Befunde, Ausrichtung 0 Abweichungen, UI-Golden wie in Abschnitt 3;
- Kosten der Render-Schleifen: alle im Budget (Abschnitt 2);
- Editor-Protokoll (Tabellen = Firmware), Projekte, Backup, alle Engines, Konverter nativ und als WebAssembly, der
  Browser-Emulator, ASan/UBSan und Fuzzer, Installer-CLI gegen ein simuliertes FM-1, Web-Tests, der zweite Kern.

Übersprungen, wie bei Skiff ohne diese Dateien bzw. Werkzeuge: M-VAVEs Original-Pakete (V15, SMK V016), der
PHYS-Vergleich mit DaisySP und – mangels Instruktionszähler auf diesem Host – die Kostenmessung in `mod_test`.

**Gegenprobe** (`tests/vizz_mutants.py`, von `build-vizz.sh` ausgeführt): jede von 15 absichtlichen Verfälschungen
lässt Tests fehlschlagen – Block-Vergleich aus, Note-On-Sperre aus, kein CC 123, SOLO bzw. gehaltenes MUTE nicht
gezählt, keine Takt-Wiederholung, keine Start-Meldung, gleiche Tonhöhe ohne Note-Off davor, Ende einer Note eigener
Länge nicht gesendet, Note-On für eine weiterklingende Tie-Note, Slide in die klingende Note neu angeschlagen, CC 102
über Kettenteile weitergezählt, Stop nur bei STOP gedrückt (nicht am Ende von SONG ONCE); im Installer: Vizz 1.x nur
nach Version erkannt, kein Backup vorher.

## Hinweise

- Ein Neubau mit `build-vizz.sh` ergibt `vizz-2.0.fwsc` bitgleich, solange das Datum gleich ist: ABOUT zeigt das
  Build-Datum (`__DATE__`, wie bei Skiff); an einem anderen Tag unterscheiden sich genau diese Bytes (und damit die
  Prüfsummen).
- `tools/fetch_cc0.py` wurde nicht ausgeführt: die Sets, die der Build benutzt, liegen in Skiffs Baum
  (`assets/samples-cc0/`); `build-vizz.sh` ruft es nur auf, wenn sie fehlen.
- Der Editor ist Skiffs Online-Editor (gleiches Protokoll). SEQ MIDI OUT gehört nicht zu den Menü-Einstellungen, die
  das Gerät dem Editor anbietet (`editor_menu.c`, wie in Vizz 1.0): eingestellt wird es am Gerät, MENU › MIDI.
- Skiffs SMK-37-Build ist nicht Ziel von Vizz; seine Kennung und sein Paketname sind unverändert (`skiff-smk37`).
