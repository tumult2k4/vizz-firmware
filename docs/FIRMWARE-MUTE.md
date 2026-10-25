# Firmware-Spezifikation: Mute-Status über SEQ MIDI OUT (CC 103)

Ergänzung zum Skiff-Fork-Patch `0001-SEQ-MIDI-OUT-…` (SEQ MIDI OUT). Umgesetzt in der Vizz-Firmware (siehe `firmware/`). Ziel: Ein Visualizer (oder eine DAW) weiß
jederzeit, welche Spuren der FM-1 stumm sind, und bekommt von stummen Spuren keine Noten mehr.

Der Visualizer (VIZZ) wertet das bereits aus: Stumme Spuren werden in der Spurleiste durchgestrichen und mit „M"
markiert, ihre Figuren dimmen ab, ein „STUMM"-Schild erscheint, und ihre Noten werden ignoriert.

## Verhalten

### 1. Stumme Spuren senden keine Noten

- Ist eine Spur (effektiv, siehe unten) stumm, sendet SEQ MIDI OUT für sie **keine Note-Ons**.
- **Note-Offs gehen weiter raus**, damit keine Note hängen bleibt.
- Wird eine Spur stummgeschaltet, während sie Noten hält, kommt zuerst **CC 123 (All Notes Off)** auf ihrem Kanal
  (das gibt es im Patch schon als `seq_midi_alloff`).
- **CC 102 (Step-Index) läuft weiter**: Der Playhead einer stummen Spur bleibt sichtbar.

### 2. Neuer Controller CC 103 = Mute-Status

| | |
|---|---|
| Nachricht | Control Change **103** auf dem MIDI-Kanal der Spur (`trk_midi_ch`, folgt T1..T6 CHANNEL) |
| Wert | **127 = stumm**, **0 = hörbar** (Empfänger werten ≥ 64 als stumm) |
| Bedeutung | der *effektive* Zustand: die Spur ist stumm, wenn ihr MUTE gesetzt ist **oder** eine andere Spur solo ist und diese nicht (Skiff kennt Solo) |

Gesendet wird CC 103:

1. **sofort bei jeder Änderung** des effektiven Zustands – egal wodurch (Mute-Taste, Solo, Pattern- oder Songwechsel,
   Laden, Undo …),
2. **für alle sechs Spuren direkt nach Start** (nach `FA`),
3. **für alle sechs Spuren einmal pro Takt**, solange der Sequencer läuft (z. B. alle 96 MIDI-Clocks bzw. am
   Taktanfang). Damit kennt ein später verbundener Visualizer den Stand spätestens nach einem Takt,
4. **für alle sechs Spuren, wenn SEQ MIDI OUT eingeschaltet wird** (wenn einfach möglich auch beim Verbinden von USB).

Nicht gesendet, wenn SEQ MIDI OUT aus ist. Reihenfolge beim Stummschalten: erst CC 123 (falls Noten klingen), dann
CC 103 = 127. Beim Lautschalten: CC 103 = 0 vor der nächsten Note.

Last: höchstens 6 Controller pro Takt plus Änderungen – vernachlässigbar.

CC 103 ist wie CC 102 ein undefinierter Controller (MIDI-Spezifikation 102–119); ein Synth, der ihn hört, ignoriert ihn.

## Umsetzung (Vorschlag im Stil des Patches 0001, `firmware/src/seq.c`)

```c
#define SEQ_MUTE_CC 103u                            /* (SEQ MIDI OUT) a track's mute: 127 muted, 0 audible */
static uint8_t seq_mute_sent[NTRK];                 /* the state last sent; 0xFF = unknown, send it */

/* the effective mute: the track's MUTE (P_MUTE), or a solo on another track */
static int trk_silent(uint32_t ti)
{
    return trk[ti].p[P_MUTE] != 0 || (any_solo() && !trk_solo(ti));   /* the names as Skiff stores its solo */
}

static void seq_midi_mute(uint32_t ti, int force)
{
    uint32_t m = trk_silent(ti) ? 1u : 0u;
    if (!seq_midi_on || (!force && seq_mute_sent[ti] == m))
        return;
    if (m && trk[ti].seq_n)
        seq_midi_alloff(ti);                        /* what still sounds ends first */
    midi_out_event(0x0Bu | (0xB0u | trk_midi_ch(ti)) << 8 | SEQ_MUTE_CC << 16 | (m ? 127u : 0u) << 24);
    seq_mute_sent[ti] = (uint8_t)m;
}
```

- **`seq_midi_note`**: Note-Ons einer stummen Spur auslassen, Note-Offs immer senden:
  `if (!seq_midi_on || (vel && trk_silent(ti))) return;`
- **Änderungen erkennen**: in `events_block` einmal pro Block `for (i = 0; i < NTRK; i++) seq_midi_mute(i, 0);` –
  so ist jede Quelle (Taste, Solo, Song laden …) abgedeckt, ohne alle Stellen zu suchen, die MUTE setzen
  (6 Vergleiche pro Block).
- **Erzwungen senden** (`force = 1`) für alle Spuren: in `seq_start` nach `seq_midi_rt(0xFAu)`, einmal pro Takt (z. B. in
  `seq_clk_block` alle 96 Clocks oder beim Taktwechsel des Songs), und wenn SEQ MIDI OUT von OFF auf ON geht
  (`seq_mute_sent` dann auf `0xFF` setzen).
- Mit externer Clock (CLOCK ≠ INT) gelten 1. und die Änderungsmeldungen genauso; die Takt-Wiederholung kann dann
  am Takt des Songs hängen.

Im Skiff-Code nachzusehen: wo genau MUTE und SOLO gespeichert werden (der Test des Patches setzt `t->p[P_MUTE]`).

## Tests (Ergänzung zu `tests/seqmidi_test.c`)

1. T2 spielt, wird stummgeschaltet: danach **keine Note-Ons** auf Kanal 2, **genau ein CC 103 = 127** auf Kanal 2;
   hielt T2 eine Note, vorher **CC 123** auf Kanal 2.
2. T2 wieder laut: **CC 103 = 0**, danach wieder Note-Ons.
3. Start: direkt nach `FA` **sechs CC 103** (je Spur ihr Zustand, auf ihrem Kanal).
4. Ein Takt läuft: **sechs CC 103 pro Takt**.
5. SEQ MIDI OUT OFF: **kein CC 103**.
6. T2 CHANNEL 10: CC 103 von T2 auf **Kanal 10**.
7. Solo: T1 solo → CC 103 = 127 für T2..T6, CC 103 = 0 für T1; Solo wieder aus → CC 103 = 0 für alle
   nicht stummen Spuren, und ihre Noten kommen wieder.
8. CC 102 läuft für eine stumme Spur weiter (16 Step-CCs pro Takt bei 16 Steps).

## Prüfen mit dem MIDI-Monitor

`fm1-midi-monitor.html` oder VIZZ › Monitor öffnen, Clock und Step-CC ausblenden, Spur stummschalten: Es erscheint
`CC #103 = 127  Mute an` auf dem Kanal der Spur, und deren Noten hören auf. In VIZZ wird die Spur in der Spurleiste
durchgestrichen.

## Auftrag für die Firmware-Session (zum Kopieren)

> Erweitere SEQ MIDI OUT im Skiff-Fork um den Mute-Status nach `docs/FIRMWARE-MUTE.md` aus dem VIZZ-Projekt:
> (1) stumme Spuren senden keine Note-Ons mehr (Note-Offs schon, beim Stummschalten vorher CC 123 auf dem Spurkanal),
> CC 102 läuft weiter; (2) CC 103 auf dem Spurkanal meldet den effektiven Mute-Zustand (127 stumm, 0 hörbar, inklusive
> Solo) – bei jeder Änderung, für alle sechs Spuren nach Start, einmal pro Takt während der Wiedergabe
> und beim Einschalten von SEQ MIDI OUT; nichts davon, wenn SEQ MIDI OUT aus ist. Änderungen bitte pro Audio-Block per
> Vergleich mit dem zuletzt gesendeten Zustand erkennen. Ergänze `tests/seqmidi_test.c` um die Fälle 1–8 der
> Spezifikation und baue eine neue `.fwsc`.
