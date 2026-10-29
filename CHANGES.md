# Vizzbox 1.1 – Änderungen gegenüber Skiff 2.0.1

> **Stand: fertig, alle 8 Etappen** (BRIEF-VIZZBOX-1.1.md, Abschnitt 10). `out/vizzbox-1.1.fwsc` (Kennung `FM-1_851`,
> nachbaubar bis aufs Byte), `out/vizzbox-installer.html`, `out/SHA256SUMS`, Lizenzen und Attributionen; `patches/`
> 0001–0024; Build und alle Tests grün, die Gegenprobe erkennt jeden Fehler. Gebaut sind „Hand drauf“, die Seiten
> KLANG und MOD mit Fokus-Spur, Tasten, Layern, Bussen, Bildschirm und LEDs, Favoriten mit Klängen, das Budget mit
> den Klängen des Nutzers (mit den Kosten der Engines), alle 22 neuen Subgenres mit Demos, CC 110, die Live-Demo und
> der Emulator auf 1.1. Nicht geprüft werden konnte nur eins: eine echte FM-1 (Abschnitt 12).

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
| 0020 | **Favoriten mit Klängen**, lesbar für die Vizzbox 1.0 (Abschnitt 6) |
| 0021 | **Budget** mit den Klängen des Nutzers: ihr Ausklang, POLY-Klänge, Platz fürs Mitspielen, die Kosten der Engines (Abschnitt 7) |
| 0022 | **22 neue Subgenres**, das Genre AFRO & LATIN, CC 110 (Abschnitt 8) |
| 0023 | **Version 1.1** (`FM-1_851`), nachbaubares Release, der Installer 1.0 ↔ 1.1, die neuen Bedienungen im Emulator (Abschnitte 9, 10) |
| 0024 | `tools/vizzbox_live.c`: die Live-Demo (Abschnitt 10) |

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
  die 1.1 wird das Datum deshalb festgelegt (`SOURCE_DATE_EPOCH`, Abschnitt 9), damit ihr Paket nachbaubar ist.
- **Alle Tests der 1.0** (`./build.sh`, dann `tests/run_tests.sh`): siehe Abschnitt 13.

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
| Etappe 5: Favoriten mit Klängen | 574 928 | 6 636 | +944 |
| Etappe 6: Budget | 576 752 | 4 812 | +1 824 |
| Etappe 7: 22 Subgenres, CC 110 | 578 032 | 3 532 | +1 280 |
| Etappe 8: Version 1.1 (`FM-1_851`), das Release | 578 032 | 3 532 | ±0 |

**Vorher und nachher:** Vizzbox 1.0 575 904 Bytes (5 660 frei), Vizzbox 1.1 578 032 Bytes (**3 532 frei**, die
Reserve von 2 KB bleibt): +2 128 Bytes für alles in diesem Dokument, gegen −6 684 für QUARKs Zierwerk. Je Funktion:
Hand drauf +1 664, Bedienung (Seiten, Fokus, Tasten, Layer, Busse, Bildschirm, LEDs) +3 100, Favoriten mit Klängen
+944, Budget mit den Klängen des Nutzers +1 824, 22 Subgenres und CC 110 +1 280.

RAM `.data` + `.bss` (mit `.vbox` dahinter) 90 172 von 98 304 Bytes, Pool 347 312 von 356 352 (Reserve 9 040, Skiff
verlangt 8 192).

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

## 6. Favoriten mit Klängen (Etappe 5)

- **SAVE + weiße Taste** speichert zum Rezept (Genre, Subgenre, Seed, Energie, Variation, Länge, Tempo – wie 1.0) je
  Spur, was der Nutzer übernommen hat: den **Klang** (ein Werks-Preset als Engine und Preset, ein User-Sound als sein
  Platz), die **zuletzt gedrehten Parameter**, bis zu acht je Spur (bei mehr die acht letzten: der Produzent führt je
  Spur eine Liste in der Reihenfolge des Drehens), und die **Bus-Werte**, die der Nutzer gedreht hat (bis zu zwölf).
- **Laden** (GLO + weiße Taste) stellt sie als Übernahmen wieder her: Eine Spur, die der Favorit hält, bekommt seinen
  Klang und seine Werte an Stelle dessen, was der Nutzer dort gerade hatte; die anderen Spuren bleiben, wie sie sind.
  Im Stillstand übernimmt der Produzent dafür die Spuren (wie beim Öffnen von KLANG); geladen, während die GROOVEBOX
  spielt, kommen die Klänge beim nächsten PLAY der VIZZBOX. Ein Favorit **ohne Übernahmen** verhält sich wie in 1.0.
- Ein Favorit, der auf einen **User-Sound-Platz** zeigt, spielt, was jetzt dort liegt; ein leerer Platz lässt die
  Spur beim Klang des Produzenten.
- In der Liste des GLO-Layers steht bei einem Favoriten mit Klängen ein `+`.
- **Format:** die beiden Sektoren der 1.0 (A `0x95000`, B `0x96000`) bleiben, ihr Rekord „VBF1“ am Anfang
  unverändert – die Vizzbox 1.0 liest ihn wie bisher und liest nicht weiter. Dahinter, ab `+0x100`, je Favorit ein
  Eintrag von 196 Bytes: das Rezept, zu dem er gehört, die Klänge, Parameter, Busse und eine eigene CRC. Er zählt,
  solange sein Favorit genau dieses Rezept hat, in welcher der beiden Kopien auch immer (die neuere gewinnt). Speichert
  die 1.0 über einen Favoriten, verliert nur dieser seine Klänge; die anderen behalten sie, auch wenn die 1.0 die
  neuere Kopie ohne Einträge geschrieben hat. Skiff 2.0.1 und Vizz 2.0 fassen die Sektoren weiter nicht an.
  Geschrieben wird mit dem Rekord, nur im Stillstand, wie in 1.0.
- RAM: 3 136 Bytes für die Einträge (hinter `.bss`, beim Booten aus dem Flash gelesen), 48 im Pool für die Listen der
  letzten Parameter.

## 7. Budget mit den Klängen des Nutzers (Etappe 6)

**Stimmen.** Der Produzent plant jeden Takt so, dass höchstens 8 Stimmen klingen (1.0). Mit einem Klang des Nutzers
plant er jetzt mit dessen eigenem Ausklang, dessen Stimmenzahl und dessen Kosten:

- **Ausklang aus den Hüllkurven** (`producer.c vb_tail_ms`, `vb_ring_ms`): für einen gewählten Klang (oder wenn
  RELEASE, ENV SYNC oder der Stimmen-Modus gedreht wurden) – die Release der Amplituden-Hüllkurve bis zum Ende der
  Stimme (Skiff beendet sie bei −72 dB: 8,3 Zeitkonstanten, die Tabelle nennt 4,6; gerechnet mit 8,5 und 40 ms),
  ENV SYNC als Notenwert im Tempo; **FM6** nach seinen Trägern (seine eigenen Hüllkurven beenden die Stimme: der Pegel
  fällt je Block um den Schritt der Rate R4, vom höchsten aus L1–L3 bis zum Boden; L4 über Stille: 12 s);
  **DRUM-X** je Lane aus DECAY (das lautere Ende von MORPH und der DECAY-Regler darin); **DRUM** aus einer kleinen
  Tabelle der gemessenen Presets (13 × 8 Lanes, `VB_DRING`), verschoben von DECAY-Regler und Lane-DECAY (gemessen
  ×1,5 je 16 hinauf, ×1,2 hinab; gerechnet ×2 je 24 hinauf, /2 je 64 hinab), ein anderes KIT nach dem Preset mit
  diesem Kit, tiefere PITCH oder anderer KICK doppelt; höchstens 12 s.
  **Geprüft gegen jeden Werks-Sound** (`producer_test tails`: jedes Preset eine Note, jedes Kit jede Lane, dazu
  DECAY-Regler und Lane-DECAY verschoben): keine Schätzung kürzer als gemessen.
- **Ein POLY-Klang** (oder einer aus Schlägen) auf einer Rolle, die der Produzent mit einer Stimme spielt (BASS,
  LEAD, ARP, FX), zählt eine Stimme je Note wie die Akkorde (`vb_ply`), höchstens so viele, wie seine Engine hat.
  Ein Klang mit einer Stimme auf CHORDS zählt eine.
- **Mitspielen:** gehaltene und noch klingende weiße Tasten auf der Fokus-Spur (Klang mit einer Stimme: keine
  zusätzlichen; DRUMS eine Lane je Taste; CHORDS mit Ein-Finger-Akkord drei oder vier je Taste; höchstens sechs)
  bekommen im übernächsten Takt Platz (`vb_room`).
- **Die Kosten der Engines** (`VB_EW`, `vb_w`) – der Weg, den der Auftrag nennt, wenn die schwerste Wahl sonst nicht in
  die Grenze passt (siehe unten): Eine Stimme eines Klangs, den der Nutzer gewählt hat, zählt im Budget so viel, wie
  die teuerste Werks-Stimme ihrer Engine kostet, in Vierteln der teuersten VOICE-Stimme (MONK CHANT), mindestens eine
  ganze: **PHYS zwei, GRAIN 1¾, FM6 und DRUM-X 1½**, alle anderen eine. Mit schweren Klängen plant der Produzent also
  weniger Stimmen. Klingt ein Bass-Klang des Nutzers in den nächsten Takt hinein, darf das Budget als Letztes auch
  dessen Noten ausdünnen (die Bässe des Produzenten nie). Die Klänge des Produzenten zählen wie in 1.0 je eine Stimme –
  seine Songs bleiben bitgleich. (Skiffs eigene Tabelle `ENG_VCOST` in `fx.c` gibt es nur im Zweikern-Build, sie
  nennt Mittelwerte je Engine und für DRUM-X die von DRUM; deshalb 15 eigene Bytes aus der Messung.)
- **Was bleibt:** Die Takte, die schon geplant waren, als ein Klang gewählt wurde oder das Mitspielen begann, sind
  für das Alte geplant; dort kann Skiff eine ausklingende Stimme in einem Block ausblenden (seine Stimmenverwaltung
  hält die 8 immer). Ab dem übernächsten Takt nicht mehr. Die Zusatzstimmen eines UNISON-Klangs nimmt Skiff zurück,
  wenn andere sie brauchen – wie in der GROOVEBOX. Ein von Hand umgebautes DRUM-X-Kit schätzt die Vizzbox aus seinen
  eigenen DECAY-Werten, ein User-Kit (Samples) mit 6 s je Lane; ein USER-Klang zählt mit den Kosten seiner Engine.

**Gemessen** (`producer_test budget_user`): die längsten Ausklänge auf allen Rollen (CRISP KIT, SOFT PAD, OCEAN,
FROZEN, GLASS BELL, CRYPT CHOIR) und zufällige Werks-Sounds auf allen sechs Spuren über drei Drops: höchstens 8
Stimmen, **keine gestohlen** ab dem Drop; zwei Tasten auf einem POLY-LEAD und ein Ein-Finger-Akkord auf CHORDS über
acht Takte: keine gestohlen ab dem vierten; DRUM-X DEEP KIT und PHYS BOWED METAL auf allen Spuren: nie mehr als das
Budget in Vierteln (ohne die Kosten wären es 58 statt höchstens 32).

**CPU – Messfall „schwerste Wahl“** (`tests/vizzbox_budget.c`). Zuerst wird jeder Werks-Sound gemessen: was eine
Stimme kostet (acht Noten gehalten auf T1, POLY, eine Sekunde, abzüglich derselben Sekunde ohne Noten, geteilt durch
die klingenden Stimmen; das Geringste aus drei Läufen). Der teuerste je Budget-Viertel, den jede Spur spielen darf,
kommt auf T1–T4, der teuerste, den T5 und T6 spielen dürfen, auf diese – alle als Klänge des Nutzers, im schwersten
Drop aus dem Durchlauf aller Subgenres, mit allen Effekten zugleich, Seite an Seite mit Skiffs heavy song mit
denselben Effekten (Grenze 1,10).

- **Ohne die Kosten der Engines reichte es nicht:** PHYS BOWED METAL auf T1–T4 und VOICE WOW BASS auf T5/T6 kamen
  auf **1,19 ×** (7 Stimmen). (Ein erster Zwischenstand teilte die ganze Rechenzeit durch die Stimmen; damit sah eine
  Engine mit einer Stimme am teuersten aus, und die Wahl wechselte von Lauf zu Lauf. Nichts davon war gepusht.)
- **Mit ihnen:** die schwerste Wahl je Budget-Viertel, VOICE MONK CHANT auf allen sechs: **0,74 ×** (5 Stimmen); über
  alle Läufe dieser Arbeit (je nach Lauf eine andere VOICE-Stimme, mit 4 bis 8 Stimmen) 0,49 bis **0,87 ×**.
  Gegenproben mit festen Klängen im selben Messfall: PHYS BOWED METAL / VOICE WOW BASS 0,87 ×, PHYS BOWED METAL überall
  0,77 ×, PHYS BELL TREE / VOICE CRYPT CHOIR 0,73 ×, GRAIN SHIMMER überall 0,69 ×, FM6 GROWL BASS überall 0,58 ×, DRUM-X
  DEEP KIT / VOICE CRYPT CHOIR 0,52 ×.
- Ohne die Klänge des Nutzers wie in 1.0: schwerster Drop 0,68–0,81 ×, mit allen Effekten 0,70–0,77 × (je nach Lauf
  ein anderer der fünf schwersten). Der Interrupt-Teil des Produzenten bleibt eine Funktion ohne Schleife über die
  Samples; das Kostenmaß der Interrupts ist unverändert (`fm1_alnk0_irq` 24 922, `fm1_timer5_irq` 27 166).

Platz: `VB_DRING` 104 Bytes, `VB_EW` 15, alles zusammen **+1 824 Bytes** (App 576 752, frei 4 812), Pool +144
(Reserve 9 040).

## 8. Mehr Subgenres (Etappe 7)

**Alle 22 der Liste** (Abschnitt 4 des Auftrags) passen; keins übersprungen. Zusammen mit CC 110 kosten sie
**+1 280 Bytes** (App 578 032, frei 3 532: die Reserve von 2 KB bleibt).

| CC 108 · Genre | neu (CC 109) |
| --- | --- |
| 0 HOUSE | 6 PROG HOUSE, 7 BASS HOUSE |
| 1 TECHNO | 6 ACID TECHNO, 7 INDUSTRIAL |
| 2 ELECTRO / SYNTHWAVE | 3 NU-DISCO, 4 DARKSYNTH |
| 3 TRANCE | 4 HARD TRANCE |
| 4 BREAKS / UK GARAGE | 3 BASSLINE, 4 GRIME, 5 JERSEY CLUB |
| 5 DRUM & BASS | 4 HALFTIME |
| 6 DUBSTEP | 2 RIDDIM, 3 FUTURE BASS |
| 7 HIP-HOP / LO-FI / TRAP | 3 DRILL, 4 PHONK |
| 8 AMBIENT / DOWNTEMPO | 3 TRIP-HOP |
| 9 HARDSTYLE / HARDCORE | 2 HARDCORE, 3 FRENCHCORE |
| **10 AFRO & LATIN** (neues Genre nach HARD) | 0 AMAPIANO, 1 AFROBEATS, 2 REGGAETON, 3 BAILE FUNK |

Auf dem Gerät stehen sie im Genre hinter den alten (Regler SUBGENRE), die Demos zählen sie von 37 bis 58.

- **Nummern:** Die 36 aus 1.0 behalten Genre- und Subgenre-Nummer (CC 108/109, Favoriten) und ihren Platz in
  `VB_SUB`, nach dem ihr Zufallsstrom und ihre Pegel gehen; die neuen stehen dahinter, je Genre nach den alten
  (`vb_rig`, `vb_gof`). Das Golden der 1.0-Songs ist bitgleich.
- **Tabellen statt Code:** jede neue Zeile ist eine Zeile `VB_SUB` (Tempo, Swing, Form, Raster, Bass-, Akkord-,
  Lead-, Arp-Stil und ihre Klanglisten), aus den vorhandenen Generatoren. Neu sind nur sechs Drum-Raster, wo der
  Charakter sie braucht – Amapiano (Shaker in 16teln, Rim und Holz, Claps neben der Zählzeit), Afrobeats (synkopierte
  Kick, Congas), **Dembow**, Drill (Halftime, Hats in Dreiergruppen), Jersey Club (die Kick in Dreiergruppen),
  **Tamborzão** – und ein Schalter für Hat-Rolls wie bei TRAP (Drill, Phonk, Future Bass).
- **Klänge durch Messen:** zwei neue Listen, gerendert und gemessen wie in 1.0 (`tools/vizzbox_sounds`,
  `vizzbox_sounds.py`, `vizzbox_pick.py`, das jetzt die vorhandenen Klänge und Listen unverändert übernimmt und nur
  neue anhängt): **Log Drum** für Amapiano (perkussiv, Tonhöhe fällt: SYN TOM, TOMS, HAND DRUM, PICK BASS; KALIMBA,
  MARIMBA zu leise, FM MARIMBA zu langer Ausklang) und **Glocken / Cowbell** als Lead für Phonk und Drill (RING BELL,
  MUSIC BOX, CHIP BELL; BELL TREE und METAL zu hell, GLASS BELL ohne Ende). Sonst die Listen aus 1.0.
- **Pegel:** `tools/vizzbox_level.py` bringt die neuen auf die gemeinsame Lautheit (drei Seeds, vier Durchgänge, bis
  sich keine Trimmung mehr ändert: −24,5 bis −22,3 dBFS bei −22,5 als Ziel; fünf stehen an der Obergrenze von +4 dB,
  die schon in 1.0 galt – mehr Pegel hieße mehr Limiter); die 36 aus 1.0 behalten ihre.
- **ENDLOS:** Von einem neuen Subgenre geht es zu allen Tempo-Nachbarn, neuen wie alten. Von einem der 36 aus 1.0
  aus wählt die Vizzbox wie in 1.0 nur unter den 36 – sonst wären deren ENDLOS-Songs nicht mehr dieselben.
- **Abweichungen vom Richtwert:** HARDCORE und FRENCHCORE ohne eigenen Bass (die verzerrte Kick ist der Bass; der
  „Hoover“ der Liste spielt als Lead); RIDDIM ohne Triolen (16tel-Raster); Drill-Hats in Dreiergruppen statt echter
  Triolen; Grime mit Pizzicato als Arp.
- **Anzeige:** Der große Wert beim Drehen kommt in einer Schrift ohne „&“; ein Name mit einem Zeichen, das ihr fehlt
  („AFRO & LATIN“, auch „DRUM & BASS“ aus 1.0), steht jetzt in der mittleren Schrift – so macht es Skiff auf seinen
  Karten (`face_has`).
- **Demos:** von jedem neuen eine wie in 1.0 (`demos/37-…` bis `58-…`, Tabellen in `demos/README.md`), gerendert mit
  `tools/vizzbox_demos.py … new`; die 36 aus 1.0 bleiben, wie sie sind (ihre Songs sind bitgleich). Dabei aufgefallen:
  `tools/vizzbox_render.c` nannte die Stile noch nach der Zählung von 1.0 – korrigiert, bevor eine Demo gespeichert
  wurde.
- **CC 110** (optional, gebaut): auf Kanal 16 der gerade gehaltene Effekt des FX-Layers, 1–14 in der Reihenfolge der
  Tasten (der des Nutzers zuerst, sonst der des Produzenten), 0 keiner; bei Änderung und auf jeder Takt-Eins nach
  den sechs. Das Golden lässt CC 110 aus, weil die 1.0 ihn nie sendet.
- **Gefunden beim neuen Test „ENDLOS 30 min ab AMAPIANO“** (ein Verhalten aus Skiff, das es schon in 1.0 gab): Nachdem
  das Tempo geglitten ist, können die Spuren die Eins eines Takts einen Teilblock der Klangerzeugung (32 Samples,
  0,7 ms) vor Skiffs Takt-Zähler erreichen; dann kommen die Noten dieser Eins kurz vor CC 104–109. Im Lauf ab LIQUID
  (nur 1.0-Stile) zeigt es sich genauso, es traf dort nur nie eine Drop-Eins. Nicht geändert, weil der Takt-Zähler
  Skiffs ist und das Golden der 1.0-Songs (auch ENDLOS) es enthält; der Test zählt die Kick jetzt im selben Block wie
  CC 104, und `docs/VIZZBOX-MIDI.md` nennt die Ausnahme (mit Etappe 8).

## 9. Version 1.1: Name, Kennung, Installer, Paket (Etappe 8)

- **Name und Kennung:** `FELUCCA_VERSION` „v1.1“ (Startbild, ABOUT, Editor); das Release `./build.sh --release 1.1`
  bekommt wie jede Vizzbox X.Y die Kennung `FM-1_8(X+4)Y`, also **`FM-1_851`**; das Paket heißt `vizzbox-1.1.fwsc`,
  der Installer weiter `vizzbox-installer.html`. Entwicklungs-Builds bleiben `FM-1_800`.
- **Nachbaubar:** Skiffs ABOUT-Seite zeigt das Build-Datum (`__DATE__`). Mit `SOURCE_DATE_EPOCH` setzt
  `tools/build.py` es auf diesen Tag (UTC, Monatsnamen aus einer festen Liste, unabhängig von der Sprache des
  Rechners); `build-vizzbox.sh` legt den 29. Oktober 2026 fest. Zwei Release-Builds aus frischem Baum: **bytegleich**
  (sha256 siehe `out/SHA256SUMS`). Geprüft auch rückwärts: der Baum der 1.0 mit dem Datum ihres Builds ergibt mit
  diesem Weg wieder `out/vizzbox-1.0.fwsc` der 1.0.
- **Installer:** Über Vizzbox 1.0, Vizz 2.0 und Skiff 2.0.1 (und einer 1.1) nur installieren; über Vizz 1.x, Skiff
  1.4, älterem Felucca und Entwicklungs-Builds wie in 1.0 erst die vollständige Sicherung, dann installieren, dann
  umwandeln, was Firmware 2.0 nicht lesen kann. Das entscheidet die Kennung (`FM-1_8XY` mit X ≥ 2: Skiff 2.0
  darin), sonst die Versionsnummer – unverändert aus 1.0, nur die Texte nennen jetzt „1.x“.
- **1.0 → 1.1 und zurück, auch mit Favoriten** (alles auf dem Rechner, ohne Gerät):
  - der **Update-Loader** (`tests/ldr_test.c`, Skiffs eigener Loader-Code mit simuliertem Flash) vom Paket der 1.0
    (`origin/vizzbox-1.0:out/vizzbox-1.0.fwsc`, sha256 `4f8e1016…`) auf das der 1.1 und zurück: der App-Bereich
    geschrieben, der Kopf zuletzt, **die Sektoren der Favoriten 0x95000–0x96FFF unberührt**;
  - die **Installer** in Chromium über einem simulierten Gerät: der der 1.1 über einer 1.0 (`FM-1_850`) und **der
    Installer der 1.0, wie er ausgeliefert wurde, über einer 1.1** (`FM-1_851`): keine Sicherung, keine Frage,
    installiert, danach meldet das Gerät die Kennung des Pakets;
  - die **Favoriten selbst** (`tests/vizzbox_compat.c`, Abschnitt 6): die 1.0 liest die Rezepte, die die 1.1 schrieb,
    die 1.1 die Favoriten der 1.0, die Klänge bleiben über einen Ausflug in die 1.0 erhalten.
- **`out/`:** `vizzbox-1.1.fwsc`, `vizzbox-installer.html`, `SHA256SUMS` (beide Dateien), Lizenzen und Attributionen
  wie in 1.0 (`LICENSE`, `LICENSING.md`, `LICENSES/`, `ATTRIBUTION.txt`, `ATTRIBUTION-BREAKS.txt` aus dem
  Release-Ordner). Das Paket der 1.0 liegt weiter auf dem Branch `vizzbox-1.0`.

## 10. Hören und ausprobieren (Etappe 8)

- **`demos/vizzbox-im-browser.html` auf 1.1:** dieselbe Firmware im Browser. Jede neue Bedienung lässt sich anklicken
  (eine Taste halten: gedrückt halten; zwei zugleich: die erste mit Rechtsklick oder Shift-Klick festhalten) und über
  die Computertastatur spielen, wo eine Taste so lange hält, wie man sie hält; auf der Seite steht die ganze
  **Tastenbelegung** (1 FX, 2 SEL, 4 LFO, 5 EDIT, 6 GLO, 7 HOME, 8 SAVE, 9 ARP, `-` PLAY, Z … / die weißen Tasten,
  S D F H J L die schwarzen der sechs Spuren, Pfeile SELECT und ALGORITHM, Maus und Mausrad die Regler).
  `web/emu/test_vizzbox_emu.mjs` prüft das in Chromium: EDIT öffnet KLANG, SEL + schwarze Taste 2 wechselt die
  Fokus-Spur, FX gehalten zeigt den Layer und geht beim Loslassen, ein Rechtsklick hält FX fest und löst es wieder,
  die Übersicht steht auf der Seite.
- **Demos:** die 22 neuen (Abschnitt 8); die 36 der 1.0 unverändert.
- **Live-Demo** (optional im Auftrag, gemacht): `demos/live-1.1.mp3`, 60 s TECH HOUSE mit einer geskripteten
  Performance über die Bedienelemente des Geräts (`tools/vizzbox_live.c`): BASS-Klang über PRESETS gewechselt, der
  Filter von CHORDS über LIVE-Regler 1 zu und auf, REPEAT 1/16 vor dem Drop, im Drop acht Takte auf LEAD mitgespielt.

## 11. Update-Anleitung

Für alle Wege: die FM-1 per USB anschließen, **`out/vizzbox-installer.html`** in Chrome oder Edge öffnen (eine Datei,
auch ohne Internet), den MIDI-Zugriff erlauben, **Install**, warten bis „Done“. Kabel nicht ziehen; bricht es ab,
bleibt die FM-1 im Update-Modus, und **Install** noch einmal genügt.

- **Von der Vizzbox 1.0:** nur installieren. Projekte, Sounds, Einstellungen und die 16 Favoriten bleiben; die
  Favoriten spielen dieselben Songs wie in 1.0 (die 36 Subgenres haben ihre Nummern behalten). Neu nach dem Neustart:
  die Seiten KLANG (EDIT) und MOD (LFO), die Fokus-Spur, FX/ARP/GLO halten, 58 Stile (`docs/VIZZBOX-ANLEITUNG.md`,
  Abschnitte 6 und 9).
- **Von Vizz 2.0 oder Skiff 2.0.1:** nur installieren, nichts wird umgewandelt (beide sind Skiff 2.0 innen); die FM-1
  startet in der VIZZBOX, HOME + PLAY führt in die GROOVEBOX mit allem, was vorher da war.
- **Von Vizz 1.x, Skiff 1.4 oder älter:** der Installer speichert zuerst die vollständige Sicherung
  (`Vizzbox-backup-DATUM.json`, der Weg zurück), installiert, wandelt dann um, was Firmware 2.0 nicht lesen kann, und
  zeigt die Liste.
- **Zurück zur 1.0:** ihren Installer (Branch `vizzbox-1.0`, `out/vizzbox-installer.html`) öffnen und installieren –
  ohne Sicherung und ohne Umwandlung, geprüft (Abschnitt 9). Die 1.0 liest die Favoriten der 1.1 als Songs; die Klänge
  darin behält der Flash, eine spätere 1.1 hat sie wieder (außer bei einem Favoriten, den man in der 1.0 neu speichert). Ebenso zurück zu Vizz 2.0 oder Skiff 2.0.1 über deren
  Installer; zur Original-Firmware über M-VAVEs Update-Programm (V15).

## 12. Entscheidungen und Abweichungen im Überblick

- **Platz:** QUARKs eigenes Zierwerk weggelassen (−6 684 Bytes, Abschnitt 3); die QUARK-Palette, LARGE, NEON, CRYPT
  und alle Engines und Effekte bleiben. Der Flash zwischen `0x93000` und `0x95000` bleibt ungenutzt (ohne Gerät nicht
  ohne Risiko zu beweisen).
- **Kopf- und Fußzeile:** Fokus-Spur und Klang stehen in der Fußzeile statt in der Kopfzeile (Abschnitt 5).
- **Pattern-Seiten in der GROOVEBOX während der Produzent spielt:** nicht gesperrt, sondern der Hinweis „VIZZBOX
  PLAYS IT – NEXT BAR: ITS OWN“ (Abschnitt 4).
- **Die Fokus-Spur ist Skiffs gewählte Spur** (wie der Auftrag sie wählen lässt: ALGORITHM, SEL + schwarze Taste),
  beim Einschalten LEAD; die GROOVEBOX zeigt deshalb nach einem Ausflug die zuletzt gewählte Spur.
- **Budget:** die Kosten der Engines zählen bei den Klängen des Nutzers mit (Abschnitt 7) – der im Auftrag genannte
  Weg, nachdem die schwerste Wahl ohne sie 1,19 × erreichte.
- **Subgenres:** alle 22, mit den genannten Abweichungen vom Richtwert (Abschnitt 8); ENDLOS von einem der 36 aus 1.0
  bleibt unter den 36.
- **CC 104–109 nach einem Tempo-Gleiten** (aus Skiff, schon in 1.0): bis zu 0,7 ms nach den Noten derselben Eins;
  nicht geändert (Abschnitt 8).
- **Nicht auf einem Gerät geprüft:** Alles ist auf dem Rechner getestet – der Firmware-Code im Emulator, Skiffs
  Update-Loader mit simuliertem Flash, die Installer in Chromium über einem simulierten Gerät, Platz und
  Interrupt-Kosten statisch am Release. Eine echte FM-1 stand nicht zur Verfügung.

## 13. Tests

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
| **Etappe 5**, derselbe Lauf | darin `producer_test fav_sounds`: LEAD-Klang auf KLANG gewählt, LIVE-Regler gedreht, CHORDS mit User-Sound, Delay-MIX auf GLO, ARP zehn Parameter gedreht; SAVE + Taste 3: der Rekord der 1.0 unverändert und lesbar, der Eintrag dahinter (ARP: die acht letzten); **ein frisches Gerät in einem eigenen Prozess bootet auf diesem Flash** (`fav_boot`), GLO + Taste 3: das Rezept, die Klänge, der Wert, der Bus, wieder die des Nutzers, ein neuer Stil lässt sie; ein Favorit ohne Übernahmen lässt die Hand, wie sie ist; ein Platz mit anderem Klang spielt den neuen |
| `tests/vizzbox_compat.c` mit dem Baum der Vizzbox 1.0 (neu) | die 1.0 liest die 16 Rezepte, die 1.1 schrieb, speichert über Favorit 10; zurück auf 1.1: Favorit 6 mit Klängen, Favorit 10 ohne (anderes Lied), eine Änderung schreibt alle Einträge wieder; die Favoriten, die die 1.0 schrieb, liest die 1.1 wie geschrieben, ohne beim Booten etwas zu schreiben, und speichert einen mit Klang. Skiff 2.0.1 und Vizz 2.0 lassen beide Sektoren bytegleich (wie in 1.0; jeder alte Baum jetzt mit seinem eigenen `tests/hostsim.c`) |
| `tests/vizzbox_mutants.py`, neu | die Klänge im Favoriten werden nicht gespeichert, die Favoriten aus 1.0 gehen verloren (ein eigener Rekord „VBF2“): **jeder erkannt** – alle 12 Fehler der 1.1 bis hier erkannt |
| **Etappe 6**, `tests/run_tests.sh` auf Patch 0021 | **`ALL HOST TESTS PASSED`**, 148 Schritte, 8 400 Einzelprüfungen „ok“: Golden der 1.0-Songs bitgleich, GROOVEBOX mit/ohne Produzent bitgleich, Kostenmaß `fm1_alnk0_irq` 24 922, `fm1_timer5_irq` 27 166 (unverändert); im selben Lauf die schwerste Wahl VOICE CHOIR AAH auf allen sechs Spuren 0,81 × Skiffs heavy song (8 Stimmen, Grenze 1,10), schwerster Drop 0,79 ×, mit allen Effekten 0,73 × |
| darin `producer_test`, neu | tails (jedes Werks-Preset, jedes Kit jede Lane, DECAY-Regler und Lane-DECAY verschoben: keine Schätzung kürzer als gemessen), budget_user (die längsten Ausklänge auf allen Rollen, zufällige Werks-Sounds auf allen Spuren über drei Drops; Mitspielen auf POLY-LEAD und mit Ein-Finger-Akkord: höchstens 8 Stimmen, keine gestohlen; DRUM-X DEEP KIT und PHYS BOWED METAL überall: nie mehr als das Budget in Vierteln) |
| `tests/vizzbox_budget.c`, neu | Messfall „schwerste Wahl“ (Abschnitt 7): die Kosten jeder Werks-Stimme, die teuerste je Budget-Viertel auf allen Spuren als Klänge des Nutzers, schwerster Drop, alle Effekte; dazu die Gegenproben mit festen Klängen (Abschnitt 7, auf ruhiger Maschine) |
| `tests/vizzbox_mutants.py`, neu | das Budget plant den Ausklang des Produzenten für den Klang des Nutzers, ein POLY-Klang zählt eine Stimme, kein Platz fürs Mitspielen, FM6 nach der Amplituden-Hüllkurve statt nach seinen Trägern, die Kosten der Engines nicht im Budget: **jeder erkannt** – alle 17 Fehler der 1.1 bis hier erkannt |
| **Etappe 7**, `tests/run_tests.sh` auf Patch 0022 (der Baum vor einer Ortsangabe in `tests/vizzbox_mutants.py`, sonst derselbe) | **`ALL HOST TESTS PASSED`**, 148 Schritte, 8 400 Einzelprüfungen „ok“: Golden der 1.0-Songs bitgleich (CC 110 ausgenommen), GROOVEBOX mit/ohne Produzent bitgleich, VIZZBOX-Bildschirme wie im Golden, Kostenmaß unverändert (`fm1_alnk0_irq` 24 922, `fm1_timer5_irq` 27 166); schwerster Drop über alle 58: DRUM & BASS / HALFTIME, 0,68 ×, mit allen Effekten 0,87 × (Grenze 1,10); die schwerste Wahl in diesem Lauf 0,49 × (die Auswahl schwankte noch von Lauf zu Lauf: Etappe 8 misst jeden Klang länger) |
| darin `producer_test`, neu | jedes neue Subgenre in jeder LÄNGE mit den Prüfungen der 1.0 (Form, Tempo, Tonart, Lagen, Stimmen, DROPs, CC 104–109), ENDLOS 30 min ab AMAPIANO (Nachbarn neu und alt, kein Wechsel über 8 BPM, keine Stimme gestohlen), cc110 (GATE gehalten 11, losgelassen nicht mehr, auf jeder Eins nach den sechs, beim Stopp 0) |
| `tests/vizzbox_fuzz.c`, erweitert | (Abschnitt 9 des Auftrags) dazu EDIT und LFO, SEL + schwarze Taste, FX/ARP/GLO gehalten mit Reglern und Tasten, LFO + Regler, PRESETS und HOME + PRESETS, HOME + schwarze Taste und HOME + EDIT (danach nichts mehr des Nutzers), die GROOVEBOX zwischendurch mit ihren Reglern, die Genres bis AFRO & LATIN: je 1 500 Aktionen mit Seed 11 und 12 unter ASan/UBSan, 0 Fehler |
| `tests/vizzbox_mutants.py`, neu | ein neues Subgenre verschiebt alte Nummern (HOUSEs neue vor seinem sechsten): **erkannt**; der ganze Lauf auf Patch 0022 (ohne die Fehler im Installer, die Etappe 7 nicht berührt): **jeder Fehler erkannt**, alle 18 der 1.1 und die der 1.0 (eine Ortsangabe der 1.0 nachgeführt, die CC 110 verschoben hatte: „CC 104 beim Stopp nicht 0“) |
| **Etappe 8**, `tests/run_tests.sh` auf Patch 0023 (0024 ist ein Werkzeug außerhalb der Firmware) | **`ALL HOST TESTS PASSED`**, 148 Schritte, 8 405 Einzelprüfungen „ok“: **176 Regressions-Renders bitgleich** (auch mit dem zweiten Kern und ohne ihn), Golden der 1.0-Songs bitgleich, GROOVEBOX mit/ohne Produzent bitgleich, Kostenmaß unverändert (`fm1_alnk0_irq` 24 922, `fm1_timer5_irq` 27 166); schwerster Drop TECHNO / INDUSTRIAL 0,81 ×, mit allen Effekten 0,80 ×, die schwerste Wahl (jetzt 4 s je Klang gemessen) VOICE MONK CHANT auf allen sechs 0,56 × (Grenze 1,10) |
| darin der Emulator auf 1.1 | `web/emu/test_vizzbox_emu.mjs`: eingeschaltet, KNOB 1, PLAY (Bild und Ton), die Tastenübersicht, EDIT öffnet KLANG, SEL + schwarze Taste 2 wechselt auf BASS, FX gehalten zeigt den Layer, Rechtsklick hält FX fest und löst es, Stopp, keine Skriptfehler: **all ok** (ebenso mit `demos/vizzbox-im-browser.html`) |
| **Gegenprobe** auf dem Endstand (`tests/vizzbox_mutants.py`, `tests/vizz_mutants.py`) | **jeder Fehler erkannt**: alle 40 im Produzenten, Bildschirm und Golden (die 18 der 1.1 darunter: Stilwechsel übergeht die Übernahme, eine Fahrt überschreibt den Parameter, Zurückgeben gibt nicht zurück, FILTER des Produzenten über dem des Nutzers, Sprung statt Gleiten, Antippen öffnet nichts, Halten löst DROP aus, DRUMS-Tasten nach GM, PRESETS ohne Markierung, die Songs aus 1.0 verändert, die Klänge im Favoriten nicht gespeichert, die Favoriten aus 1.0 verloren, vier Budget-Fehler, die Kosten der Engines vergessen, ein neues Subgenre verschiebt alte Nummern), beide im Installer, und alle der Gegenprobe von Vizz 2.0. Nachgeführt: zwei Ortsangaben, die sich mit CC 110 und dem Text „1.x“ im Installer verschoben hatten |
| **`./build-vizzbox.sh` von vorn** (frischer Skiff-Klon, die 24 Patches, ohne die Gegenproben, die oben liefen) | 38 min, **rc 0**: Release, Konverter, Installer, `tests/run_tests.sh` **`ALL HOST TESTS PASSED`** (148 Schritte, 8 405 „ok“; schwerster Drop 0,78 ×, mit allen Effekten 0,67 ×, schwerste Wahl VOICE CHOIR AAH überall 0,87 ×, 8 Stimmen), Update-Loader 1.0 → 1.1 und 1.1 → 1.0 mit den Favoriten-Sektoren, die Installer beide Richtungen: **all ok**; das `out/`, das es schreibt, ist bytegleich mit diesem (`SHA256SUMS` gleich) |
| Release `./build.sh --release 1.1` mit `SOURCE_DATE_EPOCH` | zweimal aus frischem Baum: **bytegleich**, sha256 `8c1d34422c3fa4e5ede717630ca98bf1c82cefe28d4130f62f4d964fd0c8f0dd`, 610 445 Bytes, Kennung `FM-1_851`, App 578 032 Bytes, in der App „FELUCCA v1.1“ und „Oct 29 2026“ |
| Update-Loader (`tests/ldr_test.c`) mit den echten Paketen | Vizzbox 1.0 → 1.1 und 1.1 → 1.0: **loader test passed**, je mit „the favourites' sectors 0x95000..0x96FFF kept“ |
| Installer (`web/test_vizzbox_installer.mjs`) mit dem Release | über Vizz 1.0/1.x, Skiff 1.4, Entwicklungs-Build: Sicherung, Frage, Installation, Umwandlung; über Vizz 2.0, Skiff 2.0.1, Vizzbox 1.0 und 1.1: nur installiert; Vizz 2.0s Installer über beiden Vizzboxen; **der Installer der 1.0 über einer 1.1: nur installiert, danach `FM-1_850`**: **all ok** |
| Geänderte Goldens (alle beabsichtigt) | Skiffs UI-Golden: 751 von 3 388 Bildern – QUARKs Zierwerk (Patch 0017) und die 42 Bilder mit der Versionsnummer (ABOUT, ABOUT bei Aufnahme, Startbild; Patch 0023); VIZZBOX-Bildschirme: 42 geändert (SONG mit dem Rahmen der Fokus-Spur in `vb_ready`, `vb_techno_ready`, `vb_playing`, `vb_muted_t2`, `vb_saved_message`, `vb_stopped`; `vb_groovebox`: die GROOVEBOX auf der zuletzt gewählten Spur, Abschnitt 12), 60 neu (zehn Szenen der 1.1 × sechs Paletten); die 176 Regressions-Renders und das Golden der 1.0-Songs unverändert |

## Offen

- **Eine echte FM-1:** Alles ist auf dem Rechner geprüft (Abschnitt 12). Vor dem Weitergeben einmal auf einem Gerät
  installieren, 1.0 → 1.1 → 1.0 mit Favoriten, und die schwerste Wahl anhören (PHYS oder VOICE auf allen Spuren).
