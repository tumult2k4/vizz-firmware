# Auftrag: Vizzbox 1.0 – eine FM-1-Firmware, die selbst elektronische Musik produziert

Stefan ist kein geübter Produzent elektronischer Musik. Er möchte eine Firmware für seine M-VAVE FM-1, bei der er mit
den Reglern im Wesentlichen nur **Genre** und **Subgenre** wählt, **PLAY** drückt – und die Firmware produziert und
spielt live einen kompletten Track: Patterns, Sounds, Aufbau, Drops, Breaks, Übergänge. Dazu sendet sie, wie die
Vizz-Firmware, alles über USB-MIDI an seinen Browser-Visualizer VIZZ (Noten je Spur, Steps, Takt, Mute/Solo).

Das Konzept steht in [docs/VIZZBOX.md](docs/VIZZBOX.md). Dieser Auftrag legt fest, was gebaut wird. Wo er etwas offen
lässt, entscheiden und in `CHANGES.md` begründen.

**Grundprinzip:** Die Vizzbox ist **kein neuer Synthesizer**, sondern ein **Produzent**, der auf der Groovebox sitzt.
Er schreibt Patterns in Skiffs Sequencer, wählt Sounds, legt das Arrangement an und bedient Mutes, Scenes und Effekte
so, wie es ein Mensch live täte. Die Klangerzeugung bleibt die von Skiff. Der Produzent läuft im **Steuertakt** (pro
Step, Takt, Abschnitt), nicht im Audio-Interrupt; das Audio-Budget ist schon zu rund 90 % belegt.

## 1. Basis

Vizzbox = **Vizz 2.0** (Branch `vizz-2.0` dieses Repos: Skiff `v2.0.1` + fünf Patches) + der Produzent.

```
git clone https://github.com/illuminus5/skiff.git skiff
cd skiff
git checkout -b vizzbox-1.0 v2.0.1
git am -3 <patches/ von origin/vizz-2.0>/*.patch    # danach: Vizz 2.0, alle Tests grün (build-vizz.sh als Vorlage)
```

- **Alles von Vizz 2.0 bleibt** und funktioniert unverändert: SEQ MIDI OUT (Noten, CC 102, Clock, Start/Stop,
  CC 123), CC 103 Mute-Status, gemeinsames MUTE/SOLO, MENU › MIDI › SEQ MIDI OUT. Details: `CHANGES.md` auf `vizz-2.0`.
- **Die volle Groovebox bleibt erreichbar** (Skiffs ganze Oberfläche, im Folgenden „GROOVEBOX“). Die Vizzbox ist eine
  zusätzliche Ebene, kein Ersatz – es sei denn, der Platz zwingt zu Streichungen (Abschnitt 7).
- **Speicherformate unverändert** gegenüber Skiff 2.0: Wer zwischen Vizz 2.0 und Vizzbox wechselt, behält Projekte,
  Patterns, User-Sounds, Einstellungen. Neue Daten (Favoriten, Abschnitt 2.4) in einem eigenen Objekt, das Vizz 2.0
  und Skiff 2.0.1 ignorieren (testen).
- **Die gespeicherten Projekte des Nutzers fasst der Produzent nie an.** Er arbeitet in einem eigenen Arbeitsbereich
  (z. B. ein reservierter Arbeitsprojekt-Zustand im RAM bzw. reservierte Patterns); gespeichert wird nur, was der Nutzer
  ausdrücklich speichert.

## 2. Bedienung

### 2.1 Start und Modi

- Nach dem Einschalten zeigt die FM-1 den **VIZZBOX-Bildschirm**. Eine eindeutige Taste bzw. Kombination (Vorschlag:
  HOME lang halten; mit Skiffs Tastenbelegung abgleichen, keine Kollision) wechselt in die **GROOVEBOX** und zurück.
  Der zuletzt benutzte Modus bleibt beim nächsten Start (Einstellungsbit).
- Läuft ein Song und man wechselt in die GROOVEBOX, spielt er weiter. Optional (wenn Platz): **„Song übernehmen“** –
  der aktuelle Abschnitt liegt dann als normale Patterns in der GROOVEBOX und lässt sich dort bearbeiten und speichern.

### 2.2 Regler und Tasten im VIZZBOX-Modus

| Bedienelement | Funktion |
|---|---|
| Regler 1 | **GENRE** (10, Abschnitt 4) |
| Regler 2 | **SUBGENRE** (je Genre 2–6) |
| Regler 3 | **ENERGIE** 0–100: wie intensiv der Song wird – Dichte, Zahl der Elemente, Effekte, wie hart die Drops sind. Bei 0 bleibt er gemütlich, bei 100 voll auf die Zwölf. |
| Regler 4 | **VARIATION** 0–100: wie stark sich der Song wandelt – bei 0 wiederholen sich Abschnitte fast identisch, bei 100 neue Motive je Abschnitt, mehr Fills, überraschendere Übergänge. Die Form bleibt. |
| SELECT drehen | **TEMPO** (Standard: vom Subgenre und Seed gewählt; ± innerhalb sinnvoller Grenzen, 1 BPM-Schritte) |
| SELECT drücken | **LÄNGE**: KURZ (~3 min) / NORMAL (~5–6 min) / ENDLOS |
| MASTER | Lautstärke (wie bisher) |
| PLAY | Start / Stopp. Beim Start ohne Song wird einer aus Genre, Subgenre und Seed erzeugt. |
| eine Taste (Vorschlag: REC) | **NEU**: neuer Seed. Gestoppt → neuer Song; beim Spielen → ab dem nächsten Abschnitt. |
| SAVE | aktuellen Song als **Favorit** speichern (Abschnitt 2.4) |
| schwarze Tasten | **MUTE / SOLO** wie in Skiff (tippen, halten, mit GLO solo) – über CC 103 wie in Vizz |
| weiße Tasten | mitspielen mit dem Sound der LEAD-Spur, **auf die Skala des Songs eingerastet** |
| drei Tasten (zuordnen, z. B. FX / ARP / SEQ) | **DROP JETZT** (kurzer Aufbau von 4 bzw. 8 Takten, dann Drop), **BREAK JETZT** (ab dem nächsten Takt), **HALTEN** (aktuellen Abschnitt loopen, bis erneut gedrückt) |

- Genre, Subgenre, Energie oder Variation **während der Wiedergabe** ändern: wirkt am **nächsten Abschnitt** (bei
  Genre/Subgenre mit Übergang wie ein DJ: Break/Aufbau in den neuen Stil, Tempo gleitet über 8–16 Takte), nicht abrupt.
  Energie darf zusätzlich sofort sanft auf Filter und Dichte wirken.
- Mit externer Clock folgt die Vizzbox dem Tempo von außen (TEMPO-Regler dann ohne Wirkung, Anzeige „EXT“).

### 2.3 Bildschirm (240×240)

Genre und Subgenre, BPM, Tonart, der aktuelle Abschnitt mit Taktzähler (z. B. `BUILD 12/16`), die **Energiekurve des
ganzen Songs** mit Playhead, die sechs Spuren mit Rolle (DRUMS, BASS, CHORDS, LEAD, ARP, FX), ob sie gerade spielen und
ob sie stumm/solo sind, der Seed (4 Hex-Stellen), beim Drehen eines Reglers groß dessen Wert. In Skiffs Paletten und
Schriften, UI-Goldens für alle neuen Bildschirme.

### 2.4 Favoriten

Mindestens **16 Favoriten**, dauerhaft gespeichert (übersteht Ausschalten und Firmware-Update auf eine neue Vizzbox).
Ein Favorit ist nur: Genre, Subgenre, Seed, Energie, Variation, Tempo, Länge – also ein paar Bytes. Ein Favorit spielt
denselben Song **bitgleich** wieder ab (Abschnitt 3.2). Speichern und Abrufen per SAVE + weiße Taste o. ä.; Liste auf
dem Bildschirm.

### 2.5 ENDLOS

Wie ein DJ-Set: Zyklen aus Break/Aufbau/Drop mit Mutationen; nach 4–8 Minuten Wechsel in ein **verwandtes Subgenre**
(gleiches Genre oder Tempo-Nachbar, Liste in der Tabelle), über einen Break/Aufbau, Tempo gleitet höchstens
±8 BPM über 16 Takte. Läuft beliebig lange ohne Speicherwachstum.

## 3. Der Produzent

### 3.1 Spuren und Rollen

| Spur | Rolle | Engine / Inhalt | Stimmen (Richtwert) |
|---|---|---|---|
| T1 | DRUMS | DRUM bzw. DRUM-X, Kit je Genre, alle Lanes (Kick, Snare, Clap, Hi-Hat zu/offen, Perc/Tom, Ride, Crash) | wie Skiffs Drum-Spur |
| T2 | BASS | aus den BASS-Sounds, mono | 1 |
| T3 | CHORDS | Pad, Stab, Piano, Pluck | ≤ 4 |
| T4 | LEAD | Hook/Melodie | 1–2 |
| T5 | ARP | Arp, zweites Element, Perc-Loop | 1 |
| T6 | FX | Riser (NOISE), Downlifter, Impacts, Atmo | 1 |

MIDI-Kanäle wie in Vizz (T1..T6 CHANNEL). Ein **Stimmenbudget je Genre** sorgt dafür, dass im Drop mit allen
Elementen nicht hörbar Stimmen gestohlen werden (8 Stimmen, 12 mit zweitem Kern – Vizz 2.0 baut mit zweitem Kern).

Das Arrangement schaltet Spuren über **eigene Steuerung** ein und aus (leere Steps, Pattern-Wechsel, Launch), **nicht**
über das MUTE des Nutzers: MUTE und SOLO gehören dem Nutzer, wirken immer zusätzlich, und CC 103 meldet weiter genau
sie (wie in Vizz). Eine Spur, die das Arrangement gerade pausiert, sendet einfach keine Noten.

### 3.2 Determinismus

Ein Song ist eine Funktion von (Genre, Subgenre, Seed, Energie, Variation, Tempo, Länge) – und von den Live-Eingriffen
in ihrer Reihenfolge. Gleiche Eingaben ⇒ **bitgleiche** MIDI-Ausgabe und bitgleiches Audio. Eigener kleiner PRNG
(xorshift/PCG), **getrennte Ströme je Spur und Abschnitt**, damit eine Änderung an einer Stelle nicht alles
Nachfolgende verschiebt.

### 3.3 Generatoren

- **Drums:** je Subgenre ein Wahrscheinlichkeitsraster 16 Steps × Lane (0–255), dazu feste **Anker** (z. B. Four-on-
  the-Floor in House/Techno, Snare auf 3 im Halftime). Energie skaliert die Dichte. Ghost-Notes mit kleiner Velocity,
  Hi-Hat-Akzentmuster, Swing je Genre. **Fills** im letzten Takt jeder 8/16-Takt-Phrase (eigener Generator oder Skiffs
  FILL-Bedingung). Breakbeat-Genres: typische Breakbeat-Rhythmen als Raster; für Jungle/Breakbeat zusätzlich Skiffs
  **CC0-Breaks über SLICE**, falls sie im Build liegen (`ATTRIBUTION-BREAKS.txt`). Als Ideenquelle erlaubt:
  Mutable Instruments **Grids** (MIT-Lizenz; bei Übernahme von Code oder Tabellen die Lizenz mitliefern und nennen).
- **Bass** (Stile): ROOT (Grundton auf Zählzeiten), OFFBEAT (Achtel-Offbeat), ROLLING (16tel, setzt auf der Kick aus),
  ACID (16tel mit Slides und Akzenten, Cutoff-Automation), WOBBLE (lange Noten, LFO auf den Filter in 1/4–1/16 im
  Takt), SUB (lange Subnoten hinter der Kick), REESE (verstimmt, lang), OCTAVE (Disco-Oktavsprünge), 808 (lange
  Noten mit Glide). Folgt dem Akkordgrundton; trifft die Kick nur, wo der Stil es will.
- **Akkorde:** Progressionen je Genre als Stufen (1, 2, 4 oder 8 Takte je Akkord), Voicings über Skiffs
  Akkord-Funktionen; Rhythmen PAD (gehalten), STAB (kurz, Offbeat/synkopiert), PLUCK (Achtel), GATE (Trance-Gate über
  SLICER oder 16tel), PIANO (House-Piano, synkopiert).
- **Lead/Hook:** ein Motiv aus 1–2 Takten (Stufen der Skala, Rhythmuszelle aus dem Genre), Phrasen **A A′ A B** oder
  Frage/Antwort über 4 Takte. Das Motiv **kehrt im ganzen Song wieder** und wird in späteren Drops variiert (Oktave,
  zusätzliche Töne) – nicht ständig neu erfinden. Auf betonten Zählzeiten bevorzugt Akkordtöne.
- **Arp:** Skiffs Arpeggiator über den aktuellen Akkord, Modus und Rate aus der Tabelle.
- **FX:** Riser (NOISE-Engine, HPF und Lautstärke steigen über den Aufbau), Downlifter nach dem Drop-Einsatz,
  Impact/Crash auf der Eins des Drops, Reverse-Effekt vor dem Drop (REVERSE).

**Regeln für Musik statt Zufall** (im Code durchsetzen, in Tests prüfen, wo messbar):

- Alles in Phrasen von 4/8/16 Takten; Änderungen nur an Phrasengrenzen.
- Im Intro und im Aufbau kommt höchstens etwa alle 8 Takte ein neues Element dazu.
- Der Drop ist der größte Kontrast nach dem Aufbau, auf Wunsch mit einem Moment Stille davor (1 Beat bis 1 Takt).
- Tonart und Skala bleiben im Song gleich (Ausnahme: Subgenre-Wechsel im ENDLOS-Modus).
- Register trennen: Bass unter etwa C3, Akkorde C3–C5, Lead C4–C6.
- Höchstens zwei dichte melodische Elemente gleichzeitig.
- Velocity leicht menschlich variieren.

### 3.4 Sounds

Aus den 148 Werks-Sounds nach Tag und Rolle, je Genre eine Vorzugsliste (2–4 Kandidaten je Rolle; der Seed wählt).
Die Listen durch **Rendern und Auswerten** erstellen (Pegel, Spektrum, Tonumfang), nicht raten. User-Sounds werden nicht
verändert. Kits: Skiffs DRUM-/DRUM-X-Kits je Genre (z. B. 909-artig für House/Techno, 808-artig für Electro/Trap).

### 3.5 Arrangement

Abschnittstypen: **INTRO, GROOVE, BUILD, DROP, BREAK, OUTRO**. Jeder Abschnitt hat eine Länge in Takten und eine
Ziel-Energie 0–1; welche Spuren spielen und wie dicht, folgt aus Energie und Rolle (Tabelle je Genre). Formen für
LÄNGE NORMAL (KURZ kürzt Abschnitte bzw. lässt Wiederholungen weg, ENDLOS siehe 2.5):

| Form | Abschnitte (Takte) |
|---|---|
| **D** Drop-Form | INTRO 16 – GROOVE 16 – BUILD 8 – DROP 32 – BREAK 16 – BUILD 16 – DROP 32 – OUTRO 16 |
| **T** Techno | INTRO 32 – GROOVE 32 – BUILD 16 (Spannung: Filter zu, nur Hats/Perc) – DROP 32 – BREAK 8 – DROP 32 – OUTRO 32 |
| **N** Drum & Bass | INTRO 32 (ohne volles Schlagzeug) – BUILD 8 – DROP 32 – BREAK 16 – BUILD 8 – DROP 32 (neue Bassvariante) – OUTRO 16 |
| **S** Dubstep | INTRO 16 – BUILD 8 – DROP 16 (Halftime) – BREAK 16 – BUILD 8 – DROP 16 – OUTRO 8 |
| **V** Strophe/Hook | INTRO 4 – GROOVE 16 – DROP 8 (als Hook) – GROOVE 16 – DROP 8 – BREAK 8 – DROP 8 – OUTRO 4 |
| **A** Ambient | INTRO 16 – GROOVE 32 – BREAK 32 – GROOVE 32 – OUTRO 16 (keine harten Wechsel, langsame Veränderung) |
| **H** Hard | INTRO 16 – BUILD 16 – DROP 32 – BREAK 32 (Melodie, „Climax“-Aufbau) – BUILD 16 – DROP 32 – OUTRO 16 |

**Werkzeugkasten für Übergänge** – mit Skiffs eigenen Mitteln (PERFORM, Scenes, Throws, FX-Layer, DUCK, p-Locks):

| Moment | Umsetzung |
|---|---|
| BUILD | HPF-Sweep nach oben über die Länge; Snare-/Clap-Roll über Ratchets 1/4 → 1/8 → 1/16 → 1/32 in den letzten 4 Takten; Riser auf T6; Reverb-Throw im letzten Beat; Kick fällt in den letzten 1–2 Takten weg (genreabhängig) |
| DROP | Kick und Bass zurück, alle Spuren, DUCK (Sidechain) in 4/4-Genres, Cutoff auf, Crash auf der Eins |
| BREAK | Kick und Bass raus (gestaffelt auf der Taktgrenze), Pad mit HALL, optional FREEZE; im Dub: Delay-Throws, SPRING |
| Übergänge | REPEAT als Stotter-Effekt im letzten Beat, Fills, Wechsel der Scene; TAPE STOP sparsam (höchstens einmal pro Song, nicht in jedem Genre) |
| Techno-Spannung | LPF auf den Drums langsam zu, Hats/Perc tragen, dann auf |

Erzeugt wird **abschnittsweise im Voraus** (spätestens im Takt vor dem Abschnitt), verteilt auf die Hauptschleife,
nicht im Audio-Interrupt. Was der Sequencer spielt, entsteht in seinen normalen Strukturen, damit Klang, SEQ MIDI OUT
und CC 102 genau wie bei einem von Hand programmierten Pattern funktionieren.

### 3.6 Mix

Pegel je Rolle und Genre so, dass kein Render clippt (Spitze < −0,3 dBFS) und die Genres ähnlich laut sind (RMS
innerhalb ±3 dB über alle Subgenre-Demos). DUCK, wo das Genre pumpt. Mit Renders prüfen.

## 4. Genres und Subgenres

Richtwerte; beim Tunen anpassen und Abweichungen in `CHANGES.md` nennen. Swing in % (50 = gerade). Daten als kompakte
Tabellen (Ziel: wenige KB für alle), kein Code je Genre.

| Genre | Subgenre | BPM | Swing | Drums | Bass | Harmonie / Akkorde | Lead / Arp | Form |
|---|---|---|---|---|---|---|---|---|
| **House** | Deep House | 120–124 | 54 | 4/4, Clap 2+4, offene Hat Offbeat, 16tel-Hats leicht | ROOT/OFFBEAT, rund | Moll 7/9, PAD + STAB | sparsam, weich | D |
| | Tech House | 124–128 | 52 | knackig, viel Perc und Tops | ROLLING, kurz | wenig, ein Akkord / Stab | Perc-Stab | D |
| | Acid House | 120–128 | 52 | 909-artig 4/4 | **ACID** (Hauptelement) | statisch | Acid ist der Lead | T |
| | Filter House | 122–126 | 54 | 4/4, Disco-Hats | OCTAVE | Dur/Moll 7, Akkord-Loop mit großen LPF-Fahrten | Stab | D |
| | Afro House | 120–124 | 57 | 4/4, viel Perc (Toms/Congas-Lanes), Shaker | ROLLING, synkopiert | Dorisch, Pads | Pluck/Marimba-artig | T |
| | Disco House | 118–124 | 55 | 4/4, offene Hat Offbeat | OCTAVE | Dur 7, ii–V–I, Piano/Strings | Riff | V |
| **Techno** | Minimal | 124–128 | 52 | sparsam, Klicks, Rimshots | kurze SUB-Noten | keine / ein Ton | kleine Blips | T |
| | Peak-Time | 128–134 | 50 | harte 4/4, Rumble, 16tel-Hats, Clap | ROLLING (Kick-Rumble) | dunkle Ein-Ton-Stabs | Riff, Acid optional | T |
| | Dub Techno | 118–124 | 52 | weiche Kick, Hat | SUB | Moll-Stab mit viel DELAY und Reverb (das Markenzeichen) | – | A |
| | Hard Techno | 140–150 | 50 | verzerrte Kick (DIST), 16tel-Hats, metallische Perc | Rumble | – | Noise-Stabs | T |
| | Detroit | 125–130 | 52 | 909/808 4/4 | ROOT/OFFBEAT | Moll 9, Strings | Synth-Lead | T |
| | Melodic Techno | 120–126 | 50 | 4/4, sparsam | ROLLING 16tel | Moll, epische Pads | Arp + Hook | D |
| **Electro / Synthwave** | Electro | 125–132 | 50 | 808-Electro (synkopierte Kick, Snare 2+4) | synkopierte 16tel | Moll | Robot-Lead, Arp | D |
| | Synthwave | 85–110 | 50 | Gated Snare (großer Reverb), 4/4 | ROOT in Achteln | i–VI–III–VII, breite Pads | Lead-Melodie, Arp | V |
| | Italo Disco | 115–125 | 50 | 4/4, Claps | OCTAVE in Achteln | Dur/Moll-Folgen | eingängiger Lead | V |
| **Trance** | Progressive | 122–128 | 50 | 4/4, offene Hat Offbeat | ROLLING Offbeat | Moll, lange Pads | Plucks, Arp | D |
| | Uplifting | 136–140 | 50 | 4/4 | OFFBEAT | i–VI–III–VII, GATE-Pads | große Lead-Melodie, langer Break mit Melodie | H |
| | Psytrance | 140–146 | 50 | 4/4, Kick-Bass-Bass-Bass | ROLLING (16tel nach der Kick) | Phrygisch, kaum Akkorde | Acid-Leads, FX | T |
| | Goa | 140–148 | 50 | 4/4 | ROLLING | Phrygisch / harmonisch Moll | melodische Acid-Leads, Arps | T |
| **Breaks / UK Garage** | Breakbeat | 128–135 | 52 | Breakbeat-Raster (+ CC0-Breaks) | ROLLING / WOBBLE | Moll | Stab / Lead | D |
| | 2-Step | 130–134 | 62 | 2-Step (springende Kick, Snare 2+4) | SUB / synkopiert | Moll 7/9, Stabs | kleiner Lead | V |
| | Speed Garage | 130–135 | 58 | 4/4, geshuffelte Hats | REESE / WOBBLE | Stabs | – | D |
| **Drum & Bass** | Liquid | 172–176 | 50 | DnB 2-Step mit Ghost-Hats | REESE / SUB, weich | jazziges Moll 9, Pads, Piano | weicher Lead | N |
| | Neurofunk | 172–176 | 50 | straff | REESE, FM-Growl (FM6 + DIST) | dunkel, minimal | FX | N |
| | Jump-Up | 174–176 | 50 | 2-Step | hüpfendes Bass-Riff | – | – | N |
| | Jungle | 160–170 | 50 | Breakbeat-Raster, CC0-Breaks über SLICE | SUB | Dub-Akkorde | – | N |
| **Dubstep** | Deep Dubstep | 138–142 | 50 | Halftime (Kick 1, Snare 3) | SUB, langsamer WOBBLE | Moll, dunkel | sparsam | S |
| | Brostep | 140–150 | 50 | Halftime | schneller WOBBLE + DIST, FM-Growl | – | – | S |
| **Hip-Hop / Lo-Fi / Trap** | Boom Bap | 86–96 | 60 | Boom-Bap, Achtel-Hats geswingt | ROOT | jazzig 7/9, Piano | – | V |
| | Lo-Fi | 70–90 | 60 | weich, LOFI-Engine, VINYL | ROOT, weich | Maj7/Moll 9, E-Piano | sparsame Melodie | V |
| | Trap | 130–150 (Halftime) | 50 | 808-Kick, Snare/Clap auf 3, Hat-Rolls (Ratchets, Triolen) | **808** mit Glide | Moll/Phrygisch | Bell/Pluck | V |
| **Ambient / Downtempo** | Ambient | 60–90 | – | keine oder sehr sparsam | Drones / SUB | lange Pads, langsame Wechsel, Lydisch/Maj7, GRAIN | sparsame Melodie | A |
| | Chill / Downtempo | 85–105 | 56 | weicher Beat | ROOT | jazzig | Lead | V |
| | Dub | 70–80 | 56 | One-Drop (Kick + Snare auf 3) | Dub-Bassline | Offbeat-Skank-Stabs mit Delay | Melodica-artiger Lead | A (Dub-Mischung: Delay-Throws, Mutes, SPRING) |
| **Hardstyle / Hardcore** | Hardstyle | 150–155 | 50 | verzerrte Kick mit Tonhöhen-Hüllkurve (DIST) | Reverse-Bass auf dem Offbeat | episches Moll | Screech/Lead | H |
| | Gabber | 170–190 | 50 | stark verzerrte 4/4-Kick | – | minimal | Hoover-artiger Lead | T |

Tonart je Song vom Seed aus einer genretypischen Auswahl. Tempo-Nachbarn für ENDLOS aus der Tabelle ableiten.

## 5. MIDI OUT

Alles von Vizz 2.0 unverändert (Noten, CC 102, Clock, Start/Stop, CC 123, CC 103). **Neu**, nur im VIZZBOX-Modus,
nur mit SEQ MIDI OUT ON, auf **MIDI-Kanal 16** (fest; kollidiert mit nichts, auch wenn eine Spur auf 16 liegt, denn
die Controller-Nummern sind andere):

| CC | Inhalt |
|---|---|
| **104** | Songteil: 0 = kein Song/gestoppt, 1 INTRO, 2 GROOVE, 3 BUILD, 4 DROP, 5 BREAK, 6 OUTRO |
| **105** | Energie 0–127 (die aktuelle, geglättete) |
| **106** | Takt im Abschnitt, ab 0 (höchstens 127) |
| **107** | Länge des Abschnitts in Takten (höchstens 127) |
| **108** | Genre 0–9 (Reihenfolge der Tabelle in Abschnitt 4) |
| **109** | Subgenre 0–n (Reihenfolge innerhalb des Genres) |

Gesendet:

- alle sechs beim Start (direkt nach `FA` und Vizz' sechs CC 103), beim Einschalten von SEQ MIDI OUT und beim
  USB-Verbinden;
- CC 104, 106, 107 zu Beginn jedes Abschnitts – **vor** der ersten Note seiner Eins;
- CC 106 auf jeder Takt-Eins;
- CC 105 bei Änderung, höchstens einmal pro 16tel;
- alle sechs einmal pro Takt zur Resynchronisation (wie CC 103);
- beim Stopp CC 104 = 0.

Im GROOVEBOX-Modus ohne laufenden Produzenten nichts davon (beim Wechsel einmal CC 104 = 0). Spezifikation zusätzlich
als `docs/VIZZBOX-MIDI.md` (für die Empfängerseite in VIZZ).

## 6. Name, Kennung, Installer

Wie Vizz 2.0 (Patch 0003), angepasst:

- Startbildschirm „Vizzbox / v1.0 / on Skiff 2.0.1 / Hügelton + community“; ABOUT „VIZZBOX“, „based on Vizz 2.0 /
  Skiff 2.0.1 / Felucca“; Credits beginnen mit VIZZBOX, alle Credits und Lizenzen von Skiff bleiben; Absturzbild,
  Update-Loader („THE VIZZBOX INSTALLER“; die 5×7-Schrift braucht ggf. B, O, X).
- Version `v1.0`. Kennung: Vorschlag **`FM-1_850`** (Vizz-Familie `FM-1_8XY`; der Installer von Vizz 2.0 behandelt
  `FM-1_8XY` mit X ≥ 2 wie Skiff 2.0, also passt das ohne Konvertierung). Entwicklungs-Builds nach Vizz' Schema.
  Prüfen und begründen.
- **USB-Namen und -Deskriptoren unverändert.**
- Paket `vizzbox-1.0.fwsc`, Installer `vizzbox-installer.html` als **eine** Datei mit Skiffs ganzer 2.0-Logik wie bei
  Vizz 2.0 (Backup und Konvertierung über Firmware vor 2.0 und über Vizz 1.x, Rückweg zur Original-Firmware V15).
  Über Vizz 2.0 und Skiff 2.0.1 kein Backup nötig, nur die Installation; ebenso umgekehrt (Vizz 2.0 über Vizzbox).
- Code-Bezeichner, Kommentare und Dateinamen des Quellbaums bleiben Skiffs; der Produzent bekommt eigene Dateien
  (z. B. `producer.c`, `producer_tables.c`, `ui_vizzbox.c`).

## 7. Platz und Leistung

**Zuerst messen**, bevor viel Code entsteht: Ausgangslage Vizz 2.0 = App 553 052 Bytes, **28 512 Bytes frei** im
App-Bereich (581 564 Bytes), RAM 79 924 / 98 304, Pool 346 500 / 356 352, Kosten der Render-Schleifen 7 598 / 8 441.
Aus der Map-Datei eine Liste der größten Brocken je Modul.

- Ziel: Produzent + Tabellen + UI passen, mit mindestens **2 KB Reserve**. Zustand im Pool (wie bei Vizz), RAM-Code
  nur, wo nötig.
- Reicht der Platz nicht: **nicht still Genres weglassen.** Erst den eigenen Code verkleinern (Tabellen statt Code,
  gemeinsame Generatoren), dann in der GROOVEBOX streichen – mit gemessener Ersparnis je Posten und Begründung in
  `CHANGES.md`. Kandidaten: selten genutzte Engines, die kein Genre braucht, Menüseiten, Hilfetexte, Demo-Inhalte,
  SMK-Unterstützung. **Nie** streichen: Update-Loader/Installer-Protokoll, Backup/Editor-Protokoll (der Installer
  braucht es), USB-MIDI, SEQ MIDI OUT, MUTE/SOLO, die Engines, die die Genre-Tabellen benutzen.
- Zweiter Kern bleibt an. `tests/target_budget.py`: im Budget, **auch im schwersten Genre-Drop** mit allen Effekten
  (dafür einen Messfall anlegen). Der Interrupt für Tasten/LEDs bleibt im Rahmen.

## 8. Hören, ohne zu flashen

Stefan soll die Ergebnisse hören können, bevor er installiert. Mit Skiffs Host-Render (dieselbe DSP wie im Gerät):

- Werkzeug `tools/vizzbox_render` (Host-Programm oder Skript): `GENRE SUBGENRE SEED ENERGIE VARIATION LÄNGE` →
  WAV und **Standard-MIDI-Datei** (alle sechs Spuren auf ihren Kanälen, dazu CC 102–109 genau wie über USB).
- **`demos/`** auf dem Branch: je Subgenre ein Ausschnitt von etwa 60 s **über einen BUILD in den DROP** als MP3
  (128 kbps; ffmpeg/lame bei Bedarf installieren) und die `.mid` des ganzen Songs (LÄNGE NORMAL). Dazu
  `demos/README.md` mit Liste (Genre, Subgenre, Seed, BPM, Tonart, Spitzenpegel, RMS). Die `.mid`-Dateien spielt der
  MIDI-Datei-Player von VIZZ ab.
- Wenn Skiffs **Browser-Emulator** das hergibt: eine Vizzbox-Fassung als eine HTML-Datei in `demos/`, in der man im
  Browser Genre, Subgenre und PLAY bedient und hört.
- Selbst prüfen, was messbar ist: kein Clipping, Lautheit, Tonart (Noten außerhalb der Skala nur, wo gewollt),
  Abschnittslängen, Kick und Bass nicht dauerhaft aufeinander, Pegelsprung am Drop, Stille vor dem Drop, Riser im Aufbau.

## 9. Tests

- **Alle Tests von Vizz 2.0 grün**, `seqmidi_test` unverändert bestanden, die **176 Regressions-Renders bit für bit**
  wie Skiff 2.0.1 (GROOVEBOX, Produzent nicht aktiv) und UI-Goldens nur dort geändert, wo beabsichtigt (aufzählen).
- **`tests/producer_test.c`**, mindestens:
  - Determinismus: gleicher Favorit ⇒ gleiche MIDI-Bytes und gleiches Audio (Hash); anderer Seed ⇒ anderer Song;
  - jedes Subgenre erzeugt einen ganzen Song in jeder LÄNGE ohne Fehler; Abschnittsfolge und -längen nach Form; BPM
    im Bereich; Noten in der Skala (Ausnahmen gekennzeichnet); Register der Rollen;
  - Stimmenbudget nie überschritten (keine gestohlenen Stimmen im Drop);
  - Drop: auf seiner Eins Kick (wo das Genre eine hat) und CC 104 = 4 genau in diesem Takt; der Aufbau davor hat
    Roll bzw. Riser;
  - CC 104–109: Werte, Kanal 16, Zeitpunkte, Resync pro Takt, nichts bei SEQ MIDI OUT OFF, nichts in der GROOVEBOX;
  - Regler während der Wiedergabe wirken am nächsten Abschnitt; DROP JETZT / BREAK JETZT / HALTEN;
  - MUTE/SOLO des Nutzers wirken weiter, CC 103 meldet nur sie, nicht das Arrangement;
  - ENDLOS: 60 simulierte Minuten ohne Speicherwachstum, mit Subgenre-Wechsel;
  - Favoriten: speichern, Ausschalten (simuliert), abrufen ⇒ derselbe Song; Vizz 2.0 / Skiff 2.0.1 lesen ein Gerät mit
    Favoriten-Objekt ohne Fehler;
  - Wechsel VIZZBOX ↔ GROOVEBOX, auch während der Wiedergabe;
  - Fuzzer: zufällige Folgen von Reglern und Tasten über lange Zeit, ASan/UBSan sauber.
- UI-Goldens für alle neuen Bildschirme in allen Paletten.
- Installer-Test wie bei Vizz 2.0, erweitert um Geräte mit Vizz 2.0 und Vizzbox.
- **Gegenprobe** (`tests/vizzbox_mutants.py`, wie `vizz_mutants.py`): absichtliche Verfälschungen (Determinismus
  gebrochen, CC 104 zu spät/nicht gesendet, Drop ohne Kick, Arrangement über das Nutzer-MUTE, Favorit nicht
  gespeichert …) lassen Tests fehlschlagen; die bestehenden Vizz-Mutanten weiter erkannt.

## 10. Vorgehen

Das ist ein großer Auftrag. In Etappen arbeiten und **nach jeder Etappe auf `vizzbox-1.0` pushen**:

1. Vizz 2.0 nachbauen (grün), Platz messen (Abschnitt 7), Zwischenstand in `CHANGES.md`.
2. Produzent-Kern auf dem Host: Generatoren, Arrangement, Determinismus, `vizzbox_render`; erste Renders.
3. Alle Genres und Subgenres als Tabellen, Sounds auswählen, tunen anhand der Renders und Messungen.
4. Bedienung und Bildschirm, Favoriten, Live-Eingriffe, ENDLOS.
5. MIDI OUT CC 104–109.
6. Name, Kennung, Installer.
7. Tests, Gegenprobe, Budget.
8. Release und Demos.

Endet die Sitzung, bevor alles fertig ist: in `CHANGES.md` genau festhalten, was steht, was getestet ist und was als
Nächstes kommt.

## 11. Ergebnis

Auf Branch **`vizzbox-1.0`** in diesem Repo committen und pushen:

- `out/vizzbox-1.0.fwsc`, `out/vizzbox-installer.html`, `out/SHA256SUMS`, Lizenzen und Attributionen wie bei Vizz 2.0
  (dazu die von Grids, falls übernommen)
- `patches/` = alle Commits ab `v2.0.1` (`git format-patch v2.0.1..vizzbox-1.0`, also Vizz' fünf und die neuen),
  durchnummeriert
- `build-vizzbox.sh` (nach `build-vizz.sh`)
- `CHANGES.md` auf Deutsch; **erste Zeile** `# Vizzbox 1.0 – Änderungen gegenüber Skiff 2.0.1` (die Web-App liest daraus
  die Basis). Inhalt: was Vizzbox gegenüber Vizz 2.0 ändert, die Entscheidungen, Kennung, Platz (vorher/nachher, was
  gestrichen wurde), Budget, Testergebnis, Update-Anleitung (von Vizz 2.0 und von Skiff 2.0.1)
- `docs/VIZZBOX-MIDI.md` (Abschnitt 5) und **`docs/VIZZBOX-ANLEITUNG.md`**: Bedienungsanleitung auf Deutsch für
  jemanden, der nicht produziert – was jeder Regler und jede Taste tut, Favoriten, ENDLOS, zurück in die GROOVEBOX
- `demos/` (Abschnitt 8)

Fertig ist es, wenn Build und alle Tests grün sind, alle Subgenres Demos haben und `vizzbox-1.0` gepusht ist. Falls etwas
nicht geht, genau sagen, was fehlt, statt abzukürzen.
