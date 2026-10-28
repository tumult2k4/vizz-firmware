# Vizzbox – Konzept: eine FM-1-Firmware, die selbst Musik produziert

**Vizzbox** ist eine geplante zweite Firmware für die M-Vave FM-1. Wie die Vizz-Firmware schickt sie alle
MIDI-Signale über USB raus (Noten, Steps, Takt, stumme Spuren) – aber sie spielt nicht nur ab, was man
programmiert hat, sondern **produziert elektronische Musik live**: Mit den Reglern wählt man im Wesentlichen nur
noch Genre und Subgenre, drückt **PLAY**, und die Firmware übernimmt den Rest – Patterns, Aufbau, Drops, Breaks,
Übergänge.

Stand: Brainstorming aus dem VIZZ-Repo (`docs/VIZZBOX.md` dort). Verbindlich für den Bau ist
[BRIEF-VIZZBOX.md](../BRIEF-VIZZBOX.md). Legende: ○ Idee · ? offene Frage

---

## 1. Grundidee: ein „Produzent“ auf der Groovebox

Die Vizzbox ist **kein neuer Synthesizer**, sondern ein Produzent, der auf der vorhandenen Groovebox sitzt: Er
schreibt Patterns in den Sequencer, legt das Arrangement an und bedient Mutes und Effekte so, wie es ein Mensch live
tun würde. Die Klangerzeugung bleibt, wie sie ist.

Der Produzent läuft **im Steuertakt** (einmal pro Step bzw. Takt), nicht im Audiopfad. Das Audio-Budget der
FM-1 ist mit der jetzigen Firmware schon zu rund 90 % ausgelastet; der Generator braucht dort praktisch nichts.
Deshalb ist das Projekt auf dieser Hardware überhaupt machbar.

## 2. Basis: Skiff 2.x, wieder als Fork

| Option | Bewertung |
|---|---|
| **Skiff 2.0.1** (illuminus5, GPL-3.0) | **Empfehlung.** Fast alle Bausteine für einen automatischen Produzenten sind schon da (siehe 2.1), und die Vizz-Patches (SEQ MIDI OUT, CC 102, CC 103, Clock) lassen sich direkt übernehmen. |
| Felucca (Hügelton Instruments, die Basis von Skiff) | Schlanker, aber es fehlt, was Skiff ergänzt hat: Song-Modus, PERFORM, FX-Layer, Trig-Bedingungen. |
| Original-Firmware von M-Vave | Nicht offen, scheidet aus. |
| Eigene Firmware von Null auf dem JieLi-AC79-SDK | Unrealistisch: Treiber, Audio, Display und Engines müsste man alle neu bauen. |

Die Vizzbox wäre damit wie Vizz ein Patch-Satz auf Skiff, nur mit einem großen zusätzlichen Modul.

### 2.1 Was Skiff schon mitbringt

| Baustein | Wofür der Produzent ihn nutzt |
|---|---|
| 14 Klang-Engines, 148 Werks-Sounds mit Tags (BASS, LEAD, PAD …) | „nimm einen Bass“ – Sounds nach Rolle und Genre wählen |
| DRUM / DRUM-X mit 8 Lanes, 5 VA-Kits | das komplette Schlagzeug auf einer Spur |
| 6 Spuren, 64 Steps, Akkorde bis 4 Noten | Drums, Bass, Akkorde/Pad, Lead, Arp, FX/Riser |
| Chance, Ratchets, 12 Trig-Bedingungen inkl. FILL, Nudge, Swing | Lebendigkeit, Snare-Rolls, Fills am Phrasenende |
| p-Locks / Automation | Filterfahrten, Akzente |
| Pattern-Pool, Listen pro Spur mit REPS, Ketten, SONG ONCE | das Arrangement als Song ablegen |
| PERFORM: Starts/Mutes auf LOOP/BAR/BEAT/NOW | Spuren sauber auf der Taktgrenze rein- und rausnehmen |
| 16 Scenes, Throws auf CUTOFF/REVERB/DELAY/DIST | Energie-Sprünge, Übergänge |
| LPF/HPF-Sweeps, DIST, INSERT, Delay, Reverb (ROOM/SPRING/HALL), DUCK | Aufbau, Drop, Sidechain-Pumpen |
| FX-Layer: REPEAT, REVERSE, TAPE STOP, FREEZE, GATE, DUB, VINYL … | Übergänge, Breaks |
| SEQ TOOLS RANDOM / EUCLID / COOK, Arp (14 Modi), Chord-Tasten, 16 Skalen | Rohmaterial für den Generator |

## 3. Architektur

```
Knöpfe ─► Genre-Tabelle ─► Arrangement-Engine ─► Pattern-Generator ─► Skiff-Sequencer / FX
                 ▲             (Energiekurve)          (Seed)              │
                 └──────────────── Seed / SAVE ◄───────────────────────────┤
                                                                           ▼
                                                        Audio + USB-MIDI (wie Vizz)
```

### 3.1 Genre-Tabellen

Jedes Subgenre ist ein kompakter Datensatz (geschätzt 100–200 Bytes), kein Code:

| Feld | Beispiel (Acid House) |
|---|---|
| BPM-Bereich, Swing | 120–126, leichter Swing |
| Skala / Modus | Moll, Phrygisch |
| Pool an Akkordfolgen | i–VII, i–iv, statisch |
| Drum-Grammatik | Wahrscheinlichkeit pro 16tel und Instrument (Four-on-the-Floor, offene Hi-Hat auf Offbeat, Clap auf 2 und 4) |
| Bass-Stil | Acid mit Slides und Akzenten |
| Sound-Tags pro Rolle | Bass: ANALOG/BASS, Pad: aus, Lead: keiner, Arp: ANALOG |
| Effekt-Vorlieben | Resonanz-Sweeps, Delay-Throws, DIST leicht |
| Form des Arrangements | lange Aufbauten, wenige harte Drops, Filter als Hauptwerkzeug |

○ Ideenquelle für die Drums: Mutable Instruments **Grids** (MIT-Lizenz). Dort entstehen Drum-Patterns durch
Interpolation in einer winzigen Pattern-Karte – ideal bei wenig Speicher.

### 3.2 Pattern-Generator

- **Drums:** Wahrscheinlichkeitsraster plus Euklid, Ghost-Notes, Fills am Phrasenende.
- **Bass:** folgt Akkord und Kick, damit der Groove stimmt (Offbeat, Rolling, Acid, Wobble, Sub).
- **Akkorde und Pads:** aus dem Progressions-Pool des Genres, Voicings über Skiffs Chord-Funktionen.
- **Lead:** ein Motiv in 4-Takt-Phrasen nach dem Muster Frage/Antwort. Es wird wiederholt und leicht variiert,
  nicht ständig neu erfunden – genau das macht den Unterschied zwischen „Musik“ und „Zufall“.
- **Arp:** Skiffs Arpeggiator auf den aktuellen Akkord.

Der Generator schreibt direkt in Skiffs vorhandene Pattern-Speicher; er hält selbst nur wenige KB Zustand.

### 3.3 Arrangement-Engine

Ein Zustandsautomat in Blöcken von 8, 16 oder 32 Takten:

`Intro → Aufbau → Drop → Break → Aufbau → Drop 2 → Outro`

Eine **Energiekurve** von 0 bis 1 bestimmt, welche Spuren laufen, wie dicht die Patterns sind, wo der Filter steht
und welche Effekte kommen. Jedes Genre bringt seine eigene Form mit (Trance: langer Break mit Melodie; Techno: kaum
Breaks, Spannung über Filter und Wegnehmen; DnB: Intro, harter Drop, zweiter Drop mit neuem Bass).

### 3.4 Seed

Alles wird deterministisch aus einem Seed erzeugt. Gefällt ein Song, speichert **SAVE** nur Genre, Subgenre und
Seed – ein paar Bytes. Der Song lässt sich jederzeit exakt wieder abspielen.

## 4. Drops, Breaks und Aufbau mit Skiff-Mitteln

| Moment | Umsetzung mit vorhandenen Funktionen |
|---|---|
| **Aufbau** | HPF-Sweep nach oben. Snare-Roll über Ratchets, die von 1/4 bis 1/32 schneller werden. Riser aus der NOISE-Engine mit Filterfahrt. Reverb-Throw am Ende. |
| **Drop** | Kick und Bass kommen zurück, alle Spuren laufen, DUCK als Sidechain, Cutoff auf, ein Crash. |
| **Break** | Kick und Bass werden über PERFORM gestaffelt stummgeschaltet. Pad mit HALL-Reverb, eventuell FREEZE. |
| **Übergänge** | TAPE STOP, REPEAT als Stotter-Effekt, Fills über die FILL-Bedingung, Wechsel der Scene. |
| **Lebendigkeit** | Chance, Trig-Bedingungen und kleine Pattern-Mutationen alle 8–16 Takte. |

## 5. Genres und Subgenres (Vorschlag)

| Genre | Subgenres | Machbarkeit auf der FM-1 |
|---|---|---|
| House | Deep, Tech, Acid, Filter/French, Afro, Disco | sehr gut |
| Techno | Minimal, Peak-Time, Dub, Hard/Industrial, Detroit, Melodic | sehr gut |
| Electro / Synthwave | Electro, Synthwave, Italo | sehr gut |
| Trance | Progressive, Uplifting, Psy, Goa | gut (Supersaws begrenzt durch die Stimmenzahl) |
| Breaks / UK Garage | Breakbeat, 2-Step, Speed Garage | gut |
| Drum & Bass | Liquid, Neurofunk, Jump-Up, Jungle | mittel (Jungle-Breaks bräuchten SLICE und Samples) |
| Dubstep | Deep/Classic, Brostep | mittel (Wobble über LFO auf dem Filter geht) |
| Hip-Hop / Lo-Fi / Trap | Boom Bap, Lo-Fi, Trap | gut (LOFI-Engine, Vinyl-FX) |
| Ambient / Downtempo | Ambient, Chill, Dub | sehr gut |
| Hardstyle / Hardcore | Hardstyle, Gabber | mittel (verzerrte Kick über DIST) |

Lieber zuerst 2–3 Genres richtig gut als zehn halbgar.

## 6. Bedienung

| Bedienelement | Funktion |
|---|---|
| Regler 1 | Genre |
| Regler 2 | Subgenre |
| Regler 3 | Energie – von gemütlich bis voll auf die Zwölf |
| Regler 4 | Variation (wie stark sich der Song wandelt) oder Länge (Kurz / Normal / Endlos) |
| SELECT | Tempo fein einstellen |
| MASTER | Lautstärke |
| PLAY | Start / Stopp |
| eine Taste (z. B. SEQ) | neuen Song würfeln (neuer Seed) |
| SAVE | aktuellen Song merken (Genre + Subgenre + Seed) |

○ **Live-Eingriffe** (optional): Tasten für „Drop jetzt“, „Break jetzt“ und „hier bleiben“. Schwarze Tasten für
Mute/Solo wie bei Vizz. Die Tastatur bleibt spielbar und ist automatisch auf die Skala des Songs eingerastet.

○ **Display** (240×240): Genre, aktueller Teil (z. B. `BUILD 12/16`) und die Energiekurve des Songs.

○ **Endlos-Modus:** wie ein DJ-Set. Nach einigen Minuten wechselt er sanft in ein verwandtes Subgenre.

## 7. MIDI-Out und die Verbindung zu VIZZ

Alles von Vizz bleibt: Noten auf den Spurkanälen, **CC 102** = Step-Index, MIDI Clock / Start / Stop,
**CC 123** bei Panic, **CC 103** = Mute-Status (siehe [FIRMWARE-MUTE.md](FIRMWARE-MUTE.md)). Neu dazu kämen:

| Nachricht | Inhalt |
|---|---|
| ○ **CC 104** | Song-Teil: Intro, Aufbau, Drop, Break, Outro (Wertebereich noch festzulegen) |
| ○ **CC 105** | Energie 0–127 |
| ○ **Program Change** | Genre / Subgenre |

Dann weiß die VIZZ-Web-App, *wann der Drop kommt*: Sie kann das Theme passend zum Genre wählen, die Visuals im
Aufbau hochfahren und im Drop explodieren lassen. Firmware und Web-App würden sich gegenseitig aufwerten.

## 8. Wie realistisch ist das?

Ausgangswerte aus der Vizz-2.0-Firmware (siehe `CHANGES.md` auf dem Branch `vizz-2.0`): 1 MiB Flash, App
553 052 Bytes mit **28 512 Bytes frei** im App-Bereich, RAM 79 924 / 98 304 Bytes, Pool 346 500 / 356 352 Bytes,
Audio-Render 7 598 / 8 441 (~90 %), 8 Stimmen (12 mit dem zweiten Kern).

| Bereich | Einschätzung |
|---|---|
| Generator-Logik und CPU | **Unkritisch.** Ein paar hundert Rechenschritte pro Step, die Klangerzeugung bleibt die vorhandene. |
| **Flash** | **Der Engpass.** Grob geschätzt braucht der Generator 10–20 KB Code und die Genre-Tabellen 3–6 KB – bei rund 28 KB frei ist das knapp. Weil die Vizzbox eine andere Bedienung hat, kann man vieles streichen: Step-Editor-Menüs, Aufnahme, selten genutzte Engines wie WHEEL, GRAIN oder VOICE. |
| RAM | Unkritisch für den Generator selbst (wenige KB). Der Pool ist allerdings schon fast voll. |
| Stimmen | 8 bzw. 12. Pro Genre braucht es ein Stimmenbudget, z. B. Drums auf einer Spur mit mehreren Lanes, Bass mono, Pad 3–4 Stimmen, Lead 1–2. |
| **Musikalische Qualität** | **Das eigentliche Risiko.** Technisch lösbar, aber „klingt richtig gut“ braucht viel Feintuning pro Genre. Realistisch: ein stilechter, abwechslungsreicher Groovebox-Live-Jam, kein Beatport-fertiger Track. |
| Testen | Flashen ist langsam – deshalb zuerst ein Prototyp im Browser (Phase 1). |
| Lizenz | Als Skiff-Fork ist die Vizzbox GPL-3.0. Wer Binärdateien weitergibt, muss den Quellcode zugänglich machen (wie bei Vizz). |
| Pflege | Bei neuen Skiff-Versionen müssen die Patches nachgezogen werden – das gilt heute schon für Vizz. |

**Fazit:** ehrgeizig, aber machbar – eher Monate als Wochen.

## 9. Reihenfolge

0. **Platz messen.** Im Skiff-Build (Map-Datei) nachsehen, was im Flash wie viel belegt und wie viel sich
   freimachen lässt. Davon hängt alles ab.
1. **Prototyp im Browser.** Den Generator in JavaScript bauen, neben oder in VIZZ, mit grober Web-Audio-Vorschau.
   Noch besser: Der Browser schickt die Noten per USB-MIDI an die FM-1 mit der jetzigen Vizz-Firmware – dann hört
   man sofort echte FM-1-Sounds, ohne zu flashen. Den Code „C-nah“ schreiben (Ganzzahlen, Tabellen), damit er
   sich leicht portieren lässt.
2. **Klang tunen.** House, Techno und eine dritte Richtung, bis es wirklich groovt.
3. **Portieren.** Den Generator als Modul (etwa `producer.c`) in den Skiff-Fork übertragen; er nutzt die
   vorhandenen Song-, PERFORM- und FX-Funktionen.
4. **Bedienung und Display.** Knöpfe, Anzeige, SAVE für Seeds, CC 104/105.
5. **Ausbauen.** Weitere Genres, Endlos-Modus, Live-Eingriffe.

## 10. Offene Fragen

- ? Wie viel Flash lässt sich durch Streichen von Menüs und Engines tatsächlich freimachen?
- ? Legt Skiff eingehende MIDI-Noten pro Kanal auf die Spuren? (Voraussetzung für den Prototyp mit echten FM-1-Sounds)
- ? Über welche internen Funktionen lassen sich Patterns, PERFORM-Staging und FX-Layer aus Code heraus steuern,
  ohne den Weg über die Bedienoberfläche zu gehen?
- ? Wie viele Stimmen bleiben im Drop mit allen Effekten übrig, ohne dass das Audio-Budget reißt?
- ? Separate Firmware oder ein zuschaltbarer „Vizzbox-Modus“ innerhalb von Vizz? (Platzfrage)
