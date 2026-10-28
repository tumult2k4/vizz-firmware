# Firmware-Spezifikation: Songteile über SEQ MIDI OUT (CC 104–109)

Ergänzung zu Vizz 2.0 (`docs/FIRMWARE-MUTE.md`: Noten, CC 102, Clock, Start/Stop, CC 123, CC 103). Umgesetzt in der
Vizzbox 1.0 (`patches/0007…`, `firmware/src/producer_isr.c` im Skiff-Baum). Ziel: Ein Visualizer (VIZZ) oder eine DAW
weiß jederzeit, **wo im Song** der Produzent gerade ist: welcher Songteil, wie viel Energie, welcher Takt davon, wie
lang er ist, welches Genre und Subgenre. So kann der Empfänger einen Drop vorhersehen, statt ihn erst an den Noten zu
erraten.

Alles von Vizz 2.0 bleibt **unverändert**. Die Vizzbox fügt nur sechs Controller auf einem festen Kanal hinzu.

## Wann gesendet wird

- Nur wenn **SEQ MIDI OUT = ON** (MENU, wie bei Vizz 2.0) und nur über USB-MIDI.
- Nur solange **der Produzent die Spuren spielt**, also im VIZZBOX-Modus nach PLAY (und weiter, wenn man während des
  Spielens mit HOME + PLAY in die GROOVEBOX schaltet, bis zum Stopp).
- In der GROOVEBOX ohne laufenden Produzenten: **nichts davon**. Beim Wechsel in die GROOVEBOX einmal CC 104 = 0.
- **MIDI-Kanal 16**, fest. Liegt eine Spur ebenfalls auf Kanal 16, stört das nicht: Ihre Controller sind andere
  (CC 102, 103, 123), ihre Noten sind Noten.

## Die sechs Controller

| CC | Inhalt | Werte |
|---|---|---|
| **104** | Songteil | 0 = kein Song / gestoppt, 1 INTRO, 2 GROOVE, 3 BUILD, 4 DROP, 5 BREAK, 6 OUTRO |
| **105** | Energie (die aktuelle, geglättete) | 0–127 |
| **106** | Takt im Abschnitt, ab 0 | 0–127 (größer bleibt 127) |
| **107** | Länge des Abschnitts in Takten | 1–127 (größer bleibt 127) |
| **108** | Genre | 0–9, Tabelle unten |
| **109** | Subgenre innerhalb des Genres | 0–5, Tabelle unten |

**CC 105, Energie:** Jeder Abschnitt hat eine Energie-Linie vom ersten bis zum letzten Takt (ein BUILD steigt, ein
BREAK fällt ab, ein späterer DROP liegt etwas höher als der erste). Der Regler ENERGY skaliert sie: bei 0 auf etwa ein
Drittel, bei 100 ganz. Innerhalb eines Takts läuft der Wert linear von seinem Anfangs- zu seinem Endwert, auf
16tel-Raster. Gesendet wird er nur, wenn er sich ändert, höchstens einmal pro 16tel.

**CC 106 / CC 107:** Auf der Eins jedes Abschnitts ist CC 106 = 0. Ist CC 106 = CC 107 − 1, läuft der letzte Takt des
Abschnitts, und mit der nächsten Eins beginnt der nächste. Damit lässt sich ein Drop einen Takt vorher ankündigen:
**CC 104 = 3 (BUILD) und CC 106 = CC 107 − 1** heißt fast immer: Der nächste Takt ist ein DROP. (Ausnahmen: In den
Formen T und V kann auf einen BREAK oder GROOVE direkt ein DROP folgen; im Ambient gibt es keinen DROP.)

**CC 108 / CC 109, Genre und Subgenre:**

| CC 108 | Genre | CC 109: Subgenres |
|---|---|---|
| 0 | HOUSE | 0 DEEP HOUSE, 1 TECH HOUSE, 2 ACID HOUSE, 3 FILTER HOUSE, 4 AFRO HOUSE, 5 DISCO HOUSE |
| 1 | TECHNO | 0 MINIMAL, 1 PEAK-TIME, 2 DUB TECHNO, 3 HARD TECHNO, 4 DETROIT, 5 MELODIC TECHNO |
| 2 | ELECTRO / SYNTHWAVE | 0 ELECTRO, 1 SYNTHWAVE, 2 ITALO DISCO |
| 3 | TRANCE | 0 PROGRESSIVE, 1 UPLIFTING, 2 PSYTRANCE, 3 GOA |
| 4 | BREAKS / UK GARAGE | 0 BREAKBEAT, 1 2-STEP, 2 SPEED GARAGE |
| 5 | DRUM & BASS | 0 LIQUID, 1 NEUROFUNK, 2 JUMP-UP, 3 JUNGLE |
| 6 | DUBSTEP | 0 DEEP DUBSTEP, 1 BROSTEP |
| 7 | HIP-HOP / LO-FI / TRAP | 0 BOOM BAP, 1 LO-FI, 2 TRAP |
| 8 | AMBIENT / DOWNTEMPO | 0 AMBIENT, 1 CHILL, 2 DUB |
| 9 | HARDSTYLE / HARDCORE | 0 HARDSTYLE, 1 GABBER |

## Zeitpunkte

1. **PLAY:** `FA` (Start), dann Vizz' sechs CC 103, dann **alle sechs** (CC 104 … 109), dann die Noten der ersten
   Eins.
2. **Jede Takt-Eins:** **alle sechs**, **vor** der ersten Note dieser Eins. Das deckt ab: CC 104, 106 und 107 zu
   Beginn jedes Abschnitts, CC 106 auf jeder Eins und die Resynchronisation einmal pro Takt (wie CC 103). Ein
   Empfänger, der mitten im Song dazukommt, kennt den Stand spätestens nach einem Takt.
3. **Dazwischen:** nur CC 105, wenn sich die Energie ändert, höchstens einmal pro 16tel.
4. **SEQ MIDI OUT eingeschaltet oder USB verbunden**, während der Produzent spielt: **alle sechs** sofort (spätestens
   mit dem nächsten Audio-Block, ≈ 3 ms).
5. **Stopp** (PLAY gedrückt oder das Songende): `FC` (Stop), dann **CC 104 = 0**.
6. **In die GROOVEBOX** (HOME + PLAY im Stillstand): einmal **CC 104 = 0**.

Bei SEQ MIDI OUT = OFF wird keiner der sechs Controller gesendet, auch nicht beim Stopp.

## Was der Empfänger noch wissen sollte

- **Der Drop:** CC 104 = 4 kommt auf der Eins des Drops, vor dessen Kick. Der letzte Schlag des BUILD davor ist oft
  still (eine Pause vor dem Drop): Die Spuren klingen aus, Noten kommen keine. Das ist Absicht, kein Aussetzer.
- **Das Arrangement benutzt nicht das MUTE des Nutzers.** Lässt der Produzent eine Spur aus (Intro ohne Bass, Break
  ohne Kick), sendet sie einfach keine Noten; ihr CC 102 (Step-Index) läuft weiter. **CC 103 meldet weiter nur das
  MUTE und SOLO des Nutzers** (die schwarzen Tasten im VIZZBOX-Modus), genau wie in Vizz 2.0.
- **Neuer Stil während des Spielens** (Regler GENRE/SUB, ein neuer Seed, ein Favorit, ENDLOS): Der Produzent
  schiebt einen BREAK und einen BUILD ein und wechselt in der Pause vor dem Drop die Klänge. CC 108 und CC 109 nehmen
  die neuen Werte mit der Eins dieses Drops an. Das Tempo gleitet während BREAK und BUILD; die MIDI-Clock folgt ihm.
- **Externe Clock** (MENU > CLOCK): Das Tempo kommt dann von außen, der Produzent stellt es nicht. CC 104 … 109
  laufen wie oben.
- **Last:** sechs Controller pro Takt plus höchstens 15 × CC 105, vernachlässigbar.

## Beispiel

Ein Song in TECHNO / DUB TECHNO (CC 108 = 1, CC 109 = 2), das Ende eines 16-taktigen BUILD und die Eins des Drops
(Kanal 16, also Status `BF`):

```
BF 68 03   BF 69 5C   BF 6A 0F   BF 6B 10   BF 6C 01   BF 6D 02     Eins des letzten BUILD-Takts (15 von 16)
BF 69 5E   …                                                        CC 105 steigt im Takt
BF 68 04   BF 69 66   BF 6A 00   BF 6B 10   BF 6C 01   BF 6D 02     Eins des DROP (Takt 0 von 16)
9x 24 64   …                                                        dann die Kick und die übrigen Noten
```

## Geprüft

`tests/producer_test.c` im Skiff-Baum (läuft in `tests/run_tests.sh`): in jedem der 36 Subgenres ein ganzer Song,
jeder Takt: alle sechs auf Kanal 16 auf der Eins vor den Noten, CC 106 zählt, CC 107 passt zur Länge, CC 105
höchstens einmal pro 16tel; jeder DROP: CC 104 = 4 vor der Kick auf seiner Eins; PLAY: Start, sechs CC 103, dann
die sechs; Stopp: CC 104 = 0; SEQ MIDI OUT OFF: nichts davon, beim Einschalten während des Spielens alle sechs
binnen 10 ms, ebenso wenn USB wiederkommt; die GROOVEBOX: nichts davon; ein Arrangement-Aussetzer
sendet kein CC 103.
