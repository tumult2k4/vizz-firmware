# Vizzbox 1.0 – Änderungen gegenüber Skiff 2.0.1

> **Zwischenstand: Etappe 6 von 8** (BRIEF-VIZZBOX.md, Abschnitt 10). Vizz 2.0 ist nachgebaut und grün, der Platz im
> Flash ist gemessen, der Produzent spielt ganze Songs in allen 36 Subgenres (Patch 0007), ist über Messungen getunt
> (0008), hat seine Bedienung: VIZZBOX-Bildschirm, Regler und Tasten, 16 Favoriten, Stilwechsel während der
> Wiedergabe, ENDLOS (0009–0011), und heißt Vizzbox: Kennung `FM-1_850`, Paket `vizzbox-1.0.fwsc`, Installer
> `vizzbox-installer.html`, MIDI CC 104–109 beschrieben in `docs/VIZZBOX-MIDI.md` (0012). Noch nicht da: die
> restlichen Tests (Gegenprobe, Fuzzer, Lesetest alter Firmware, Budget-Messfall), die Demos, die Anleitung. Was steht,
> was getestet ist und was als Nächstes kommt: unten, „Stand“.

Vizzbox ist eine geänderte Fassung von Skiff 2.0.1 (illuminus5, <https://github.com/illuminus5/skiff>, GPL-3.0; Skiff
baut auf Felucca von Leo Kuroshita / Hügelton Instruments auf) und baut auf **Vizz 2.0** auf (Branch `vizz-2.0` dieses
Repos: Skiff `v2.0.1` + fünf Patches). Basis ist der Tag `v2.0.1` (`b03d98a`); die Änderungen sind die Commits in
`patches/` (`git format-patch v2.0.1..vizzbox-1.0`), anzuwenden mit `git am -3 patches/*.patch` auf einem Branch ab
`v2.0.1`.

| Patch | Inhalt |
| --- | --- |
| 0001–0005 | **Vizz 2.0**, unverändert von `origin/vizz-2.0` (SEQ MIDI OUT, CC 103, Name Vizz, Installer-Test, Gegenprobe) – siehe `CHANGES.md` dort |
| 0006 | `tools/size_report.py`: wohin der Flash geht, je Quelldatei und Symbol (Messwerkzeug für Abschnitt 7) |
| 0007 | **Der Produzent** (`producer.c`, `producer_isr.c`, `producer_tables.c`, erster `ui_vizzbox.c`), Haken in Skiffs Quellen, `tools/vizzbox_render.c`, die Sound-Messung (`tools/vizzbox_sounds.c`, `vizzbox_sounds.py`, `vizzbox_pick.py`) |
| 0008 | **Tuning über Messungen:** Songlängen je Tempo, Stille vor dem DROP, Riser geschützt, Pegel unter Skiffs Master-Limiter, Lautheit je Subgenre (`VB_TRIM`), `tools/vizzbox_demos.py`, `tools/vizzbox_level.py` |
| 0009 | **Bedienung:** VIZZBOX-Bildschirm und -Tasten (`ui_vizzbox.c`), 16 Favoriten in eigenen Sektoren, neuer Stil während der Wiedergabe (BREAK + BUILD, Klangwechsel in der Pause vor dem DROP), ENDLOS; `tests/producer_test.c`, `tests/vizzbox_ui.c` mit Golden |
| 0010 | `tools/build.py`: der Entwicklungs-Build der FM-1 ohne serielle Konsole (sie passt nicht mehr neben den Produzenten; `FELUCCA_CDC=1` holt sie zurück) |
| 0011 | `tests/target_budget_cdc0.txt`: das Kostenmaß eines Builds ohne Konsole gegen Vizz 2.0s eigenes, ebenso gebaut |
| 0012 | **Name und Kennung:** Vizzbox, `FM-1_850`, `vizzbox-1.0.fwsc`; `web/make_vizzbox_installer.py` und `web/test_vizzbox_installer.mjs`; CC 104–109 auch beim Einschalten von SEQ MIDI OUT und wenn USB wiederkommt geprüft |

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

4. **Der Produzent (Etappe 2, Patch 0007).** Gebaut wie im Plan unten; was er tut und wie, steht vorn in
   `firmware/src/producer.c`. Kurz:
   - Generatoren für DRUMS (Raster 16 Steps × 8 Lanes je Stil mit Ankern, Dichte nach Energie, Akzente, Fills am
     Phrasenende, Roll im BUILD 1/4 → 1/8 → 1/16 → Ratchets), BASS (14 Stile: ROOT, OFFBEAT, ROLLING, ACID, WOBBLE,
     SUB, REESE, OCTAVE, 808, synkopiert, Dub, Riff, Psy, Hard), CHORDS (Progressionen als Stufen, PAD/STAB/PLUCK/
     GATE/PIANO/SKANK, Stimmführung), LEAD (ein Motiv von 1–2 Takten je Song, Akkordtöne auf betonten Steps, kehrt
     wieder), ARP (Modi über den Akkord, oder ein Break über SLICE), FX (Riser über den BUILD, Impact und Downlifter
     am DROP, Atmo). Alles in Skalenstufen; die Tonart vom Seed und Subgenre aus einer genretypischen Auswahl.
   - Arrangement in Abschnitten (INTRO, GROOVE, BUILD, DROP, BREAK, OUTRO) nach den sieben Formen des Auftrags, mit
     Energiekurve; welche Rollen spielen, folgt aus Abschnitt und Energie; höchstens zwei dichte melodische Rollen.
     Übergänge mit Skiffs Mitteln: HPF-Fahrt (Techno: LPF zu) über den FX-Layer-FILTER, THROW, REPEAT/REVERSE im
     letzten Beat, TAPE STOP höchstens einmal, DUB-Throws, VINYL, Kick-Ausfall am BUILD-Ende, Crash auf der Eins.
   - Erzeugt wird jeder Takt in der Hauptschleife einen Takt im Voraus in `launch_q` (LOOP); der Audio-Interrupt
     wendet je 1/16 nur vorbereitete Werte an (`producer_isr.c`: Tempo, Filter, Throw, Effekt, Parameterfahrten,
     CC 104–109). Jede Rolle zieht aus einem eigenen Strom (Seed, Rolle, Abschnitt, Takt).
   - **Stimmenbudget 8** (auch mit zweitem Kern, der dann 4 Stimmen fürs Mitspielen frei hat): je Step des
     vorbereiteten Takts werden die klingenden Stimmen aus den gemessenen Ausklangzeiten der Sounds gezählt (Lanes,
     Mono-Rollen, Akkordnoten samt Ausklang, Swing-Verzögerung, Ratchets, was der Takt davor nachklingen lässt, Platz
     für Kick und Bass des nächsten Takts); zu viel wird in fester Reihenfolge weggenommen (Arp-Note, oberste
     Akkordnote, Percussion, FX, Lead, Akkord; im BUILD der Riser zuletzt).
   - Die GROOVEBOX-Musik wartet gepackt (SKF4) im RAM, in einem eigenen Abschnitt `.vbox` **hinter** `.bss` (app.ld):
     keine bestehende Variable verschiebt sich, der Pool behält seine 8 KiB Reserve (Skiffs Prüfung in `build.py`).
     Autosave, Pattern-Pool und SONG lassen die Spuren in Ruhe, solange der Produzent sie hat.
5. **Gemessen auf dem Host** (`tools/vizzbox_render`, Seed `5EED`, ENERGIE 70, VARIATION 40, NORMAL):
   - alle 36 Subgenres spielen einen ganzen Song durch: 4:17–7:10 min, Spitze −7,1 bis −10,4 dBFS (kein Clipping),
     RMS −18,7 bis −24,2 dBFS, **0 gestohlene Stimmen**;
   - **Stimmenbudget:** 936 Songs (36 Subgenres × 26 Kombinationen aus Seed, ENERGIE 0/30/60/100 und VARIATION
     0/40/100) – **0 gestohlene Stimmen** in allen Abschnitten;
   - **Determinismus:** derselbe Song zweimal und mit `-O1` statt `-O2` gebaut: WAV und MIDI-Datei bytegleich.
6. **Platz und RAM** (Release, `./build.sh --release 2.0`, noch mit Vizz' Namen und Kennung): App **569 028 Bytes**
   (+15 976 gegenüber Vizz 2.0), frei **12 536 Bytes**. Der Produzent wird wie Skiffs übrige Hauptschleife auf Größe
   gebaut (`tools/size_fns.py`; das sparte 2 736 Bytes). RAM `.data`+`.bss` **unverändert 79 924 Bytes**, dahinter
   `.vbox` 2 560 Bytes; Pool 346 860 Bytes (+360), Reserve 9 492 Bytes.
7. **Tests auf diesem Stand (Patch 0007):** `tests/run_tests.sh` im Entwicklungs-Build mit Emscripten:
   **`ALL HOST TESTS PASSED`**, „vizz installer: all ok“. Die Host-Tests bauen Skiffs Quellen ohne den Produzenten
   (`VIZZBOX` 0, wie Vizz 2.0): die 176 Regressions-Renders und die UI-Goldens prüfen damit die GROOVEBOX mit den
   Haken. Ein Regressionslauf **mit** einkompiliertem, aber inaktivem Produzenten kommt mit den Tests (Etappe 7).

8. **Tuning (Etappe 3, Patch 0008)** – alles gemessen mit `tools/vizzbox_demos.py` (rendert jedes Subgenre, schneidet
   ~60 s über einen BUILD in den DROP heraus, prüft Abschnitt 8 des Auftrags am ganzen Song) und `vizzbox_level.py`:
   - **Songlängen:** der Plan passt die Form an das Tempo des Songs an (NORMAL 4:45–6:10, KURZ 2:30–3:35: die Mitte
     noch einmal, solange zu kurz; die längste ruhige Strecke halbiert, solange zu lang; Ambient ohne DROP wiederholt
     BREAK–GROOVE). Gemessen über 36 Subgenres × 6 Seeds: NORMAL **4:32–6:09**, KURZ **2:22–3:42**. Abweichung vom
     Auftrag: KURZ wiederholt bei schnellen Tempi die Mitte (DnB mit halbierten Abschnitten käme sonst auf 1:50).
   - **Der DROP:** der letzte Beat des BUILD wird still, wo das Subgenre es hat (`VF_SIL`), sonst mit
     35 % + VARIATION/2 Wahrscheinlichkeit: alle Spuren enden, der FILTER des FX-Layers nimmt, was nachklingt
     (gemessen: −18 bis −36 dB gegenüber den vier Takten davor). Der Riser im BUILD geht im Stimmenbudget als Letztes;
     ein gehaltener Akkord, Riser oder Atmo-Ton kommt einen Beat später, statt zu entfallen (vorher fehlte der Riser
     in 9 Subgenres). Die HPF-Fahrt des BUILD geht weiter hinauf (40–90 statt 25–70).
   - **Der Mix:** gemessen lief jeder Drop 3–9 dB tief in Skiffs Master-Limiter (`fx.c`, Schwelle −5,2 dBFS; Acid
     House im Mittel 8,7 dB), weil die Rollen nach RMS eingepegelt waren und die Drum-Kits 15–19 dB Crest haben. Jetzt:
     jede Rolle 7 dB (Drums 10 dB) leiser im Mix, jeder Sound mit seiner gemessenen Spitze gedeckelt; der Limiter
     regelt im Drop im Mittel **0,1–2 dB**.
   - **Lautheit:** `VB_TRIM` je Subgenre (aus drei Seeds gemessen, höchstens +4 dB): die 36 Demo-Ausschnitte (Seed
     `5EED`) liegen bei RMS **−25,5 bis −20,3 dBFS** (Median −22,1), Spitzen −11,1 bis −8,1 dBFS – innerhalb ±3 dB
     (Spanne 5,2 dB).
   - `tools/vizzbox_render`: das Booten stand vorher im WAV (das Audio lief 0,6 s hinter der MIDI-Datei); jetzt nicht
     mehr. Es gibt Tonart (Skalenmaske) und die sechs Sounds aus.
   - **Geprüft:** Stimmenbudget 936 Songs, **0 gestohlene Stimmen**; keine Note außerhalb der Tonart (alle 36);
     Flash **569 748 Bytes** (+720), frei 11 816; `tests/run_tests.sh` auf Patch 0008: **`ALL HOST TESTS PASSED`**
     (8 322 Einzelprüfungen, 176 Regressions-Renders 0 geändert, „vizz installer: all ok“).

9. **Bedienung (Etappe 4, Patches 0009–0011).** Belegung im VIZZBOX-Modus (steht auch vorn in
   `firmware/src/ui_vizzbox.c`):

   | Bedienelement | Funktion |
   | --- | --- |
   | Regler 1 / 2 / 3 / 4 | GENRE / SUBGENRE / ENERGIE / VARIATION |
   | SELECT drehen | TEMPO (1 BPM; mit externer Clock ohne Wirkung, Anzeige „EXT“) |
   | ALGO drehen | LÄNGE: KURZ / NORMAL / ENDLOS (Abweichung: SELECT hat keinen Taster, siehe „Plan“) |
   | PRESET drehen | der Seed (4 Hex-Stellen) |
   | PLAY | Start / Stopp |
   | REC | NEU: ein neuer Seed (gestoppt: ein neuer Song; beim Spielen ab dem nächsten Abschnitt) |
   | HOME + PLAY | in die GROOVEBOX; dort HOME + PLAY zurück (Abweichung: HOME lang halten öffnet in Skiff schon das MENU) |
   | FX / ARP / SEQ | DROP JETZT (BUILD von 4 Takten, nach BREAK/INTRO 8, dann DROP) / BREAK JETZT (BREAK 8, BUILD 8, DROP) / HALTEN (der Abschnitt wiederholt sich, bis erneut gedrückt) |
   | OCT− / OCT+ | Oktave der weißen Tasten |
   | schwarze Tasten | T1–T6 MUTE (tippen), stumm solange gehalten (halten), mit GLO SOLO – Skiffs GLO-Ebene, CC 103 meldet sie |
   | weiße Tasten | der Sound der LEAD-Spur, auf die Skala des Songs eingerastet (Skiffs QNT WHITE) |
   | SAVE + weiße Taste / GLO + weiße Taste | Favorit 1–16 speichern / laden (die weiße Taste klingt dabei nicht) |

   - **Bildschirm:** Genre, Subgenre, Tempo (EXT), Tonart, Seed, Länge, Abschnitt mit Taktzähler (`BUILD 12/16`), die
     Energiekurve des ganzen Songs mit Playhead, die sechs Spuren (spielt / stumm / solo), beim Drehen groß der Wert
     des Reglers, die Favoritenliste bei gehaltenem SAVE/GLO; eigene LEDs. Gezeichnet mit Skiffs Mitteln in allen
     sechs Paletten.
   - **Favoriten:** 16, je 8 Bytes (Genre, Subgenre, Seed, Energie, Variation, Länge, Tempo), in zwei eigenen Sektoren
     A/B bei `0x95000`/`0x96000` (zwischen App-Bereich und Skiffs Speicher; `fm1_flash_map.h` `FL_VBOX`): Skiff 2.0.1,
     Vizz 2.0 und der Update-Loader lesen, schreiben und löschen dort nichts (der Loader löscht nur Sektoren mit
     seinem eigenen Datensatz). Datensatz `VBF1` mit Folgenummer und CRC, abwechselnd A/B, also übersteht er einen
     Stromausfall beim Schreiben. Geschrieben wird erst im Stillstand (ein Löschvorgang hält den Flash an und damit
     das Audio). Ein Favorit spielt denselben Song bitgleich.
   - **Neuer Stil während der Wiedergabe** (GENRE, SUBGENRE, Seed oder ein Favorit; ENDLOS): wie ein DJ – ein BREAK
     von 8 und ein BUILD von 16 Takten, das Tempo gleitet darüber, dann der Song des neuen Stils ab seinem ersten DROP,
     in derselben Tonart (ENDLOS darf die Skala wechseln). Die Klänge des neuen Stils kommen im stillen letzten Beat des
     BUILD auf die Spuren: in der Hauptschleife vorbereitet (`vb_nx`, im `.vbox`-Abschnitt), im Audio-Interrupt in
     einem Schritt gesetzt, alle Stimmen dort beendet – so bleibt ein Song bitgleich. ENERGIE, VARIATION und LÄNGE
     wirken ab dem nächsten Abschnitt, TEMPO gleitet über vier Takte.
   - **ENDLOS:** nach 4–8 Minuten eines Subgenres, am Ende eines DROP (Ambient: nach einem BREAK) ein verwandtes
     Subgenre (Tempo-Nachbar innerhalb ±8 BPM, das eigene Genre doppelt gewichtet), das Tempo gleitet über den BUILD.
     Der Plan ist ein Ring von 24 Abschnitten: kein Speicherwachstum.
   - **Die Musik des Nutzers:** Beim ersten PLAY merkt sich der Produzent die GROOVEBOX-Sitzung gepackt im RAM; in die
     GROOVEBOX zurück (im Stillstand) ist sie wieder da. Autosave, Pattern-Pool und SONG schreiben nichts, solange er
     die Spuren hat; gespeicherte Projekte fasst er nie an.
   - **Abweichung, Konsole:** Mit dem Produzenten passt der Entwicklungs-Build mit serieller Konsole (~7,4 KB) nicht
     mehr in den App-Bereich (1 632 Bytes zu viel); `tools/build.py` lässt sie deshalb auch im Entwicklungs-Build der
     FM-1 weg (der Release hat sie seit Skiff 2.0 ohnehin nicht; `FELUCCA_CDC=1` verlangt sie).
   - **Abweichung, Kostenmaß:** `tests/target_budget.py` misst statisch die Befehle in den Schleifen der
     Render-Funktionen. Ohne Konsole legt der Compiler den Audio-Interrupt anders an: Dieselben ~1 390 Befehle in
     Schleifen liegen eine Ebene tiefer verschachtelt, `fm1_alnk0_irq` zählt **24 542 bei Vizz 2.0 selbst** (ohne
     Konsole gebaut) gegen 7 598 mit ihr. Skiffs `tests/target_budget.txt` gilt für Builds mit Konsole und bleibt
     unverändert; für Builds ohne Konsole ist `tests/target_budget_cdc0.txt` Vizz 2.0s eigenes Maß (Patch 0005,
     `FELUCCA_CDC=0 ./build.sh`), `tests/run_tests.sh` wählt danach. Die Vizzbox: `fm1_alnk0_irq` **24 543** (+1),
     `fm1_timer5_irq` 27 164 (gleich), alle Render-Funktionen im Budget.
10. **Tests auf diesem Stand (Patches 0009–0011)**, Entwicklungs-Build mit Emscripten (`tests/run_tests.sh`, 134
    Schritte):
    - `tests/producer_test.c`, neu: 115 Fälle, je ein frisches Gerät (fork): jedes Subgenre in jeder LÄNGE (Form,
      Abschnittslängen, Tempo im Bereich, Noten in der Tonart, Register der Rollen, 0 gestohlene Stimmen, jeder DROP:
      CC 104 = 4 vor der Kick auf seiner Eins, davor Roll oder Riser; CC 104–109 auf Kanal 16, alle sechs auf jeder
      Eins vor den Noten, CC 105 höchstens einmal pro 16tel), Determinismus (derselbe Song zweimal und mit anderer
      Render-Blockgröße: gleiche MIDI-Bytes und gleiches Audio; anderer Seed: anderer Song), PLAY/Stopp, SEQ MIDI OUT
      OFF, die GROOVEBOX, Regler während der Wiedergabe, DROP JETZT/BREAK JETZT/HALTEN, MUTE und SOLO als CC 103
      (nicht das Arrangement), ENDLOS 60 simulierte Minuten mit Subgenre-Wechseln, Favoriten über einen simulierten
      Neustart, VIZZBOX ↔ GROOVEBOX auch während der Wiedergabe: **370 344 Prüfungen, 0 Fehler**.
    - `tests/vizzbox_ui.c`: die neuen Bildschirme (bereit, Regler groß, spielend, MUTE, Favoriten speichern/laden,
      gestoppt, GROOVEBOX) in allen sechs Paletten gegen `tests/vizzbox_ui_golden.txt` (72 Bilder), von Hand
      angesehen.
    - Alle übrigen Schritte grün wie zuvor: 176 Regressions-Renders 0 geändert (auch mit zweitem Kern und ohne ihn),
      UI-Goldens 3 388 Bilder 0 geändert, `seqmidi_test` „all ok“, Fuzzer, „vizz installer: all ok“. Der eine rote
      Schritt des Laufs war das Kostenmaß (oben, „Abweichung, Kostenmaß“); mit Patch 0011 besteht es auf demselben
      Build.
    - Flash (Entwicklungs-Build, noch mit Vizz' Namen): App **575 748 Bytes**, frei **5 816**. RAM `.data`+`.bss`
      unverändert 79 924 Bytes, dahinter `.vbox` 4 300 (die gemerkte GROOVEBOX-Sitzung 2 560, der nächste Stil
      1 740): zusammen 84 224 von 98 304. Pool 347 092 von 356 352 (Reserve 9 260).

11. **Name, Kennung, Installer, MIDI (Etappe 5–6, Patch 0012).**
    - **Name** überall, wo Vizz ihn hatte: Startbild „Vizzbox / v1.0 / on Skiff 2.0.1 / Hügelton + community“, ABOUT
      „VIZZBOX“ und „based on Vizz 2.0 / Skiff 2.0.1 / Felucca“, die Credits beginnen mit VIZZBOX (alle von Vizz,
      Skiff und Felucca bleiben, ebenso alle Lizenzen), das Absturzbild („VIZZBOX CRASH“), der Update-Loader („WAITING
      FOR THE / VIZZBOX INSTALLER“; seine 5×7-Schrift bekommt das X, B und O hatte sie), der Name der Standardpalette
      unter THEME. **USB-Namen und -Deskriptoren unverändert.** Code-Bezeichner, Kommentare und Dateinamen bleiben
      Skiffs; was der Produzent mitbringt, steht in eigenen Dateien.
    - **Version `v1.0`, Kennung `FM-1_850`.** Release X.Y ist `FM-1_8(X+4)Y` (`tools/build.py`), Entwicklungs-Builds
      `FM-1_800` wie bei Vizz. Begründung: Die Installer von Vizz 2.0 und der Vizzbox erkennen an `FM-1_8XY` mit X ≥ 2
      „Skiff 2.0 innen“ und installieren dann ohne Backup und Konvertierung; X = 5 bleibt frei von Vizz' eigenen
      Nummern (2.x, später 3.x, 4.x) und lässt Vizzbox-Versionen bis 5.9. Paket `vizzbox-1.0.fwsc`
      (610 445 Bytes), App **575 904 Bytes**, frei **5 660** (≥ 2 KB Reserve).
    - **Was die Versionskennung „v1.0“ bei fremden Seiten auslöst, geprüft:** Skiff 2.0.1s eigene Seite entscheidet
      nur nach der Version und hält eine Vizzbox deshalb für Firmware vor 2.0: Sie sichert zuerst (harmlos) und lässt
      nach der Installation den Konverter laufen. Der schreibt bei einem 2.0-Speicher nichts zurück (geprüft: Vizz 1.0s
      Gerät einmal konvertiert und dann noch einmal – nichts zurückzuschreiben, nichts geändert). Die Seiten von Vizz
      2.0 und der Vizzbox gehen nach der Kennung.
    - **`vizzbox-installer.html`** (`web/make_vizzbox_installer.py`): eine Datei wie bei Vizz 2.0, mit Skiffs ganzer
      2.0-Logik und den Worten der Vizzbox. Eine Änderung über Vizz' Seite hinaus war nötig: Skiffs Seite sichert nur,
      wenn das, was sie installiert, nach seiner Version 2.0 oder neuer ist; die Vizzbox ist 1.0 mit Skiff 2.0 innen,
      also sichert sie immer nach den Regeln von 2.0. Ohne das blieb das Backup über Vizz 1.0 aus (der Test fand es).
    - **`web/test_vizzbox_installer.mjs`** (in Chromium, im Lauf von `tests/run_tests.sh`): über Vizz 1.0, Vizz 1.x,
      Skiff 1.4 und einem Entwicklungs-Build zuerst das ganze Backup (`Vizzbox-backup-DATUM.json`), die Frage, die
      Installation, die Konvertierung; über Vizz 2.0, Skiff 2.0.1, Vizzbox 1.0 und einer späteren Vizzbox nur die
      Installation; **Vizz 2.0s Installer über einer Vizzbox ebenso nur die Installation**; Skiffs eigene Seite über
      einer Vizzbox schreibt nichts zurück: **18 Prüfungen, „vizzbox installer: all ok“**.
    - **MIDI CC 104–109:** Spezifikation für die Empfängerseite in `docs/VIZZBOX-MIDI.md`. `tests/producer_test.c`
      prüft jetzt auch: alle sechs sofort, wenn SEQ MIDI OUT während der Wiedergabe eingeschaltet wird und wenn USB
      wiederkommt; beim Wechsel in die GROOVEBOX genau einmal CC 104 = 0.
    - **UI-Goldens, absichtlich geändert:** in allen Paletten (auch CUSTOM und LARGE) das Startbild und ABOUT samt
      REC, Credits und Ende; in der Palette SKIFF dazu MENU, MENU LEDS und das MENU-Modell, deren THEME-Zeile jetzt
      VIZZBOX heißt – 76 von 3 388 Bildern. Die übrigen Tests, die den Namen nennen (`ui_render.c`, `ui_test.c`,
      `editor_test.c`, `web/test_web.mjs`), folgen ihm.
12. **Tests auf diesem Stand (Patch 0012):** Release `--release 1.0`, Konverter, Entwicklungs-Build, dann
    `tests/run_tests.sh` (136 Schritte): **`ALL HOST TESTS PASSED`**, 8 346 Einzelprüfungen „ok“ – darunter
    `producer_test` 115 Fälle mit **370 347 Prüfungen, 0 Fehler**, `seqmidi: all ok`, die **176 Regressions-Renders
    0 geändert** (auch mit zweitem Kern und ohne ihn), UI-Goldens 3 388 Bilder 0 geändert, die VIZZBOX-Bildschirme
    (72), das Kostenmaß ohne Konsole (`fm1_alnk0_irq` 24 543 bei Budget 24 542), „vizz installer: all ok“,
    „vizzbox installer: all ok“.

### Als Nächstes

- Etappe 7 (läuft): `tests/vizzbox_mutants.py` (Gegenprobe, die Vizz-Mutanten weiter erkannt), Fuzzer für die
  VIZZBOX-Bedienung unter ASan/UBSan, Lesetest von Vizz 2.0 und Skiff 2.0.1 auf einem Gerät mit Favoriten (und die
  Favoriten über ein Update), Budget-Messfall im schwersten Drop, GROOVEBOX mit eingebautem, aber inaktivem
  Produzenten bitgleich zu Vizz 2.0.
- Etappe 8: Release, Demos (MP3 und MIDI je Subgenre, `demos/README.md`), Anleitung `docs/VIZZBOX-ANLEITUNG.md`,
  `build-vizzbox.sh` für die Vizzbox, endgültiges `CHANGES.md`.

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
