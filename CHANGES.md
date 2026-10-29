# Vizzbox 1.1 – Änderungen gegenüber Skiff 2.0.1

> **Stand: Etappe 4 von 8** (BRIEF-VIZZBOX-1.1.md, Abschnitt 10). Die Vizzbox 1.0 ist bytegleich nachgebaut, das Golden
> ihrer Songs steht; „Hand drauf“ (Abschnitt 2 des Auftrags), die Seiten KLANG und MOD, Fokus-Spur, Tasten, die
> Layer FX, ARP (PERFORM) und GLO (Busse), MOMENTARY, Zurückgeben, Bildschirm und LEDs (Abschnitt 3.1–3.8) sind
> gebaut und getestet, alle Tests grün. Es fehlen noch: Favoriten mit Klängen (3.9), das Budget mit den Klängen des
> Nutzers, neue Subgenres, Name/Kennung/Installer, Release, Demos, Emulator, Anleitung; das Paket in `out/` ist bis
> Etappe 8 das der 1.0.

Die Vizzbox ist eine geänderte Fassung von **Skiff 2.0.1** (illuminus5, <https://github.com/illuminus5/skiff>,
GPL-3.0; Skiff baut auf **Felucca** von Leo Kuroshita / Hügelton Instruments auf) und baut auf **Vizz 2.0** auf. Die
Vizzbox 1.0 (Branch `vizzbox-1.0`, ihre `CHANGES.md` dort) macht die Musik selbst: ein Produzent erzeugt aus Genre,
Subgenre, Seed, Energie und Variation ganze Tracks. Die **Vizzbox 1.1** (dieser Branch) bringt Live-Kontrolle über
die Tracks, die der Produzent gerade spielt – Klänge wechseln, Filter und Modulatoren drehen, Effekte, mitspielen –
und, wenn Platz bleibt, weitere Genres.

Basis ist der Tag `v2.0.1` (`b03d98a`); die Änderungen sind die Commits in `patches/`
(`git format-patch v2.0.1..vizzbox-1.1`), anzuwenden mit `git am -3 patches/*.patch` auf einem Branch ab `v2.0.1`.

| Patch | Inhalt |
| --- | --- |
| 0001–0014 | **Vizzbox 1.0**, unverändert von `origin/vizzbox-1.0` (darin 0001–0005 Vizz 2.0) – siehe `CHANGES.md` dort |
| 0015 | `tests/vizzbox_golden.c`, `tests/vizzbox_golden10.txt`: das Golden der Songs aus 1.0 (Abschnitt 2) |
| 0016 | **Hand drauf**: was der Nutzer auf den Spuren des Produzenten anfasst, bleibt seins (Abschnitt 4) |
| 0017 | Platz: QUARKs eigene Optik (Zierwerk des Themes) weggelassen, die Palette bleibt (Abschnitt 3) |
| 0018 | **Bedienung**: Seiten KLANG und MOD, Fokus-Spur, Tasten, Layer, Busse, Bildschirm (Abschnitt 5) |
| 0019 | LEDs der Seiten, Layer und Fokus-Spur; HOME + FX hält den FX-Layer offen (Abschnitt 5) |

---

## 1. Der Nachbau der 1.0

Skiff frisch geklont (`https://github.com/illuminus5/skiff.git`), Branch `vizzbox-1.1` ab `v2.0.1`, die 14 Patches von
`origin/vizzbox-1.0` mit `git am -3`: ohne Konflikt. Werkzeuge wie in 1.0: JieLis Linux-Toolchain
(`tools/get_toolchain.sh`, heute `jieli-linux-toolchains-20260730.1`), das AC79-SDK (`AC79NN_SDK_V1.2.1_2023-12-13`),
Emscripten 6.0.13, Python 3.13 mit Pillow und fontTools.

- **Release `./build.sh --release 1.0`**: `vizzbox-1.0.fwsc`, 610 445 Bytes, Kennung `FM-1_850`, App 575 904 Bytes.
  Mit dem Datum des 1.0-Builds gebaut (`faketime '2026-10-28 12:00'`) **bytegleich**:
  sha256 `4f8e101688740a021443fcfc1a3d5471a0fdad1e8e6d3ac9f329ef833d66ef19` wie `out/vizzbox-1.0.fwsc`.
- **Ohne das Datum** unterscheiden sich 15 Bytes: Skiffs ABOUT-Seite zeigt das Build-Datum (`ui_menu.c`, `__DATE__`),
  „Oct 29 2026“ statt „Oct 28 2026“ ist ein Bit in der App, der Rest sind die Prüfsummen des Pakets darüber. Für
  die 1.1 wird das Datum deshalb festgelegt (`SOURCE_DATE_EPOCH`, Etappe 8), damit ihr Paket nachbaubar ist.
- **Alle Tests der 1.0** (`./build.sh`, dann `tests/run_tests.sh`): siehe Abschnitt 4.

## 2. Das Golden der Songs aus 1.0

`tests/vizzbox_golden.c` (Patch 0015): jedes der 36 Subgenres mit drei Seeds – `5EED` mit Energie 70 / Variation 40,
`0B0B` mit 100 / 90, `C0DE` mit 25 / 10, je um das Subgenre verschoben – in jeder LÄNGE (KURZ und NORMAL bis zu ihrem
Ende, ENDLOS 180 s), dazu zweimal 10 Minuten ENDLOS (DEEP HOUSE und LIQUID, mit Subgenre-Wechsel): 326 Songs. Für
jeden zwei Hashes: alles, was die FM-1 über USB-MIDI sendet (jedes Byte, auch die Clock, mit dem Sample, zu dem es
hinausging) und das Audio. `tests/vizzbox_golden10.txt` ist mit dieser Datei **gegen den Baum der 1.0** gebaut
(Patches 0001–0014); `tests/run_tests.sh` vergleicht von jetzt an jeden Build damit. Zweimal gerechnet: dieselben
Hashes (deterministisch, auch bei vier Songs gleichzeitig).

## 3. Platz: Ausgangslage und Plan

Gemessen am Release 1.0 (`tools/size_report.py`): App 575 904 Bytes, App-Bereich 581 564 Bytes, **5 660 frei**; RAM
`.data` + `.bss` 84 224 von 98 304 Bytes (14 080 frei), Pool 347 092 von 356 352 (Skiffs Prüfung verlangt 8 192
Reserve: 1 068 frei). Die Reserve von 2 KB bleibt, für Neues also 3 612 Bytes, bevor etwas schrumpft.

Der Plan, woher der Platz kommt, in der Reihenfolge des Auftrags, und was er ergab:

1. **Skiffs Code statt eigenem** – umgesetzt: KLANG und MOD sind Skiffs eigene Seiten (EDIT-, ENV-, FX-, LFO-Familie,
   MIXER) mit ihren Karten, Grafiken und Knöpfen; FX, ARP und GLO halten öffnen Skiffs Layer; MOMENTARY, RETURN,
   Throws, Lock und der Preset-Browser sind Skiffs. Neu ist nur die Weiche (welche Seite, welche Taste wohin) und die
   Regeln von „Hand drauf“.
2. **Den eigenen Code verkleinern** – gemessen, ohne Gewinn: Die rund 4,6 KB in `ui_input.c` und 2,9 KB in `main.c`
   sind Funktionen des Produzenten und der VIZZBOX, die der Compiler dort einbettet, weil sie nur einmal aufgerufen
   werden. `noinline` auf allen macht die App **3 552 Bytes größer**, auf den drei, die von mehreren Stellen kommen
   (`vb_page`, `vb_seq_note`, `vb_grab_snd`, dazu `vb_back`), **48 Bytes größer** – das Einbetten spart hier. Die
   Hauptschleife ist schon auf Größe gebaut (`tools/size_fns.py`).
3. **In der GROOVEBOX, was eine FM-1 nicht braucht** – nichts zu holen: Der FM-1-Build enthält weder SMK-37-Code noch
   Entwicklungs-, Debug- oder Demo-Pfade (Skiff baut sie schon heraus; geprüft an den Symbolen des Release).
4. **Nur für A**: Teil A (Hand drauf, Seiten, Fokus, Tasten, Layer, Bildschirm) braucht mehr, als über der Reserve
   frei war (3 612 Bytes; gebraucht 1 664 + 3 100, dazu das Budget aus Etappe 6). Einzeln gemessen am Release:

   | Kandidat | spart | Was fehlt |
   | --- | ---: | --- |
   | LARGE-Anzeige | 3 548 | die großen Werte zum Ablesen auf Abstand – eine Funktion |
   | QUARKs eigene Optik | 6 684 | Zierwerk: Zellen mit Klammerecken, gepunktete Linien, Kerne, Teilchenspuren, Kollisionen |
   | NEONs eigene Optik | 7 796 | Zierwerk und Pixel-Schrift des Themes |
   | CRYPTs eigene Optik | 7 872 | Zierwerk (Steine, Schwerter, Schädel, Fackeln) und Pixel-Schrift |

   **Entscheidung: QUARKs eigene Optik** (Patch 0017). Ein Theme-Zierwerk betrifft nur das Aussehen, die LARGE-Anzeige
   ist eine Funktion; von den drei Zierwerken ist QUARKs das kleinste, das reicht. Die **QUARK-Palette bleibt** (ihre
   Farben, gezeichnet wie SKIFFs BLOCKS), CRYPT und NEON behalten alles, LARGE und die Hilfetexte der SHIFT-Karte
   bleiben. Ein Build-Schalter (`FELUCCA_QUARK_UI=1`) baut es wieder wie in Skiff. (Ein erster Zwischenstand nahm
   CRYPTs Optik; geändert, weil QUARKs kleiner ist und genügt – nichts davon war gepusht.)

**Gemessen je Etappe** (Release, `./build.sh --release`, App-Bereich 581 564 Bytes):

| Stand | App | frei | Änderung |
| --- | ---: | ---: | ---: |
| Vizzbox 1.0 | 575 904 | 5 660 | |
| Etappe 2: Hand drauf | 577 568 | 3 996 | +1 664 |
| QUARKs Optik weg (0017) | 570 884 | 10 680 | −6 684 |
| Etappe 3: Seiten, Fokus, Tasten, Layer, Busse, Bildschirm | 573 984 | 7 580 | +3 100 |
| Etappe 4: LEDs, Lock | 573 984 | 7 580 | ±0 |

RAM `.data` + `.bss` 87 036 von 98 304 Bytes, Pool 347 120 von 356 352 (Reserve 9 232, Skiff verlangt 8 192).

Der Flash zwischen App-Bereich (`0x93000`) und den Favoriten (`0x95000`) bleibt liegen: Der Update-Loader schreibt
nur den App-Bereich, sein Paketformat hat eine feste App-Größe, und Skiffs Flash-Karte hat dort keinen Eintrag – das
ohne Risiko zu erweitern, ließe sich ohne Gerät nicht beweisen.

## 4. Hand drauf (Etappe 2)

Was der Nutzer auf den Spuren des Produzenten anfasst, gehört ihm, bis er es zurückgibt. Der Produzent komponiert
weiter (Noten, Arrangement, Übergänge) und lässt genau das in Ruhe. Gebaut als Weiche in Skiffs eigenen Wegen, nicht
als Kopie: ein Bit je Spur für den Klang, ein Bit je Spur und Parameter (143 Parameter), ein Bit je globalem Wert
(`vb_hand`, 116 Bytes im RAM).

- **Woher es kommt, ist egal.** Ein Klang zählt als gewählt bei jedem Laden, das Skiff als Klang-Laden kennt
  (`ui.c load_begin` mit `UNDO_SOUND`): PRESETS, USER, der EDIT-Layer, eine MIDI Program Change, der Web-Editor, ein
  Undo; dazu jede Änderung auf den Blättern von FM6 und DRUM-X (der Patch, das Kit). Ein Parameter zählt als gedreht,
  wo Skiff einen Knopfdreh aufzeichnen würde (`motion.c motion_capture`): jeder Regler in der VIZZBOX und in der
  GROOVEBOX, der Web-Editor, ein MIDI-CC über Skiffs CC-Zuordnung oder MIDI LEARN. Ein Bus (Hall, Delay, Chorus,
  Swing) zählt, wenn er auf einer Seite gedreht wird (`edit_param`).
- **Ein gewählter Klang** bleibt über Takt, Abschnitt, einen neuen Stil, einen Favoriten, den Wechsel in ENDLOS und
  STOPP/PLAY (`vb_sound`, `vb_swap`). Gesetzt wird auf seiner Spur nur noch die Tonart des Songs (für die Tasten).
- **Ein gedrehter Parameter**: Der Produzent fährt ihn nicht mehr (`vb_isr` lässt die Fahrt aus), ein neuer Stil
  überschreibt ihn nicht. Seine anderen Fahrten (etwa der Pegel des Risers auf der FX-Spur) laufen weiter.
- **Performance-Steuerungen**: Solange der Nutzer den FILTER oder THROW des FX-Layers hält (oder ein MOMENTARY-Wert,
  ein Throw auf demselben Parameter), wartet die Fahrt des Produzenten. Lässt er los und ist der Wert über Skiffs
  RETURN zurück, gleitet der Produzent von dort in einem Beat zu seinem Wert (`vb_glide`, kein Sprung: gemessen
  höchstens 12 Schritte des FILTERS je 20 ms, ohne Gleiten 34 auf einmal). Hält der Nutzer einen Effekt des
  FX-Layers, setzt der Produzent keinen eigenen.
- **Zurückgeben**: HOME + schwarze Taste gibt diese Spur zurück (Klang und Parameter so, wie der Produzent sie jetzt
  hätte; nur Parameter: ohne neuen Klang, also ohne Abriss), HOME + EDIT alle Spuren und die Busse.
- **Wie lange**: über STOPP und PLAY hinweg, auch über einen Besuch in der GROOVEBOX im Stillstand (dort ist
  derweil ihre eigene Musik in den Spuren; die Übernahmen liegen solange im RAM, `vb_hs`, und kommen beim nächsten
  PLAY zurück), bis sie zurückgegeben werden oder der Strom geht. Nie in einem Projekt, im Autosave oder im Pool.
- **Die Noten hängen nicht davon ab**: Übernahmen ändern keinen Zufallsstrom (geprüft: derselbe Song mit und ohne
  Klangwechsel und Parameter, keine andere Note).
- **GROOVEBOX, während der Produzent spielt**: Ihre Klang-, LFO- und FX-Seiten wirken auf seine Spuren und zählen
  als Übernahme. Pattern bearbeiten (SEQ-Seiten, REC, SEQ TOOLS) **sperrt die FM-1 nicht**, sie sagt beim Öffnen
  „VIZZBOX PLAYS IT – NEXT BAR: ITS OWN“: Entscheidung, weil Sperren ein Dutzend Wege in Skiffs Sequencer bräuchte
  und das Bearbeitete bis zum Taktende ja klingt (ein kurzer Live-Trick), danach schreibt der Produzent seinen Takt.
- Nebenbei: Die weißen Tasten spielen jetzt jede melodische Spur in der Skala des Songs (QNT WHITE), CHORDS mit
  einem Akkord je Taste (Dreiklang oder Septakkord des Stils, Skiffs CHORD-Tasten); beides wirkt nur auf Tasten und
  MIDI-Eingang, nie auf die Songs (Golden unverändert).

Gemessen: **+1 664 Bytes** im Flash (vb_back 342, vb_isr +322, vb_sound 262, die Übernahmen über die GROOVEBOX
rund 250, Rest in den Haken), +132 im Pool, +2 812 im RAM hinter `.bss` (`vb_hs`). Frei danach: 3 996 Bytes.

## 5. Bedienung: Seiten, Fokus-Spur, Tasten, Layer (Etappen 3 und 4)

Die VIZZBOX ist jetzt eine Weiche vor Skiffs eigener Oberfläche (`ui_vizzbox.c vb_input`): sie nimmt ihre Tasten und
die Regler der Seite SONG, alles andere machen Skiffs Seiten, Karten, Grafiken und Layer – kein Nachbau.

- **Seiten.** SONG wie in 1.0. **EDIT** öffnet **KLANG**, **LFO** öffnet **MOD**, dieselbe Taste noch einmal oder
  HOME antippen führt zurück zu SONG. KLANG beginnt mit **LIVE** (die vier Werte der Rolle: die beiden Klangregler der
  Engine von Skiffs HOME, RELEASE oder der eigene Ausklang der Engine, DRIVE), danach mit SELECT Skiffs Seiten der
  Familien EDIT, ENV, FX und der MIXER; MOD sind Skiffs LFO-Seiten. Oben die Karten für K1–K4, darunter die Grafik,
  beim Drehen groß der Wert – alles Skiffs. Die zuletzt offene Seite merkt sich KLANG und MOD je.
- **Kopf- und Fußzeile:** Abweichung vom Auftrag („in der Kopfzeile Seite, Fokus-Spur und Klang“): Skiffs Kopfzeile
  zeigt die Seite; Fokus-Spur und Klang stehen in der Fußzeile, die auf 240 Pixeln Breite dafür Platz hat.
- **Fokus-Spur:** beim Einschalten LEAD; ALGORITHM auf KLANG und MOD oder **SEL + schwarze Taste** überall.
- **PRESETS** auf KLANG und MOD: die Klänge der Rolle nach Skiffs Typen (DRUMS: Kits; BASS; CHORDS: Flächen und
  Keys; LEAD; ARP: Plucks, Leads, Keys; FX), zuerst die des Stils, mit `*` markiert; **HOME + PRESETS** jeder Klang
  (Skiffs Liste). Geladen wird sofort, über Skiffs Weg (also mit Undo und MIDI wie in der GROOVEBOX), und der Klang
  gehört damit dem Nutzer (Abschnitt 4).
- **Tasten:** die weißen spielen die Fokus-Spur – **DRUMS** eine Lane je Taste (KICK SNARE CLAP HAT HAT TOM RIM BELL),
  **CHORDS** einen Akkord je Taste (Dreiklang oder Septakkord des Stils in der Tonart, Skiffs CHORD-Tasten), die
  anderen in der Skala des Songs. Die schwarzen spielen nie eine Note: MUTE wie in 1.0, SEL + schwarz die
  Fokus-Spur, HOME + schwarz gibt diese Spur zurück.
- **FX halten** (über etwa 250 ms oder mit Taste/Regler währenddessen) öffnet Skiffs FX-Layer unverändert: die 14
  Effekte, die Makros FILTER CRUSH THROW DEPTH, die schwarzen Tasten stumm, RETURN beim Loslassen; **HOME + FX** hält
  ihn offen (Skiffs Lock), FX schließt ihn wieder. **FX antippen** löst DROP JETZT aus – neu beim Loslassen, nicht
  mehr beim Drücken. **ARP halten** öffnet PERFORM (die Throws CUTOFF REVERB DELAY DIST, OCT+ hält sie), die weißen
  Tasten spielen die Fokus-Spur (Skiffs Listen und Scenes gelten hier nicht); **ARP antippen** löst BREAK JETZT
  aus. SEQ bleibt HALTEN.
- **GLO halten:** die Busse wie Skiffs GLO-Layer – zuerst BUSES (Delay MIX, Reverb SIZE, Chorus DEPTH, Delay
  FEEDBACK), mit SELECT Skiffs GLO-Seiten (DELAY, REVERB, CHORUS mit Typ und Zeit). GLO + weiße Taste lädt einen
  Favoriten, GLO + schwarze SOLO, wie in 1.0.
- **LFO halten + Regler** auf KLANG: Skiffs MOMENTARY (der Wert, solange gehalten; zurück über RETURN); zählt nicht
  als Übernahme.
- **HOME halten** zeigt die Karte der Kombinationen wie Skiffs SHIFT-Karte: + BLACK GIVE BACK, + EDIT ALL BACK,
  + PLAY GROOVE, + PRESETS ALL, + FX LOCK, SEL + BLACK FOCUS, auf SONG dazu SEED, TEMPO, LENGTH auf den Reglern.
  **HOME lang** öffnet das MENU (in 1.0 kam man aus der VIZZBOX nicht hinein – ein Fehler der 1.0).
- **SONG** zeigt dazu den Rahmen der Fokus-Spur und je Spur einen Punkt für „übernommen“.
- **LEDs:** die offene Seite (EDIT, LFO leuchten), ein offener Layer (seine Taste atmet, wie in Skiff), die
  Fokus-Spur (ihre schwarze Taste atmet, stumm mittelhell; die anderen leuchten, solange sie klingen).
- **Wann die Spuren dem Produzenten gehören:** ab dem ersten PLAY oder beim Öffnen von KLANG oder MOD, nie vorher –
  die Spuren schon beim Einschalten zu nehmen, verschob einen Engine-Wechsel und damit das Audio der Songs aus 1.0.
  Bis dahin spielen die Tasten die Spur der GROOVEBOX. Verlässt man die VIZZBOX im Stillstand, bekommt die GROOVEBOX
  ihre Seite und Spur zurück.
- **In der GROOVEBOX während der Wiedergabe** (HOME + PLAY): Klang-, LFO- und FX-Seiten wirken auf die Spuren des
  Produzenten und zählen als Übernahme; Pattern-Seiten, REC und SEQ TOOLS sagen „VIZZBOX PLAYS IT – NEXT BAR: ITS
  OWN“ (Entscheidung und Begründung in Abschnitt 4).
- **Tasten über MIDI:** wie in Vizz 2.0 sendet jede gespielte Taste auf dem Kanal der Fokus-Spur (Skiffs
  `key_on`), auch die Lanes von DRUMS und die Akkordtöne (`docs/VIZZBOX-MIDI.md`).
- **Bildschirme:** zehn neue Szenen (KLANG LIVE, gedreht, EDIT-Seite, PRESETS, MOD, SONG mit Übernahme, FX-, GLO-,
  PERFORM-Layer, HOME-Karte) in allen sechs Paletten im Golden `tests/vizzbox_ui_golden.txt`; der Rahmen der
  Fokus-Spur ändert die SONG-Bilder der 1.0 (gewollt).

## 6. Tests

| Schritt | Ergebnis |
| --- | --- |
| Release 1.0 aus dem frischen Klon (Datum 28.10.) | bytegleich mit `out/vizzbox-1.0.fwsc` |
| `tests/run_tests.sh` auf dem Nachbau (145 Schritte, 25 min) | **`ALL HOST TESTS PASSED`**, 8 378 Einzelprüfungen „ok“, keine fehlgeschlagen – dieselben Zahlen wie in 1.0 |
| darin `producer_test`, `seqmidi_test` | „producer: all passed“, „seqmidi: all ok“ |
| darin die 176 Regressions-Renders, UI-Goldens, VIZZBOX-Bildschirme | unverändert |
| Golden der Songs aus 1.0 (326 Songs) | gebaut aus dem Baum der 1.0, zweimal gleich |
| **Etappe 2**, `tests/run_tests.sh` auf Patch 0016 | **`ALL HOST TESTS PASSED`**, 146 Schritte (dazu das Golden): Golden der 1.0-Songs bitgleich, GROOVEBOX mit/ohne Produzent bitgleich, Kostenmaß im Budget (`fm1_alnk0_irq` 24 543, `fm1_timer5_irq` 27 164) |
| darin `producer_test`, neu | hand_sound (Klang über GROOVEBOX und Program Change, über neuen Stil, STOPP/PLAY, ENDLOS; HOME + schwarze Taste, HOME + EDIT), hand_trip (über die GROOVEBOX im Stillstand), hand_param (CC 91, Regler in der GROOVEBOX, neuer Stil, Zurückgeben), hand_perf (FILTER gehalten, kein Sprung danach; GATE gehalten: kein Effekt des Produzenten), hand_notes (dieselben Noten mit und ohne Übernahme) |
| `tests/vizzbox_mutants.py`, neu | ein Stilwechsel übergeht den Klang, eine Fahrt überschreibt den Parameter, Zurückgeben gibt nicht zurück, FILTER des Produzenten über dem des Nutzers, Sprung statt Gleiten, die Songs aus 1.0 verändert: **jeder erkannt** |
| **Etappen 3–4**, `tests/run_tests.sh` (auf dem Stand mit Patch 0020, der 0017–0019 enthält) | **`ALL HOST TESTS PASSED`**, 148 Schritte, 8 399 Einzelprüfungen „ok“: Golden der 1.0-Songs bitgleich, GROOVEBOX mit/ohne Produzent bitgleich, Skiffs UI-Golden (3 388 Bilder: nur die 712 QUARK-Bilder geändert, Patch 0017), Kostenmaß `fm1_alnk0_irq` 24 922 (Budget 24 542, +10 % erlaubt), `fm1_timer5_irq` 27 166 (27 164), schwerster Drop 0,79 × Skiffs heavy song, mit allen Effekten 0,80 × |
| darin `producer_test`, neu | pages (EDIT KLANG, LFO MOD, SELECT durch die Familien, ALGORITHM und SEL + schwarz als Fokus, LIVE gedreht = Übernahme, HOME → SONG), browse (PRESETS je Rolle: die Klänge des Stils zuerst und markiert, dann die passenden Typen; HOME + PRESETS alle), keys (LEAD in der Skala, DRUMS je Taste eine Lane, CHORDS je Taste ein Akkord in der Tonart, schwarze Tasten nie eine Note, MIDI auf dem Kanal der Fokus-Spur), layers (FX antippen: DROP beim Loslassen; halten: Layer, kein DROP; ARP: BREAK / PERFORM, eine weiße Taste spielt die Fokus-Spur; SEQ HOLD; GLO + K1 Delay-MIX als Übernahme, SELECT die DELAY-Seite, das Tempo bleibt), momentary (LFO + K1: der Wert, zurück über RETURN, keine Übernahme), leds (Seiten, Layer atmet, Fokus-Taste atmet / stumm mittel; HOME + FX hält offen ohne DROP, FX schließt) |
| `tests/vizzbox_ui.c` | zehn neue Szenen × sechs Paletten im Golden |
| `tests/vizzbox_mutants.py`, neu | FX antippen öffnet nichts (kein DROP), FX halten löst DROP aus (wie 1.0 beim Drücken), DRUMS-Tasten nach GM statt Lanes, PRESETS ohne Markierung des Stils: **jeder erkannt** |

## Nächste Schritte

Etappe 5 (Favoriten mit Klängen) und 6 (Budget mit den Klängen des Nutzers) sind gebaut und getestet und folgen als
Patches 0020 und 0021; Etappe 7 (die 22 Subgenres der Liste) ist in Arbeit, dann Etappe 8 nach Abschnitt 10 des
Auftrags.
