# Auftrag: Vizzbox 1.1 – Live-Kontrolle über die Tracks, die die Vizzbox gerade produziert

Stefan hat die Vizzbox 1.0 auf seiner FM-1 getestet: **Sie funktioniert einwandfrei.** Jetzt möchte er eingreifen,
während der Produzent spielt, wie ein Live-Act an der Groovebox: **Instrumente auf den Spuren auswechseln**, **Filter
und Modulatoren drehen**, **Effekte anwenden** und **auf den Tasten mitspielen**. Wenn danach Platz bleibt, kommen
**weitere Genres und Subgenres** dazu.

Wo dieser Auftrag etwas offen lässt, entscheide selbst und begründe es in `CHANGES.md`. Die Vizzbox 1.0 ist in
`BRIEF-VIZZBOX.md` und in `CHANGES.md` auf `vizzbox-1.0` beschrieben. Beides gilt weiter, soweit hier nichts anderes
steht.

**Grundprinzip „Hand drauf“:** Der Produzent komponiert weiter: Noten, Arrangement, Übergänge. Was der Nutzer anfasst,
gehört ihm, bis er es zurückgibt. Der Produzent lässt genau das in Ruhe und macht mit dem Rest weiter.

**Platz ist knapp.** In 1.0 sind 5 660 Bytes frei. Deshalb wird für die Live-Kontrolle so viel wie möglich von
**Skiffs eigener Oberfläche** benutzt statt neu gebaut: die Klangseiten und Karten, der Preset-Browser, der FX-Layer,
PERFORM, MOMENTARY, LFO/MOD und die GLO-Busse. Eine neue Klangerzeugung gibt es nicht. Neu sind nur die Weiche
dorthin und die Regeln „Hand drauf“.

## 1. Basis

Vizzbox 1.1 = **Vizzbox 1.0**, also Branch `vizzbox-1.0` dieses Repos: Skiff `v2.0.1` plus die Patches 0001–0014. Darauf
kommen die neuen Commits.

```
git clone https://github.com/illuminus5/skiff.git skiff
cd skiff
git checkout -b vizzbox-1.1 v2.0.1
git am -3 <patches/ von origin/vizzbox-1.0>/*.patch   # danach: Vizzbox 1.0, Paket bytegleich, alle Tests grün
```

`build-vizzbox.sh` von `vizzbox-1.0` dient als Vorlage. Die Basis bleibt Skiff 2.0.1; ein Wechsel auf Skiff 2.0.2/2.0.3
gehört nicht zu diesem Auftrag.

- **Alles von 1.0 bleibt** und funktioniert wie bisher: die SONG-Bedienung, Favoriten, ENDLOS, CC 104–109, die
  GROOVEBOX bitgleich mit Vizz 2.0, die Speicherformate und alles, was Vizz 2.0 sendet. **Wer nur antippt wie in 1.0,
  merkt keinen Unterschied.**
- **Ohne Eingriff dieselben Songs wie 1.0.** Ein Favorit ohne Live-Eingriff ergibt dieselben MIDI-Bytes wie in 1.0.
  Das Audio ist ebenfalls gleich, außer wo eine Änderung beabsichtigt und begründet ist. Stefans Favoriten sollen
  klingen wie gewohnt. Dafür das Golden aus 1.0 bauen (Abschnitt 9).
- **Nummern bleiben stabil.** Die 10 Genres und 36 Subgenres behalten ihre Nummern: die Reihenfolge auf den Reglern,
  in den Favoriten und in CC 108/109. Neue Subgenres kommen ans Ende ihres Genres, neue Genres hinter HARD.
- **Favoriten aus 1.0 überstehen das Update.** Wird über 1.1 wieder die 1.0 installiert, liest sie ihre Favoriten
  weiter (Abschnitt 3.9).

## 2. Hand drauf: wer was steuert

- **Der Produzent** steuert: Noten, Arrangement und Abschnitte. Dazu gehören seine eigenen Fahrten: Filter, Throws,
  Effekte des FX-Layers, Parameterfahrten (`vb_ctl.rp`) und der Klangwechsel bei einem neuen Stil (`vb_nx`, `vb_swap`).
- **Der Nutzer übernimmt** je Spur und je Parameter, was er anfasst. Danach gilt Folgendes:
  - **Einen gewählten Klang** behält die Spur, auch über einen neuen Stil, einen Favoriten oder einen Wechsel in ENDLOS
    hinweg. Der Produzent wechselt dann nur die Klänge der übrigen Spuren.
  - **An einem gedrehten Parameter** einer Spur fährt der Produzent nicht mehr, und ein Stilwechsel überschreibt ihn
    nicht. Andere Parameter und andere Spuren fährt er weiter.
  - **Performance-Steuerungen** sind gehaltene Effekte des FX-Layers, Makros, Throws und Skiffs `perf_k`. Solange der
    Nutzer hält oder dreht, gilt sein Wert. Lässt er los und ist der Wert über Skiffs RETURN zurückgegangen, macht
    der Produzent weiter. Er gleitet dabei vom aktuellen Wert aus, ohne Sprung.
- **Woher eine Änderung kommt, ist egal.** Es zählen die VIZZBOX-Seiten (Abschnitt 3), Skiffs Seiten in der GROOVEBOX,
  während der Produzent spielt, und MIDI-CCs von außen über Skiffs CC-Zuordnung. Mit einem MIDI-Controller lässt sich
  also live mitsteuern.
- **Zurückgeben:**
  - **HOME + schwarze Taste** gibt diese Spur zurück: Klang und Parameter so, wie der Produzent sie jetzt hätte.
  - **HOME + EDIT** gibt alle Spuren und Busse zurück.
  - Der Bildschirm zeigt, welche Spuren übernommen sind.
- **Die Noten hängen nicht vom Eingriff ab.** Übernahmen verändern keinen Zufallsstrom des Produzenten. Einzige Ausnahme:
  Klingt ein gewählter Klang länger, kann das Stimmenbudget anders ausdünnen. Dann fehlen Noten, aber es kommen nie
  andere dazu.
- **Wie lange eine Übernahme gilt:** über STOPP und PLAY hinweg, bis sie zurückgegeben wird, bis ein Favorit mit
  eigenen Klängen geladen wird oder bis zum Ausschalten. Sie liegt nur im RAM.
- **Die eigene Musik des Nutzers bleibt unberührt**, wie in 1.0. Übernahmen betreffen nur die Spuren des Produzenten
  und landen nie in einem Projekt, im Autosave oder im Pattern-Pool.

## 3. Bedienung

Die Tasten mit `firmware/src/panel.c` abgleichen. Erwartet ist, dass **SEL, EDIT und LFO** in der VIZZBOX frei sind.
Heißen sie anders oder ist eine belegt, sinngemäß zuordnen und das begründen.

### 3.1 Seiten

| Seite | öffnen | K1–K4 | SELECT | ALGORITHM | PRESETS |
| --- | --- | --- | --- | --- | --- |
| **SONG** (Start, wie 1.0) | – | GENRE, SUBGENRE, ENERGIE, VARIATION | TEMPO | LÄNGE | SEED |
| **KLANG** | EDIT antippen | Klangparameter der Fokus-Spur (3.3) | Seiten | Fokus-Spur | Klang der Fokus-Spur |
| **MOD** | LFO antippen | LFO/MOD der Fokus-Spur (3.4) | Seiten | Fokus-Spur | Klang der Fokus-Spur |

- Dieselbe Seitentaste noch einmal führt zurück zu SONG. Die Taste einer anderen Seite öffnet diese.
- Auf jeder Seite gleich wie in 1.0:
  - PLAY, REC (NEU)
  - FX, ARP und SEQ antippen
  - schwarze Tasten (MUTE/SOLO)
  - SAVE/GLO + weiße Taste (Favoriten)
  - HOME + PLAY und HOME lang (MENU)
  - OCT−/OCT+ (Oktave)

### 3.2 Fokus-Spur und Tasten

- **Eine Spur ist die Fokus-Spur**, am Anfang 4 LEAD. Gewählt wird sie auf KLANG und MOD mit ALGORITHM, wie in Skiff
  auf jeder Seite, und auf jeder Seite mit **SEL + schwarze Taste**. Der Bildschirm rahmt sie ein.
- **Die weißen Tasten spielen die Fokus-Spur** mit ihrem aktuellen Klang (in 1.0 immer LEAD):
  - **DRUMS:** Jede weiße Taste ist eine Lane: Kick, Snare, Clap, Hats … wie Skiffs Drum-Tastatur, ohne Einrasten.
  - **CHORDS:** Akkorde mit einem Finger. Jede weiße Taste spielt den Akkord der Tonart auf dieser Stufe, als
    Dreiklang oder Septakkord, wie der Stil voict.
  - **BASS, LEAD, ARP, FX:** einzelne Töne, eingerastet auf die Skala des Songs wie in 1.0.
- **Stimmen fürs Mitspielen** hält das Budget frei wie in 1.0.
- **Gespielte Töne** gehen mit SEQ MIDI OUT ON auf dem Kanal der Fokus-Spur hinaus, so dass VIZZ sie sieht. Mit dem
  Verhalten von Vizz 2.0 in der GROOVEBOX abgleichen und in `docs/VIZZBOX-MIDI.md` beschreiben.

### 3.3 KLANG (EDIT)

- **PRESETS wählt den Klang der Fokus-Spur.** Das ist Skiffs Preset-Browser, gefiltert nach der Rolle über Skiffs
  LIST-Typen:
  - DRUMS: die Kits (DRUM, DRUM-X)
  - BASS: BASS
  - CHORDS: PAD, KEYS, STRINGS …
  - LEAD: LEAD
  - ARP: PLUCK, LEAD, KEYS
  - FX: FX, NOISE …
- Die Liste beginnt mit den Klängen, die der Produzent für diesen Stil und diese Rolle vorsieht (markiert). Danach
  folgen alle übrigen des Typs.
- **HOME + PRESETS:** alle Werks- und User-Sounds, ungefiltert.
- Der neue Klang setzt am nächsten Step ein, auch mit Engine-Wechsel und ohne hängende Note oder Knacken; das geschieht
  über Skiffs normalen Weg, etwa `eng_req` und das Laden von FM6. Angezeigt werden Name und Engine des Klangs.
- **K1–K4 auf Seite 1 (LIVE):** die vier wichtigsten Regler für die Rolle.
  - Vorschlag: CUTOFF, RESONANZ, DECAY bzw. RELEASE und DRIVE bzw. DIST.
  - Wo die Engine sie nicht hat, sinngemäß: bei DRUM etwa TUNE, DECAY, DIST, TONE.
  - Die Auswahl aus Skiffs Parametertabellen treffen und begründen.
- **SELECT blättert durch alle Klangseiten**, die Skiff in der GROOVEBOX für die Engine dieser Spur hat, mit denselben
  Karten, Bereichen und Anzeigen:
  - Engine, Hüllkurven, Filter
  - Effekte der Spur: DIST, INSERT, SLICER, DUCK, SPREAD
  - Sends: REVERB, DELAY, CHORUS
  - Pegel und Panorama
  - bei DRUM/DRUM-X die Lane-Seiten (Tune, Decay, Pan, Pegel je Lane)
- Skiffs Seitentabellen und Zeichenfunktionen benutzen, keine eigene Kopie.
- Jede Änderung wirkt sofort und ist eine Übernahme (Abschnitt 2).

### 3.4 MOD (LFO)

- Skiffs LFO- und MOD-Seiten für die Fokus-Spur, SELECT blättert: LFO 1 und 2, ENV SYNC und die 11 Routen einschließlich
  der Matrix mit 4 Plätzen.
- **MOMENTARY** wie in Skiff: LFO halten und auf KLANG oder MOD einen Regler drehen. Die Änderung gilt nur, solange LFO
  gehalten wird, dann geht der Wert über RETURN zurück. Das ist keine Übernahme.

### 3.5 FX und ARP halten

- **FX halten** öffnet Skiffs FX-Layer unverändert:
  - Die weißen Tasten sind die 14 Effekte (REPEAT, FREEZE, OCT, GATE, DUB, FLANGE, VINYL, LPF/HPF-Sweep, TAPE STOP,
    REVERSE).
  - K1–K4 sind die Makros FILTER, CRUSH, THROW und DEPTH; die schwarzen Tasten schalten stumm.
  - Beim Loslassen geht alles über RETURN zurück. HOME + FX lässt den Layer offen, wie in Skiff.
  - „Halten“ heißt: länger als etwa 250 ms gedrückt, oder währenddessen eine Taste oder ein Regler benutzt.
- **FX antippen** löst wie in 1.0 DROP JETZT aus, jetzt beim Loslassen.
- **ARP halten** öffnet PERFORM:
  - K1–K4 sind die Throws CUTOFF, REVERB, DELAY und DIST. Sie gleiten über einen Takt zurück; mit OCT+ bleiben sie stehen.
  - Die weißen Tasten spielen die Fokus-Spur, denn Skiffs Listen und Scenes gelten in der VIZZBOX nicht.
- **ARP antippen** löst BREAK JETZT aus. SEQ bleibt HALTEN.
- Solange ein Eingriff des Nutzers wirkt, setzt der Produzent seine eigenen Effekte und Fahrten derselben Steuerung aus
  (Abschnitt 2).

### 3.6 GLO halten: Busse

- **GLO halten + K1–K4** steuert die Busse wie Skiffs GLO-Layer: die Pegel von REVERB, DELAY und CHORUS und so weiter.
  Mit SELECT kommen Typ und Zeit dazu, wie in Skiff.
- GLO + schwarze Taste (SOLO) und GLO + weiße Taste (Favorit laden) bleiben wie in 1.0.

### 3.7 In der GROOVEBOX, während der Produzent spielt

- HOME + PLAY während der Wiedergabe führt in die GROOVEBOX wie in 1.0, und der Produzent spielt weiter.
- Alle Klang-, LFO- und FX-Seiten von Skiff wirken dort auf seine Spuren und zählen als Übernahme. Zurück in der
  VIZZBOX bleiben sie erhalten.
- **Pattern bearbeiten** (SEQ-Seiten, REC) auf einer Spur des Produzenten: Er überschreibt den nächsten Takt. Entweder
  zeigt die FM-1 das kurz an (etwa „VIZZBOX SPIELT – PATTERN WIRD ÜBERSCHRIEBEN“), oder sie sperrt es. Entscheiden und
  begründen. „Song übernehmen“ ist weiterhin nicht verlangt.

### 3.8 Bildschirm und LEDs

- **Auf jeder Seite** oben Skiffs Karten für K1–K4, darunter die Grafik der Seite. In der Kopfzeile stehen Seite,
  Fokus-Spur und deren Klang.
- **SONG** wie in 1.0, dazu der Rahmen der Fokus-Spur und je Spur ein Zeichen für „übernommen“.
- **Beim Drehen** groß der Wert.
- **Beim Halten** von FX, ARP, GLO oder HOME zeigt die FM-1 die Karte des Layers, wie Skiffs SHIFT-Karte.
- **LEDs:** offene Seite, gehaltener Layer, Fokus-Spur.
- In allen sechs Paletten, mit Goldens.

### 3.9 Favoriten mit Klängen

- **SAVE + weiße Taste** speichert zusätzlich zu 1.0 je Spur:
  - den übernommenen Klang: Preset oder Platz des User-Sounds
  - die vom Nutzer geänderten Parameter, bis zu 8 je Spur; bei mehr die zuletzt geänderten
  - die Bus-Werte
- **Laden** stellt sie als Übernahmen wieder her. Ein Favorit ohne Übernahmen verhält sich wie in 1.0.
- Ein Favorit, der auf einen User-Sound-Platz zeigt, spielt, was jetzt dort liegt. Das in der Anleitung sagen.
- **Format:** Die Vizzbox 1.0 muss die Rezepte (Genre, Subgenre, Seed …) weiter lesen können, etwa über eine
  Erweiterung, die 1.0 überliest, oder über eine erhaltene VBF1-Kopie. Skiff 2.0.1 und Vizz 2.0 fassen die Sektoren
  weiterhin nicht an. Geschrieben wird nur im Stillstand, wie in 1.0.

## 4. Mehr Genres und Subgenres, wenn Platz bleibt

Erst wenn die Abschnitte 2 und 3 stehen. Dabei gilt:

- **Nummern:** Die bisherigen behalten ihre Nummern (Abschnitt 1).
- **Tabellen:** dieselben Tabellen wie in 1.0; vorhandene Generatoren wiederverwenden. Ein neuer Stil, etwa ein Raster
  oder ein Bass-Stil, nur dort, wo der Charakter ihn braucht (zum Beispiel Log-Drum-Bass oder Dembow-Raster).
- **Sounds:** durch Rendern und Messen ausgewählt, wie in 1.0.
- **Prüfung:** jedes neue Subgenre mit denselben Prüfungen wie in 1.0 und mit einer Demo; die Tempo-Nachbarn für
  ENDLOS ergänzen.
- **Reihenfolge:** so viele wie Platz haben, von oben nach unten. Ein höheres nur mit Begründung zugunsten eines
  tieferen überspringen. Die Richtwerte beim Tunen anpassen und Abweichungen nennen.

| # | Genre | Subgenre | BPM | Swing | Drums | Bass | Harmonie | Lead / Arp | Form |
|---|---|---|---|---|---|---|---|---|---|
| 1 | **AFRO & LATIN** (neu) | Amapiano | 110–116 | 56 | sparsame Kick, Shaker in 16teln, Rim/Holz-Perc, Claps neben der Zählzeit | **Log Drum**: perkussiver Bass mit Tonhöhenabfall, synkopiert | Dur/Moll 7/9, Pads, Piano | Pluck/Piano | V |
| 2 | AFRO & LATIN | Afrobeats | 100–112 | 55 | synkopierte Kick, Rim/Snare versetzt, Shaker, Congas | synkopiert | Dur 7 | Lead-Melodie, gitarrenartiger Pluck | V |
| 3 | AFRO & LATIN | Reggaeton | 88–100 | 50 | **Dembow**-Raster | ROOT/808 | Moll | Pluck/Lead | V |
| 4 | HIP-HOP | Drill | 138–145 (Halftime) | 50 | Halftime, Triolen-Hats, versetzte Kicks | **808 mit Slides** | harmonisch Moll, dunkle Strings | Bell/Piano | V |
| 5 | HIP-HOP | Phonk | 130–145 | 50 | 808-Kick, Clap, Hats | 808 verzerrt (DIST) | Moll/Phrygisch | **Cowbell-Melodie** | V |
| 6 | HOUSE | Progressive House | 124–128 | 50 | 4/4, offene Hat neben der Zählzeit, Clap 2+4 | ROLLING neben der Zählzeit | Moll, große Pads | Plucks, Arp | D |
| 7 | HOUSE | Bass House | 124–128 | 52 | 4/4, knackig | Growl (FM6 + DIST) | wenig | Stab | D |
| 8 | BREAKS | Bassline | 134–140 | 56 | 4/4 geshuffelt, Garage-Hats | WOBBLE/orgelartiges Riff | Moll | Stab | D |
| 9 | BREAKS | Grime | 138–142 | 50 | sparsam, Halftime-Gefühl | kurzer Square-SUB | Moll | Square-Lead, Pizzicato | V |
| 10 | TECHNO | Acid Techno | 135–145 | 50 | harte 4/4, 16tel-Hats | ACID verzerrt (Hauptelement) | statisch | Acid ist der Lead | T |
| 11 | TECHNO | Industrial | 128–138 | 50 | verzerrte Kick (DIST), Noise-Perc, Rumble | Rumble | – | metallische Noise-Stabs | T |
| 12 | TRANCE | Hard Trance | 140–150 | 50 | 4/4, Hats neben der Zählzeit, Clap | OFFBEAT/ROLLING verzerrt | Moll | Acid-/Hoover-Lead | H |
| 13 | DRUM & BASS | Halftime | 170–175 | 50 | Kick 1, Snare 3 im halben Tempo | REESE/SUB | dunkel | sparsam | N |
| 14 | DUBSTEP | Riddim | 140–150 | 50 | Halftime, minimal | WOBBLE + DIST, Triolen, repetitiv | – | – | S |
| 15 | DUBSTEP | Future Bass | 140–160 (Halftime) | 50 | Halftime, Snare 3, Rolls | SUB | Dur 7/9, große GATE-Supersaw-Akkorde mit DUCK | Pluck-Lead | S |
| 16 | HARD | Hardcore | 165–180 | 50 | verzerrte 4/4-Kick, Hats neben der Zählzeit | Hoover | Dur, Piano-Stabs | Piano/Hoover | H |
| 17 | HARD | Frenchcore | 190–200 | 50 | extrem verzerrte Kick (sie ist der Bass) | – | Moll, epische Pads | Lead | H |
| 18 | AMBIENT | Trip-Hop | 80–95 | 56 | staubiger Breakbeat (SLICE), VINYL | SUB/ROOT | Moll, dunkle Pads, Piano | sparsam | V |
| 19 | ELECTRO | Nu-Disco | 115–122 | 54 | 4/4, Disco-Hats, Claps | OCTAVE/funky Riff | Dur/Moll 7 | Riff, Stab | V |
| 20 | ELECTRO | Darksynth | 100–125 | 50 | harte 4/4 oder Gated Snare | verzerrter ROOT in 16teln | Moll | aggressiver Lead, Arp | D |
| 21 | BREAKS | Jersey Club | 138–145 | 50 | Kicks in Triolen-Gruppen (der typische Bounce) | SUB | Moll | Chop-artiger Pluck | V |
| 22 | AFRO & LATIN | Baile Funk | 125–135 | 50 | Tamborzão-Raster | 808 | – | – | V |

## 5. MIDI OUT

- Alles aus 1.0 bleibt unverändert. CC 108 und CC 109 bekommen die neuen Nummern; `docs/VIZZBOX-MIDI.md` nachführen.
- Gespielte Töne behandelt Abschnitt 3.2.
- Optional, wenn Platz bleibt: **CC 110** auf Kanal 16 meldet den gerade gehaltenen Effekt des FX-Layers. 0 heißt
  keiner, 1–14 folgen der Reihenfolge der Tasten; es zählt der Effekt des Nutzers wie der des Produzenten. Gesendet
  wird bei Änderung und zusätzlich auf jeder Takt-Eins, damit VIZZ Stotter- und Tape-Stop-Momente zeigen kann.

## 6. Name, Kennung, Installer

- **Vizzbox 1.1**, Kennung **`FM-1_851`** (Release X.Y ist `FM-1_8(X+4)Y`, Entwicklungs-Builds bleiben `FM-1_800`).
  Das Paket heißt `out/vizzbox-1.1.fwsc`, der Installer weiter `vizzbox-installer.html`, im Startbild steht „v1.1“.
- **Installer:** Über Vizzbox 1.0, Vizz 2.0 und Skiff 2.0.1 nur installieren. Über Älterem wie in 1.0 sichern und
  umwandeln. Zusätzlich 1.0 → 1.1 und zurück testen, auch mit Favoriten.

## 7. Platz und Leistung

**Ausgangslage 1.0:** App 575 904 Bytes, **5 660 frei**. Die Reserve von mindestens 2 KB bleibt. Was jede Funktion
kostet, laufend mit `tools/size_report.py` messen und in `CHANGES.md` aufführen.

**Rangfolge, wenn der Platz nicht für alles reicht:**

1. **A, Pflicht:**
   - Abschnitt 2 (Hand drauf)
   - 3.1–3.8: Seiten KLANG und MOD, Fokus-Spur, Tasten auf der Fokus-Spur, FX/ARP halten, GLO-Busse, GROOVEBOX und
     MIDI-CC als Übernahme, Zurückgeben, Bildschirm
2. **B:** 3.9 (Favoriten mit Klängen), Akkorde mit einem Finger und Lanes auf DRUMS, MOMENTARY.
3. **C:** Abschnitt 4 (mehr Subgenres), CC 110.

**Platz schaffen, in dieser Reihenfolge:**

1. **Skiffs Code statt eigenem:** Seiten, Browser und Layer gibt es schon.
2. **Den eigenen Code verkleinern,** ohne die Songs aus 1.0 zu ändern (Golden). Dazu gehören die rund 4,6 KB, die der
   Compiler in `ui_input.c` einbettet, und die 2,9 KB in `main.c`: `noinline` und Größe prüfen, Tabellen statt Code.
3. **In der GROOVEBOX, was auf einer FM-1 niemand vermisst:** Code, den der FM-1-Build nicht braucht (etwa
   SMK-37-Unterstützung, falls sie im FM-1-Build steckt), reine Entwicklungs- und Debug-Pfade, Demo-Inhalte und doppelte
   Texte. Jeden Posten mit gemessener Ersparnis in `CHANGES.md` aufführen.
4. **Nur für A,** wenn 1–3 nicht reichen: spürbare GROOVEBOX-Funktionen wie die Hilfetexte der SHIFT-Karte, die
   LARGE-Anzeige oder selten genutzte Menüseiten. Jeden Posten einzeln messen und begründen. **Nie nur für mehr
   Subgenres.**

**Nie streichen:**

- Update-Loader und Installer-Protokoll
- Backup- und Editor-Protokoll
- USB-MIDI, SEQ MIDI OUT, MUTE/SOLO
- **irgendeine Engine oder einen Effekt**, denn live kann jetzt jeder Klang gewählt werden

**Der Flash zwischen dem Ende des App-Bereichs (`0x93000`) und den Favoriten (`0x95000`):** nur nutzen, wenn
Update-Loader, Paketformat und Skiffs Flash-Karte das nachweislich ohne jedes Risiko zulassen, dass das Gerät nicht mehr
startet. Prüfen und begründen, sonst liegen lassen.

**Leistung:**

- **Neuer Messfall „schwerste Wahl“:** Der Nutzer kann jeden Klang auf jede Spur legen, auch schwere Engines (etwa
  PHYS, GRAIN, FM6) auf alle sechs, im schwersten Drop, mit allen Effekten. Das muss in derselben Grenze bleiben wie der
  Messfall von 1.0 (höchstens 1,10 × Skiffs heavy song).
- Reicht das nicht: Das Stimmenbudget des Produzenten rechnet die Kosten der Engines mit ein, mit schweren Klängen also
  weniger Stimmen. **Aussetzer im Audio darf es nie geben.**
- **Stimmenbudget 8** wird nie überschritten, auch mit gewählten Klängen und beim Mitspielen. Den Ausklang jedes Werks-
  oder User-Sounds aus seinen Hüllkurven abschätzen; für Werks-Sounds reicht eine kleine Tabelle aus der Messung.
- `vb_isr` bleibt klein. Der Interrupt für Tasten und LEDs bleibt im Budget.

## 8. Hören und ausprobieren, ohne zu flashen

- **`demos/vizzbox-im-browser.html` auf 1.1 bringen.** Alle neuen Bedienungen müssen sich anklicken und über die
  Computertastatur bedienen lassen: EDIT, LFO, SEL, FX/ARP/GLO halten, HOME-Kombinationen, die Tasten. Auf der Seite eine
  Übersicht der Tastenbelegung.
- **Demos:**
  - Die 36 bisherigen bleiben. Dass sie unverändert sind, belegt das Golden; neu rendern nur, wenn sich etwas geändert hat.
  - Jedes neue Subgenre bekommt eine Demo wie in 1.0. `demos/README.md` ergänzen.
- **Optional:** eine Live-Demo (MP3, 60–90 s). Eine geskriptete Performance über den Eingabeweg: BASS-Klang wechseln,
  Filter auf CHORDS, REPEAT vor dem Drop, mitspielen. So hört man die Übernahmen.

## 9. Tests

- **Alle Tests von 1.0 grün:** 176 Regressions-Renders bitgleich, GROOVEBOX bitgleich, Goldens nur dort geändert, wo
  beabsichtigt (aufzählen).
- **Golden aus 1.0:** Ohne Eingriff ergeben sich dieselben MIDI-Bytes und derselbe Audio-Hash wie in 1.0, für alle 36
  Subgenres × 3 Seeds × 3 Längen, dazu 10 Minuten ENDLOS.
- **`tests/producer_test.c` erweitern:**
  - **Klang übernommen:** bleibt über Takt, Abschnitt, neuen Stil und Wechsel in ENDLOS. HOME + schwarze Taste gibt
    ihn zurück, und es klingt der Klang, den der Produzent jetzt hätte. HOME + EDIT gibt alle zurück.
  - **Parameter übernommen:** Die Fahrten des Produzenten lassen ihn aus, andere fahren weiter. Ein neuer Stil
    überschreibt ihn nicht.
  - **FX-Layer, PERFORM und Makros des Nutzers** gewinnen, solange gehalten. Danach setzt der Produzent ohne Sprung
    fort. Ohne Eingriff bleiben seine Übergänge, wie sie sind.
  - **Noten unabhängig von Übernahmen:** derselbe Song mit und ohne Klangwechsel. Unterschiede gibt es nur durch
    Ausdünnung, also fehlende Noten, nie andere.
  - **Weitere Wege:** Änderungen in der GROOVEBOX während der Wiedergabe und MIDI-CC von außen zählen als Übernahme.
  - **Tasten:** Fokus-Spur, Einrasten in die Skala, Lanes auf DRUMS, Akkorde in der Tonart auf CHORDS, die Reserve,
    MIDI OUT.
  - **Antippen gegen Halten:** FX und ARP angetippt lösen DROP und BREAK JETZT aus wie in 1.0. Gehalten öffnen sie den
    Layer und lösen keinen DROP aus.
  - **Favoriten mit Klängen:**
    - Speichern, Aus- und Einschalten, Laden ergibt dieselben Klänge und Parameter.
    - Favoriten aus 1.0 werden in 1.1 gelesen.
    - Favoriten aus 1.1 werden in 1.0 gelesen (die Rezepte); dafür `tests/vizzbox_compat.c` mit dem Baum von 1.0.
  - **Neue Subgenres:** dieselben Prüfungen wie in 1.0.
  - **Budget:** das Stimmenbudget mit jedem Klang auf jeder Spur, und der Messfall „schwerste Wahl“.
- **`tests/vizzbox_ui.c`:** die neuen Seiten und Layer in allen sechs Paletten gegen ihr Golden.
- **Fuzzer erweitern:** Seiten, Layer, Presets, Übernahmen, Zurückgeben, Favoriten mit Klängen, GROOVEBOX zwischendurch.
- **Gegenprobe erweitern.** Diese Fehler müssen erkannt werden:
  - Ein Stilwechsel übergeht die Übernahme.
  - Eine Fahrt des Produzenten überschreibt den Parameter des Nutzers.
  - Zurückgeben gibt nicht zurück.
  - Antippen öffnet den Layer, Halten löst DROP aus.
  - Die Klänge im Favoriten werden nicht gespeichert.
  - Favoriten aus 1.0 gehen verloren.
  - Ein neues Subgenre verschiebt alte Nummern.
  - Die Songs aus 1.0 sind verändert.
- **Installer-Test:** 1.0 → 1.1 und zurück. **Emulator-Test:** die neuen Bedienungen.

## 10. Vorgehen

In Etappen arbeiten und **nach jeder Etappe auf `vizzbox-1.1` pushen**:

1. 1.0 aus den Patches nachbauen (grün, Paket bytegleich), das Golden der Songs aus 1.0 bauen, Platz messen und planen,
   woher er kommt.
2. Hand drauf (Abschnitt 2) im Produzenten und im Interrupt-Teil, dazu die Wege über GROOVEBOX und MIDI-CC, mit Tests.
3. Seiten KLANG und MOD, Fokus-Spur, Tasten (Fokus, DRUMS, CHORDS), GLO-Busse.
4. FX und ARP halten, MOMENTARY, Zurückgeben, Bildschirm, LEDs, Goldens.
5. Favoriten mit Klängen.
6. Budget (CPU, Stimmen) mit den Klängen des Nutzers.
7. Mehr Subgenres nach der Liste, soweit Platz ist, mit gemessenen Sounds und Tests.
8. Name, Kennung, Installer, alle Tests, Gegenprobe, Release, Demos, Emulator, Anleitung.

Endet die Sitzung, bevor alles fertig ist: in `CHANGES.md` genau festhalten, was steht, was getestet ist und was als
Nächstes kommt.

## 11. Ergebnis

Auf Branch **`vizzbox-1.1`** in diesem Repo committen und pushen:

- `out/vizzbox-1.1.fwsc`, `out/vizzbox-installer.html`, `out/SHA256SUMS`, Lizenzen und Attributionen wie in 1.0.
- `patches/`: alle Commits ab `v2.0.1` (`git format-patch v2.0.1..vizzbox-1.1`), durchnummeriert.
- `build-vizzbox.sh`, nachgeführt.
- `CHANGES.md` auf Deutsch. Die **erste Zeile** lautet `# Vizzbox 1.1 – Änderungen gegenüber Skiff 2.0.1`; die
  Web-App liest daraus die Basis. Inhalt:
  - was 1.1 gegenüber 1.0 ändert, die Entscheidungen und Abweichungen
  - die Regeln „Hand drauf“
  - Platz: vorher und nachher, je Funktion, was gestrichen wurde und warum
  - Budget und Testergebnis
  - Update-Anleitung von 1.0, Vizz 2.0 und Skiff 2.0.1
- `docs/VIZZBOX-ANLEITUNG.md`, nachgeführt, für jemanden, der nicht produziert. Neu ist das Kapitel **„Live spielen“**:
  Fokus-Spur, Klänge, Filter, Modulation, Effekte, Mitspielen, Zurückgeben, Favoriten mit Klängen. Dazu die neuen Stile.
- `docs/VIZZBOX-MIDI.md`: die Nummern in CC 108/109, die gespielten Töne und CC 110, falls gebaut.
- `demos/` (Abschnitt 8).
- `README.md` des Branches auf den Stand 1.1 bringen.

Fertig ist es, wenn Build und alle Tests grün sind, jedes neue Subgenre eine Demo hat und `vizzbox-1.1` gepusht ist.
Falls etwas nicht geht, genau sagen, was fehlt, statt abzukürzen.
