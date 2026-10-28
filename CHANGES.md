# Vizzbox 1.0 – Änderungen gegenüber Skiff 2.0.1

> **Stand: fertig, Etappe 8 von 8** (BRIEF-VIZZBOX.md). Build und alle Tests grün, jedes der 36 Subgenres hat eine
> Demo, alles auf `vizzbox-1.0`. **Nicht geprüft ist das Gerät selbst:** Es stand keine FM-1 zur Verfügung. Alles
> unten ist auf dem Computer gemessen – mit Skiffs Quellen für den Host übersetzt (dieselbe Klangerzeugung, derselbe
> Sequencer, dieselbe Oberfläche) und mit dem Ziel-Compiler für den Platz und das Kostenmaß. Was das heißt, steht in
> Abschnitt 15.

Die Vizzbox ist eine geänderte Fassung von **Skiff 2.0.1** (illuminus5, <https://github.com/illuminus5/skiff>,
GPL-3.0; Skiff baut auf **Felucca** von Leo Kuroshita / Hügelton Instruments auf) und baut auf **Vizz 2.0** auf
(Branch `vizz-2.0` dieses Repos). Sie macht die Musik selbst: ein **Produzent** in der Firmware erzeugt aus Genre,
Subgenre, Seed, Energie und Variation ganze Tracks – Intro, Groove, Aufbau, Drop, Break, Outro – in 10 Genres mit 36
Subgenres, spielt sie auf Skiffs sechs Spuren und meldet über SEQ MIDI OUT, wo im Song er ist (CC 104–109). Mit HOME +
PLAY ist die FM-1 wieder die GROOVEBOX: Skiff 2.0.1 mit Vizz 2.0, unverändert.

Basis ist der Tag `v2.0.1` (`b03d98a`); die Änderungen sind die Commits in `patches/`
(`git format-patch v2.0.1..vizzbox-1.0`), anzuwenden mit `git am -3 patches/*.patch` auf einem Branch ab `v2.0.1` –
`./build-vizzbox.sh` tut das und baut alles.

| Patch | Inhalt |
| --- | --- |
| 0001–0005 | **Vizz 2.0**, unverändert von `origin/vizz-2.0` (SEQ MIDI OUT, CC 103, Name Vizz, Installer-Test, Gegenprobe) – siehe `CHANGES.md` dort |
| 0006 | `tools/size_report.py`: wohin der Flash geht, je Quelldatei und Symbol |
| 0007 | **Der Produzent** (`producer.c`, `producer_isr.c`, `producer_tables.c`, erster `ui_vizzbox.c`), die Haken in Skiffs Quellen, `tools/vizzbox_render.c`, die Sound-Messung (`tools/vizzbox_sounds.c`, `vizzbox_sounds.py`, `vizzbox_pick.py`) |
| 0008 | **Tuning über Messungen:** Songlängen je Tempo, Stille vor dem Drop, Riser geschützt, Pegel unter Skiffs Master-Limiter, Lautheit je Subgenre, `tools/vizzbox_demos.py`, `tools/vizzbox_level.py` |
| 0009 | **Bedienung:** VIZZBOX-Bildschirm und -Tasten (`ui_vizzbox.c`), 16 Favoriten in eigenen Sektoren, neuer Stil während der Wiedergabe, ENDLOS; `tests/producer_test.c`, `tests/vizzbox_ui.c` mit Golden |
| 0010 | `tools/build.py`: der Entwicklungs-Build der FM-1 ohne serielle Konsole |
| 0011 | `tests/target_budget_cdc0.txt`: das Kostenmaß eines Builds ohne Konsole, gegen Vizz 2.0s eigenes |
| 0012 | **Name und Kennung:** Vizzbox, `FM-1_850`, `vizzbox-1.0.fwsc`; `web/make_vizzbox_installer.py`, `web/test_vizzbox_installer.mjs`; CC 104–109 beim Einschalten von SEQ MIDI OUT und wenn USB wiederkommt |
| 0013 | **Tests:** `tests/vizzbox_mutants.py` (Gegenprobe), `vizzbox_fuzz.c`, `vizzbox_compat.c`, `vizzbox_inactive.c`, `vizzbox_budget.c`, die Projekte des Nutzers in `producer_test.c`; die Vizzbox im Browser als eine Datei (`web/emu/make_vizzbox_emu.py`, `test_vizzbox_emu.mjs`) |
| 0014 | `tools/vizzbox_demos.py`: Zeiten erst gerundet, dann in Minuten und Sekunden geteilt (eine Songlänge von 299,6 s stand als „4:60“ in `demos/README.md`) |

Im Repo außerdem: `out/` (Paket, Installer, Prüfsummen, Lizenzen), `demos/`, `docs/VIZZBOX-ANLEITUNG.md`
(Bedienungsanleitung), `docs/VIZZBOX-MIDI.md` (CC 104–109 für die Empfängerseite), `build-vizzbox.sh`.

---

## 1. Was sich gegenüber Vizz 2.0 ändert

- **Neu:** der Produzent und sein Bildschirm (VIZZBOX-Modus), 16 Favoriten, ENDLOS, CC 104–109 auf Kanal 16, der Name
  Vizzbox mit Kennung `FM-1_850`, der Installer `vizzbox-installer.html`.
- **In Skiffs Quellen nur Haken**, jeder in `#if VIZZBOX` (ohne den Produzenten gebaut sind sie leer): der Schritt des
  Produzenten im Audio-Interrupt (`seq.c`), seine Eingaben und LEDs (`ui_input.c`), sein Bildschirm (`ui_draw.c`), der
  Modus beim Einschalten (`main.c`), das Autosave hält still, solange er die Spuren hat (`project.c`), Pattern-Pool und
  SONG ebenso (`bank.c`), die Favoriten-Sektoren im Flash-Fenster (`fm1_flash_map.h`); dazu der Abschnitt `.vbox`
  hinter `.bss` (`app.ld`) und, immer, der Name (Abschnitt 8).
- **Unverändert:** alles, was Vizz 2.0 sendet (Noten, CC 102, Clock, Start/Stop, CC 123, CC 103), die GROOVEBOX
  (geprüft: bitgleich, Abschnitt 11), USB-Namen und -Deskriptoren, die Speicherformate von Skiff 2.0.1, alle Credits
  und Lizenzen von Skiff, Felucca und Vizz.
- **Gestrichen: nichts.** Der Platz reichte ohne jede Streichung in der GROOVEBOX (Abschnitt 9).

## 2. Der Produzent

Wie er arbeitet, steht ausführlich vorn in `firmware/src/producer.c`. Kurz:

- **In Skiffs normalen Strukturen.** Jede Spur spielt ein Pattern von 16 Steps zu 1/16. Der Produzent schreibt in der
  Hauptschleife jeweils **einen Takt im Voraus** den nächsten Takt jeder Spur in Skiffs Launch-Warteschlange
  (`launch_q`, Modus LOOP); der Audio-Interrupt tauscht ihn an der Taktgrenze ein. Klang, SEQ MIDI OUT, CC 102 und
  CC 103 laufen dadurch genau wie bei einem von Hand programmierten Pattern. Im Audio-Interrupt nur ein kleiner Haken je
  1/16 (`producer_isr.c`), der vorbereitete Werte anwendet: Tempo, Filterfahrten, THROW, ein Effekt des FX-Layers,
  Parameterfahrten einer Spur, CC 104–109, der Klangwechsel bei einem neuen Stil.
- **Deterministisch.** Jede Rolle zieht aus einem eigenen Zufallsstrom (Seed, Rolle, Abschnitt, Takt). Derselbe
  Favorit ergibt dieselben MIDI-Bytes und dasselbe Audio – unabhängig davon, wann die Hauptschleife läuft (geprüft mit
  anderer Render-Blockgröße und nach einem simulierten Aus- und Einschalten).
- **Die sechs Rollen:** T1 DRUMS (Raster 16 Steps × 8 Lanes je Stil mit Ankern, Dichte nach Energie, Akzente, Fills am
  Phrasenende, Roll im Aufbau 1/4 → 1/8 → 1/16 → Ratchets, Crash auf der Eins des Drops), T2 BASS (14 Stile: ROOT,
  OFFBEAT, ROLLING, ACID, WOBBLE, SUB, REESE, OCTAVE, 808 mit Glide, synkopiert, Dub, Riff, Psy, Hard), T3 CHORDS
  (Progressionen als Stufen, PAD/STAB/PLUCK/GATE/PIANO/SKANK, Stimmführung), T4 LEAD (ein Motiv von 1–2 Takten je Song,
  Akkordtöne auf betonten Steps, kehrt wieder), T5 ARP (Modi über den Akkord, oder ein Break über SLICE), T6 FX (Riser
  über den Aufbau, Impact und Downlifter am Drop, Atmo). Alles in Skalenstufen; die Tonart vom Seed aus einer
  genretypischen Auswahl.
- **Arrangement** in Abschnitten nach den sieben Formen des Auftrags, mit Energiekurve; welche Rollen spielen, folgt
  aus Abschnitt und Energie; höchstens zwei dichte melodische Rollen zugleich. Das Arrangement lässt Spuren über eigene
  leere Patterns aus, **nie über das MUTE des Nutzers**; CC 103 meldet weiter nur MUTE und SOLO des Nutzers.
- **Übergänge** mit Skiffs Mitteln: HPF-Fahrt über den FX-Layer-FILTER im Aufbau (Techno: LPF zu), THROW und
  REPEAT/REVERSE im letzten Beat, ein stiller letzter Beat vor dem Drop (wo der Stil ihn hat, sonst mit
  35 % + VARIATION/2), TAPE STOP höchstens einmal, DUB-Throws, VINYL, Kick-Ausfall am Ende des Aufbaus.
- **Stimmenbudget 8** (auch mit zweitem Kern; der hält dann 4 Stimmen fürs Mitspielen frei): Für jeden Step des
  vorbereiteten Takts zählt der Produzent die klingenden Stimmen aus den gemessenen Ausklangzeiten der Sounds (Lanes,
  Mono-Rollen, Akkordnoten samt Ausklang, Swing, Ratchets, was der Takt davor nachklingen lässt, Platz für Kick und
  Bass des nächsten Takts) und nimmt zu viel in fester Reihenfolge weg (Arp-Note, oberste Akkordnote, Percussion, FX,
  Lead, Akkord; im Aufbau der Riser zuletzt; ein gehaltener Ton kommt lieber einen Beat später, als zu entfallen).
- **Die Musik des Nutzers bleibt unberührt.** Beim ersten PLAY merkt sich der Produzent die GROOVEBOX-Sitzung gepackt
  im RAM (`.vbox`); zurück in der GROOVEBOX ist sie wieder da. Solange er die Spuren hat, schreiben Autosave,
  Pattern-Pool und SONG nichts; gespeicherte Projekte fasst er nie an (geprüft, Abschnitt 11).

## 3. Genres und Subgenres

**Alle 36 Subgenres** der Tabelle in Abschnitt 4 des Auftrags, keins weggelassen: HOUSE 6, TECHNO 6, ELECTRO /
SYNTHWAVE 3, TRANCE 4, BREAKS / UK GARAGE 3, DRUM & BASS 4, DUBSTEP 2, HIP-HOP / LO-FI / TRAP 3, AMBIENT /
DOWNTEMPO 3, HARDSTYLE / HARDCORE 2. Der Text des Auftrags nennt 37; seine Tabelle und das Konzept (`docs/VIZZBOX.md`)
zählen 36 – gebaut sind alle 36, keins erfunden. Die Daten sind kompakte Tabellen (`producer_tables.c`, 2 818 Bytes
im Flash), kein Code je Genre.

- **Sounds durch Rendern und Messen ausgewählt** (nicht geraten): `tools/vizzbox_sounds` rendert jeden Werks-Sound in
  jeder Rolle, `vizzbox_sounds.py` misst Schwerpunkt, Tiefen- und Höhenanteil, Pegel und Ausklang, `vizzbox_pick.py`
  wählt je Rolle und Klangfarbe die passenden (Ausklang, den das Stimmenbudget trägt; Grundton für einen Bass; der
  Pegel erreichbar) und schreibt sie in die Tabellen.
- **Getunt über Messungen** (`tools/vizzbox_demos.py`, `vizzbox_level.py`):
  - **Songlängen:** Der Plan passt die Form an das Tempo an. Gemessen über 36 Subgenres × 6 Seeds: NORMAL
    **4:32–6:09**, KURZ **2:22–3:42**. Abweichung: KURZ wiederholt bei schnellen Tempi die Mitte (Drum & Bass mit
    halbierten Abschnitten käme sonst auf 1:50).
  - **Der Drop:** die Stille im letzten Beat davor −18 bis −36 dB unter den vier Takten davor; der Riser fehlt in
    keinem Aufbau mehr (vorher in 9 Subgenres).
  - **Der Mix:** Vorher lief jeder Drop 3–9 dB tief in Skiffs Master-Limiter (Schwelle −5,2 dBFS). Jetzt jede Rolle
    7 dB (Drums 10 dB) leiser, jeder Sound mit seiner gemessenen Spitze gedeckelt: der Limiter regelt im Drop im
    Mittel 0,1–2 dB.
  - **Lautheit:** ein Ausgleich je Subgenre (`VB_TRIM`); die 36 Demo-Ausschnitte liegen bei RMS −25,5 bis −20,3 dBFS (Median −22,1), Spitzen −11,1 bis −8,1 dBFS (Abschnitt 12).
- **Abweichungen von den Richtwerten des Auftrags:** keine bei Tempo, Swing und Form; die Klangfarben sind die
  gemessen passenden aus Skiffs Werks-Sounds (DIST, FM6-Growl, LOFI, VINYL, SPRING, GRAIN, SLICE-Breaks wie gefordert,
  wo Skiff sie hat). Mutable Instruments Grids wurde **nicht** übernommen (eigene Raster), also keine Attribution dafür.

## 4. Bedienung

| Bedienelement | Funktion |
| --- | --- |
| Regler 1 / 2 / 3 / 4 | GENRE / SUBGENRE / ENERGIE / VARIATION |
| SELECT drehen | TEMPO (1 BPM; Bereich des Stils ± 20; mit externer Clock ohne Wirkung, Anzeige „EXT“) |
| ALGORITHM drehen | LÄNGE: KURZ / NORMAL / ENDLOS |
| PRESETS drehen | der Seed (4 Hex-Stellen) |
| PLAY | Start / Stopp |
| REC | NEU: ein neuer Seed |
| HOME + PLAY | in die GROOVEBOX; dort HOME + PLAY zurück |
| FX / ARP / SEQ | DROP JETZT / BREAK JETZT / HALTEN |
| OCT− / OCT+ | Oktave der weißen Tasten |
| schwarze Tasten 1–6 | MUTE der Spuren T1–T6 (tippen), stumm solange gehalten, mit GLO SOLO – Skiffs GLO-Ebene, CC 103 meldet sie |
| weiße Tasten | der Sound der LEAD-Spur, auf die Skala des Songs eingerastet |
| SAVE / GLO + weiße Taste | Favorit 1–16 speichern / laden |

Der Bildschirm zeigt Genre, Subgenre, Länge, Tempo, Tonart, Seed, Energie und Variation, den Abschnitt mit Taktzähler
(`BUILD 12/16`), die Energiekurve des ganzen Songs mit Playhead, die sechs Spuren (spielt / M stumm / S solo), beim
Drehen groß den neuen Wert, bei gehaltenem SAVE/GLO die Favoriten. Eigene LEDs. In allen sechs Paletten.

**Abweichungen, begründet:**
- **LÄNGE auf ALGORITHM statt „SELECT drücken“:** Die Drehgeber der FM-1 haben keine Druckfunktion (`panel.c`: 14
  Tasten, sieben Drehgeber).
- **HOME + PLAY statt „HOME lang halten“:** HOME lang öffnet in Skiff schon das MENU. HOME + PLAY ist in Skiff frei und
  in beiden Modi gleich.
- **„Song übernehmen“** (optional im Auftrag) ist nicht gebaut: Der Platz (5 660 Bytes frei) reicht für die
  Hauptsachen mit Reserve, nicht sicher für diese Zugabe.

Was jede Taste tut, für jemanden, der nicht produziert: `docs/VIZZBOX-ANLEITUNG.md`.

## 5. Favoriten

16 Favoriten, je 8 Bytes (Genre, Subgenre, Seed, Energie, Variation, Länge, Tempo): ein Favorit spielt denselben Song
bitgleich wieder. Gespeichert in **zwei eigenen Sektoren A/B bei `0x95000` und `0x96000`** – im Flash zwischen dem
App-Bereich (endet bei `0x93000`) und Skiffs Speicher (beginnt bei `0x97000`), wo Skiff 2.0.1 und Vizz 2.0 nichts
lesen, schreiben oder löschen und der Update-Loader nur Sektoren mit seinem eigenen Datensatz löscht. Datensatz `VBF1`
mit Folgenummer und CRC, abwechselnd in A und B: Ein Stromausfall beim Schreiben kostet höchstens die letzte Änderung.
Geschrieben wird erst im Stillstand (ein Löschvorgang hält den Flash und damit das Audio an). Geprüft: über ein
Aus- und Einschalten, über ein Update, über Skiff 2.0.1 und Vizz 2.0 hinweg (Abschnitt 11).

## 6. Neuer Stil während der Wiedergabe, ENDLOS

- GENRE, SUBGENRE, ein neuer Seed oder ein Favorit während der Wiedergabe kommen **wie bei einem DJ**: ein Break von 8
  und ein Aufbau von 16 Takten, das Tempo gleitet darüber, dann der Song des neuen Stils ab seinem ersten Drop, in
  derselben Tonart. Die Klänge wechseln im stillen letzten Beat des Aufbaus – in der Hauptschleife vorbereitet, im
  Audio-Interrupt in einem Schritt gesetzt, alle Stimmen dort beendet –, so bleibt auch das bitgleich. ENERGIE,
  VARIATION und LÄNGE wirken ab dem nächsten Abschnitt, TEMPO gleitet über vier Takte.
- **ENDLOS:** Zyklen aus Break, Aufbau und Drop mit Mutationen; nach 4–8 Minuten eines Subgenres, am Ende eines Drops
  (Ambient: nach einem Break), ein verwandtes Subgenre – ein Tempo-Nachbar innerhalb ±8 BPM, das eigene Genre doppelt
  so wahrscheinlich –, über Break und Aufbau, das Tempo gleitet. Der Plan ist ein Ring von 24 Abschnitten: kein
  Speicherwachstum (geprüft über 60 simulierte Minuten).

## 7. MIDI OUT

Alles von Vizz 2.0 unverändert. Neu, nur solange der Produzent spielt und nur mit SEQ MIDI OUT ON, auf **Kanal 16**:
CC 104 Songteil (0 kein Song, 1 INTRO … 6 OUTRO), CC 105 Energie, CC 106 Takt im Abschnitt, CC 107 seine Länge, CC 108
Genre, CC 109 Subgenre. Alle sechs auf jeder Takt-Eins vor deren Noten (das deckt Abschnittsbeginn, Takt und
Resynchronisation ab), beim Start direkt nach `FA` und Vizz' CC 103, sofort beim Einschalten von SEQ MIDI OUT und wenn
USB wiederkommt; CC 105 dazwischen bei Änderung, höchstens einmal pro 1/16; beim Stopp CC 104 = 0, ebenso einmal beim
Wechsel in die GROOVEBOX. Spezifikation: `docs/VIZZBOX-MIDI.md`.

## 8. Name, Kennung, Installer

- **Name** überall, wo Vizz ihn hatte: Startbild „Vizzbox / v1.0 / on Skiff 2.0.1 / Hügelton + community“, ABOUT
  „VIZZBOX“ / „based on Vizz 2.0 / Skiff 2.0.1 / Felucca“, die Credits beginnen mit VIZZBOX (die von Vizz, Skiff und
  Felucca bleiben), das Absturzbild, der Update-Loader („WAITING FOR THE / VIZZBOX INSTALLER“; seine 5×7-Schrift bekam
  das X), der Name der Standardpalette unter THEME. **USB-Namen und -Deskriptoren unverändert.** Code-Bezeichner,
  Kommentare und Dateinamen bleiben Skiffs.
- **Version `v1.0`, Kennung `FM-1_850`** (Release X.Y ist `FM-1_8(X+4)Y`, Entwicklungs-Builds `FM-1_800` wie bei
  Vizz). Begründung: Die Installer von Vizz 2.0 und der Vizzbox erkennen an `FM-1_8XY` mit X ≥ 2 „Skiff 2.0 innen“ und
  installieren dann ohne Backup und Konvertierung, in beide Richtungen; X = 5 bleibt frei von Vizz' Nummern bis
  Vizz 4.x. Skiff 2.0.1s eigene Seite entscheidet nur nach der Version und hält die Vizzbox („v1.0“) für Firmware vor
  2.0: Sie sichert zuerst (harmlos) und lässt dann den Konverter laufen, der bei einem 2.0-Speicher nichts
  zurückschreibt (geprüft).
- **`vizzbox-installer.html`**: eine Datei wie bei Vizz 2.0, mit Skiffs ganzer 2.0-Logik (Backup und Konvertierung
  über Firmware vor 2.0 und über Vizz 1.x, Rückweg zur Original-Firmware V15) und den Worten der Vizzbox. Eine
  Änderung über Vizz' Seite hinaus war nötig: Skiffs Seite sichert nur, wenn das Paket nach seiner Version 2.0 oder
  neuer ist; die Vizzbox ist 1.0 mit Skiff 2.0 innen, sichert also nach den Regeln von 2.0 (der Test fand das).

## 9. Platz

Der App-Bereich der FM-1 hat **581 564 Bytes**. Gemessen am Release (`./build.sh --release 1.0`, mit zweitem Kern):

| | Vizz 2.0 | Vizzbox 1.0 | |
| --- | ---: | ---: | ---: |
| App im Flash | 553 052 | **575 904** | +22 852 |
| frei im App-Bereich | 28 512 | **5 660** | Reserve ≥ 2 KB ✓ |
| RAM `.data` + `.bss` | 79 924 | 79 924 | unverändert |
| dahinter `.vbox` | – | 4 300 | die gemerkte GROOVEBOX-Sitzung 2 560, der nächste Stil 1 740 |
| Pool | 346 500 | 347 092 | +592, Reserve 9 260 (Skiffs Prüfung verlangt 8 192) |
| RAM-Code + `.ramx` | 24 200 | 24 236 | von 24 576 |

Nach Datei (`tools/size_report.py`): `producer.c` 9 911, `producer_tables.c` 2 818, `producer_isr.c` 1 268,
`ui_vizzbox.c` 534 – dazu, weil der Compiler sie dort einbettet, rund 4 600 in `ui_input.c` (Bedienung, Bildschirm)
und 2 900 in `main.c` (der Takt des Produzenten in der Hauptschleife). Der Produzent wird wie Skiffs übrige
Hauptschleife auf Größe gebaut (`tools/size_fns.py`, das sparte 2 736 Bytes). **Gestrichen wurde nichts**; die Liste
der Kandidaten nach Abschnitt 7 des Auftrags war nicht nötig.

**Abweichung:** Der Entwicklungs-Build mit serieller Konsole (~7,4 KB) passt neben dem Produzenten nicht mehr (1 632
Bytes zu viel); `tools/build.py` lässt die Konsole deshalb auch im Entwicklungs-Build der FM-1 weg (`FELUCCA_CDC=1`
verlangt sie; der Release hat sie seit Skiff 2.0 ohnehin nicht).

## 10. Leistung und Budget

- **Zweiter Kern bleibt an.** Stimmenbudget 8 je Song.
- **Kostenmaß der Render-Schleifen** (`tests/target_budget.py`, statisch am Disassemblat): Ohne Konsole legt der
  Compiler den Audio-Interrupt anders an, dieselben ~1 390 Befehle in Schleifen liegen eine Ebene tiefer:
  `fm1_alnk0_irq` zählt bei **Vizz 2.0 selbst** ohne Konsole 24 542 (mit Konsole 7 598). Für Builds ohne Konsole gilt
  deshalb `tests/target_budget_cdc0.txt` – Vizz 2.0s eigenes Maß so gebaut –, Skiffs `target_budget.txt` bleibt für
  Builds mit Konsole. Die Vizzbox: `fm1_alnk0_irq` **24 543** (+1), der Interrupt für Tasten und LEDs
  (`fm1_timer5_irq`) **27 164** (gleich), alle Render-Funktionen im Budget; der Schritt des Produzenten im Interrupt
  (`vb_isr`) ist eine eigene Funktion von 932 Bytes, einmal je Audio-Block, ohne Schleife über Samples.
- **Messfall schwerster Drop** (`tests/vizzbox_budget.c`): der erste Drop jedes Subgenres bei ENERGIE und VARIATION
  100, drei Seeds (Formen ohne Drop: der erste Groove), CPU-Zeit für 8 s Audio gegen Skiffs „heavy song“ (drei
  POLY-Spuren mit Vierklängen über dem Budget von 8 Stimmen und Drums – der Fall, den Skiffs Emulator-Test gegen
  Echtzeit hält), jeder Kandidat Seite an Seite mit ihm gemessen (die CPU-Zeit dieses VM-Rechners schwankt). Im
  Abschlusslauf der schwerste: **DEEP DUBSTEP (Seed `7A11`, 140 BPM) mit 0,76 ×**; mit allen Effekten zugleich (alle
  Sends jeder Spur voll, REPEAT 1/32, GATE, DUB und FLANGE gehalten) **0,75 ×** des heavy song mit denselben Effekten.
  Über mehrere Läufe lag der schwerste Drop bei 0,6–0,8 ×, mit allen Effekten bei 0,65–0,75 ×; die Grenze des Tests
  ist 1,10 ×. In keinem Drop mehr als 8 Stimmen, keine gestohlen.
- Auf dem Computer gemessen, nicht auf dem Gerät: Abschnitt 15.

## 11. Tests

Der Abschlusslauf: `./build-vizzbox.sh` in einem frischen Arbeitsordner – Skiff neu geklont, `v2.0.1`, die Patches
0001–0013 mit `git am -3` (ohne Konflikt), Release, Konverter, `tests/vizz10_unit.json` aus Vizz 1.0 neu gebaut,
Entwicklungs-Build, alle Tests, die Installer, beide Gegenproben, die Demos. Der Container wurde dabei zweimal neu
gestartet; die Schritte nach `tests/run_tests.sh` liefen danach mit denselben Befehlen des Skripts im selben Ordner
weiter, die Demos zuletzt mit Patch 0014 (der nur die Zeitangaben in `demos/README.md` betrifft).

| Schritt | Ergebnis |
| --- | --- |
| Release `vizzbox-1.0.fwsc` aus dem frischen Klon | 610 445 Bytes, Kennung `FM-1_850` – **bytegleich** mit dem aus dem Arbeitsbaum |
| `tests/vizz10_unit.json` aus Vizz 1.0 neu gebaut | dieselben Bytes |
| `tests/run_tests.sh` (145 Schritte) | **`ALL HOST TESTS PASSED`**, 8 378 Einzelprüfungen „ok“, keine fehlgeschlagen |
| darin `producer_test` | 117 Fälle, **370 357 Prüfungen, 0 Fehler** |
| darin `seqmidi_test` (Vizz 2.0) | „seqmidi: all ok“ |
| darin die 176 Regressions-Renders | **0 geändert** (ein Kern, zweiter Kern als Thread, ohne zweiten Kern) |
| darin die UI-Goldens | 3 388 Bilder, 0 geändert; die VIZZBOX-Bildschirme (72) wie ihr Golden |
| darin GROOVEBOX mit/ohne Produzent | 7 Szenen bitgleich |
| darin Skiff 2.0.1 / Vizz 2.0 auf einem Gerät mit Favoriten | 20 Prüfungen ok |
| darin Fuzzer (ASan/UBSan) | Skiffs vier ohne Befund; Vizzbox 2 × 1 500 Aktionen, 0 Fehler |
| darin Kostenmaß (ohne Konsole) | `fm1_alnk0_irq` 24 543 (Budget 24 542), `fm1_timer5_irq` 27 164, alles im Budget |
| darin Budget-Messfall | 0,76 × / mit allen Effekten 0,75 × (Abschnitt 10) |
| darin Web, Backup, Konverter, Emulator | „web tests passed“, „backup web tests passed“, „converter (wasm) test passed“, „emu: all ok“, „install tests passed“ |
| Installer in Chromium | „vizz installer: all ok“, „vizzbox installer: all ok“ (auch auf `out/vizzbox-installer.html`) |
| die Vizzbox im Browser | „vizzbox emu: all ok“ |
| Gegenprobe Vizz 2.0 (`tests/vizz_mutants.py`) | **every fault caught** |
| Gegenprobe Vizzbox (`tests/vizzbox_mutants.py`) | **every fault caught** (22 + 2) |
| Demos | 36 × MP3 und MIDI, alle Prüfungen ohne Befund (Abschnitt 12) |

Übersprungen, wie bei Vizz 2.0: der PHYS-Vergleich mit DaisySP (keine DaisySP-Quellen) und die Loader-Tests mit
M-VAVEs Original-Paketen (V15/V016 liegen nicht bei).

Was geprüft wird, neu für die Vizzbox:

- **`tests/producer_test.c`** (117 Fälle, jeder auf einem frischen Gerät): jedes Subgenre in jeder LÄNGE (Form
  und Abschnittslängen, Tempo im Bereich, alle Noten in der Tonart, Register der Rollen, keine gestohlene Stimme; jeder
  Drop: CC 104 = 4 vor der Kick auf seiner Eins, davor Roll oder Riser; CC 104–109 auf Kanal 16, alle sechs auf jeder
  Eins vor den Noten, CC 105 höchstens einmal pro 1/16); Determinismus (derselbe Song zweimal und mit anderer
  Render-Blockgröße gleich, anderer Seed anders); PLAY/Stopp, SEQ MIDI OUT OFF und wieder ON, USB weg und wieder da,
  in die GROOVEBOX (einmal CC 104 = 0, auch wenn nie gespielt wurde); Regler während der Wiedergabe ab dem nächsten
  Abschnitt, DROP JETZT, BREAK JETZT, HALTEN; MUTE und SOLO als CC 103, nicht das Arrangement; ENDLOS 60 Minuten mit
  Subgenre-Wechseln und ohne Wachstum; Favoriten über ein Aus- und Einschalten, beim Spielen gespeichert erst im
  Stillstand geschrieben; **die Projekte des Nutzers:** Slot 1, Autosave und Pattern-Pool nach 70 s Produzent mit
  Stilwechsel byteweise gleich, nach dem Einschalten die GROOVEBOX mit der eigenen Musik; VIZZBOX ↔ GROOVEBOX, auch
  beim Spielen.
- **`tests/vizzbox_ui.c`:** die neuen Bildschirme in allen sechs Paletten gegen ihr Golden (72 Bilder).
- **UI-Goldens von Skiff, absichtlich geändert:** in allen Paletten (auch CUSTOM und LARGE) Startbild und ABOUT samt
  REC, Credits und Ende; in der Palette SKIFF dazu MENU, MENU LEDS und das MENU-Modell (THEME heißt VIZZBOX) – 76 von
  3 388 Bildern, sonst keins.
- **`tests/vizzbox_inactive.c`:** die GROOVEBOX mit eingebautem, aber inaktivem Produzenten gegen den Build ohne ihn
  (= Vizz 2.0): ein Song, weiße Tasten, Regler, MUTE, MIDI-Eingang, Stopp – Audio, USB-MIDI und Bildschirm
  **bitgleich**. Die 176 Regressions-Renders von Skiff 2.0.1 laufen ohnehin bitgleich (Skiffs DSP ist unberührt).
- **`tests/vizzbox_compat.c`:** eine Vizzbox mit Projekt und 16 Favoriten (beide Kopien geschrieben), darauf **Skiff
  2.0.1** und **Vizz 2.0** (ihre Bäume aus git, als Gerät gebaut): booten, laden, in einen zweiten Slot speichern,
  spielen, Autosave, eine Einstellung – die Favoriten-Sektoren byteweise unberührt; zurück auf der Vizzbox alle 16
  Favoriten und beide Slots da. `tests/ldr_test.c`: die Favoriten überstehen ein Update durch den Loader.
- **`tests/vizzbox_fuzz.c`** unter ASan/UBSan (2 × 1 500 Aktionen im Lauf; vorab 20 Seeds × 3 000 Aktionen
  optimiert): Regler, Tasten, Favoriten, Moduswechsel, MENU, MIDI-Eingang und Aus- und Einschalten zufällig; danach
  keine hängende Note, alle Stimmen frei, ein frisches Gerät spielt (mit Clock von außen, wo das MENU sie
  eingeschaltet hatte).
- **`tests/vizzbox_budget.c`**: Abschnitt 10.
- **`web/test_vizzbox_installer.mjs`** (Chromium): über Vizz 1.0, Vizz 1.x, Skiff 1.4 und einem Entwicklungs-Build
  Backup, Frage, Installation, Konvertierung; über Vizz 2.0, Skiff 2.0.1, Vizzbox 1.0 und einer späteren Vizzbox nur
  die Installation; Vizz 2.0s Installer über einer Vizzbox ebenso; Skiffs Seite über einer Vizzbox schreibt nichts
  zurück.
- **`web/emu/test_vizzbox_emu.mjs`** (Chromium): die Vizzbox im Browser, von der Festplatte geöffnet: einschalten,
  VIZZBOX-Bildschirm, Regler 1, PLAY (Bildschirm läuft, Audio nicht still), Stopp.
- **Gegenprobe `tests/vizzbox_mutants.py`:** 22 absichtliche Fehler in Produzent, Interrupt-Teil, Bildschirm und
  Autosave-Haken und 2 im Installer – Determinismus gebrochen (ein Song hängt von den vorigen ab; Seed ignoriert),
  CC 104–109 einen 1/16 zu spät, CC 104 nie, CC 104 = 0 fehlt beim Stopp und beim Wechsel, falscher Kanal, trotz SEQ
  MIDI OUT OFF, nicht neu bei SEQ MIDI OUT ON/USB, Interrupt-Teil in der GROOVEBOX aktiv, Drop ohne Kick, Aufbau ohne
  Roll und Riser, Noten neben der Tonart, Stimmenbudget aus, Arrangement über das Nutzer-MUTE, ENERGIE sofort statt
  ab dem nächsten Abschnitt, ENDLOS ohne Wechsel, Favorit nicht geschrieben, Favorit beim Spielen geschrieben,
  GROOVEBOX-Musik nicht zurück, Autosave speichert den Song des Produzenten, Taktzähler ab 0; Installer: Vizzbox nach
  der Version erkannt, kein Backup über Vizz 1.0 – **jeder wird erkannt**. `tests/vizz_mutants.py` (Vizz 2.0s
  Gegenprobe) erkennt weiter jeden seiner Fehler.

## 12. Demos

`demos/`: je Subgenre ein MP3 (128 kbit/s) von etwa 60 s über einen Aufbau in den Drop und die MIDI-Datei des ganzen
Songs (alle sechs Spuren, CC 102–109 wie über USB), Seed `5EED`, ENERGIE 70, VARIATION 40, NORMAL; `demos/README.md`
listet Genre, Subgenre, Seed, BPM, Tonart, Spitze, RMS und was am ganzen Song gemessen wurde: kein Clipping (Spitzen
der Songs höchstens −8 dBFS), 0 gestohlene Stimmen, 0 Noten außerhalb der Tonart, ein Riser in jedem Aufbau vor einem
Drop. Die Ausschnitte führen **über einen BUILD in den DROP** – außer wo die Form des Auftrags keinen BUILD oder
keinen Drop hat: Form V (DISCO HOUSE, SYNTHWAVE, ITALO DISCO, 2-STEP, BOOM BAP, LO-FI, TRAP, CHILL) ist „INTRO 4 –
GROOVE 16 – DROP 8 (als Hook) …“ ohne BUILD, ihr Ausschnitt führt aus dem GROOVE in den DROP; Form A (DUB TECHNO,
AMBIENT, DUB) hat keinen Drop, ihr Ausschnitt führt aus dem GROOVE in den BREAK. Dazu
`demos/vizzbox-im-browser.html`: die Vizzbox als eine Datei im Browser (dieselbe Firmware, in WebAssembly), Genre,
Subgenre, PLAY und alles andere bedienbar und hörbar.

## 13. Update-Anleitung

**Von Vizz 2.0 oder Skiff 2.0.1:** `out/vizzbox-installer.html` in Chrome oder Edge öffnen, die FM-1 per USB
anschließen, **Install**. Es wird nichts gesichert und nichts umgewandelt – Projekte, Sounds und Einstellungen bleiben;
die FM-1 startet in der VIZZBOX, HOME + PLAY führt in die gewohnte GROOVEBOX. **Zurück** genauso mit dem Installer von
Vizz 2.0 (ohne Backup) oder Skiffs Seite (die sichert vorher, weil sie „v1.0“ für alt hält, und schreibt danach nichts
zurück). Die Favoriten bleiben dabei im Flash liegen und sind nach einer erneuten Vizzbox-Installation wieder da.

**Von Vizz 1.x, Skiff 1.4 oder älter:** wie oben; der Installer speichert zuerst eine vollständige Sicherung
(`Vizzbox-backup-DATUM.json`), fragt, installiert und wandelt um, was 2.0 nicht lesen kann (die Liste steht danach
auf der Seite).

**Zur Original-Firmware:** über M-VAVEs Update-Programm (V15), wie bei Skiff; die Musik der Vizzbox liest die
Original-Firmware nicht.

Prüfsummen: `out/SHA256SUMS`.

## 14. Abweichungen vom Auftrag, zusammengefasst

1. **36 statt 37 Subgenres:** die Tabelle des Auftrags hat 36 (Abschnitt 3).
2. **LÄNGE auf ALGORITHM**, weil SELECT keinen Taster hat; **HOME + PLAY** statt HOME lang, weil das in Skiff das MENU
   ist (Abschnitt 4).
3. **„Song übernehmen“** (optional) nicht gebaut (Abschnitt 4).
4. **KURZ** wiederholt bei schnellen Tempi die Mitte, um auf die Länge zu kommen (Abschnitt 3).
5. **Entwicklungs-Build ohne serielle Konsole** und dafür ein **eigenes Kostenmaß-Budget** für Builds ohne Konsole
   (Abschnitte 9, 10).
6. **Der Installer** sichert nach den Regeln von 2.0, obwohl die Version 1.0 ist (Abschnitt 8).
7. **Budget-Messfall auf dem Computer** (CPU-Zeit gegen Skiffs heavy song) statt mit einem Befehlszähler: Dieser
   Linux-Rechner hat keine Hardware-Zähler (`perf_event_open`: nicht vorhanden), und Skiffs Zähler gibt es nur unter
   macOS (Abschnitt 10).

## 15. Nicht geprüft, bekannte Grenzen

- **Kein Test auf einer echten FM-1.** Alles läuft auf dem Computer mit Skiffs eigenen Quellen; der Ziel-Compiler baut
  das Paket, prüft Größe, RAM und das statische Kostenmaß. Ob der Audio-Interrupt auf dem Gerät im schwersten Drop
  Luft hat, ist aus dem Vergleich mit Skiffs heavy song geschlossen (0,6-fach), nicht auf dem Gerät gemessen. Vor
  einer Veröffentlichung sollte jemand mit einer FM-1 installieren, ein paar Subgenres bis in den Drop spielen,
  ENDLOS eine Weile laufen lassen, Favoriten über Aus/Ein prüfen und mit VIZZ CC 104–109 ansehen.
- **Die Demos sind gemessen, nicht gehört:** Pegel, Tonart, Abschnitte, Stille vor dem Drop, Riser – geprüft; ob sie
  musikalisch gefallen, muss ein Mensch beurteilen.
- Skiff 2.0.1s eigene Installer-Seite hält die Vizzbox für Firmware vor 2.0 und sichert unnötig (harmlos, Abschnitt 8).

## Verlauf

Nach jeder Etappe auf `vizzbox-1.0` gepusht: 1 Vizz 2.0 nachgebaut und Platz gemessen (`81f04c1`, `7698213`) –
2 Produzent (`f86ef34`) – 3 Tuning (`b47f0e4`) – 4 Bedienung, Favoriten, ENDLOS (`ade2c81`) – 5–6 Name, Kennung,
Installer, MIDI (`619987f`) – 7 Tests, `build-vizzbox.sh`, Anleitung (`544cf62`) – 8 Abschlusslauf, Release,
Demos (dieser Stand).
