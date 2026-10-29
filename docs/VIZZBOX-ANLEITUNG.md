# Vizzbox – Bedienungsanleitung

Die Vizzbox ist eine Firmware für die **M-VAVE FM-1**. Sie macht die Musik selbst: Du wählst eine Stilrichtung, drückst
PLAY, und die FM-1 spielt einen ganzen Track – mit Intro, Aufbau, Drop, Break und Outro, wie ein Produzent oder DJ ihn
bauen würde. Du musst dafür nichts von Musikproduktion verstehen. Mit vier Reglern und ein paar Tasten lenkst du, wohin
die Musik geht. Seit **Version 1.1** kannst du dabei auch selbst Hand anlegen: Klänge wechseln, am Filter drehen,
Effekte werfen und mitspielen, während die Vizzbox weiterproduziert (Abschnitt 6).

Alles, was die FM-1 vorher konnte, bleibt: Mit einem Tastendruck wechselst du in die **GROOVEBOX** – das ist Skiff
2.0.1 mit den Erweiterungen von Vizz 2.0, so wie du es kennst, mit deinen gespeicherten Projekten.

---

## 1. Installieren

1. Die FM-1 per USB an den Computer anschließen.
2. **`vizzbox-installer.html`** in **Chrome** oder **Edge** öffnen (eine einzige Datei, sie funktioniert auch ohne
   Internet). Den Zugriff auf MIDI-Geräte erlauben.
3. **Install** klicken und warten, bis „Done“ erscheint. Das USB-Kabel währenddessen nicht ziehen.

Was der Installer mit deinen Daten macht, hängt davon ab, was vorher auf der FM-1 war:

| Vorher auf der FM-1 | Was passiert |
| --- | --- |
| **Vizzbox 1.0**, **Vizz 2.0** oder **Skiff 2.0.1** | Nur die Installation. Deine Projekte, Sounds, Einstellungen und Favoriten bleiben, wie sie sind. |
| **Vizz 1.x**, **Skiff 1.4** oder ein älteres Skiff / Felucca | Zuerst wird eine vollständige Sicherung auf deinem Computer gespeichert (`Vizzbox-backup-DATUM.json`) – das ist dein Weg zurück. Dann die Installation, dann wandelt der Installer um, was Firmware 2.0 nicht mehr lesen kann. Die Liste des Umgewandelten steht danach auf der Seite. |
| die Original-Firmware von M-VAVE | Nur die Installation (es gibt keine Vizzbox-Daten zu sichern). |

**Zurück:** Vizzbox 1.0, Vizz 2.0 oder Skiff 2.0.1 lassen sich genauso wieder darüber installieren, ohne dass etwas
umgewandelt wird. Die Vizzbox 1.0 liest deine Favoriten weiter (nur die Songs, nicht die Klänge darin, siehe
Abschnitt 6). Zur Original-Firmware führt der Weg über M-VAVEs eigenes Update-Programm (V15).

---

## 2. Der erste Song

Nach dem Einschalten zeigt die FM-1 den **VIZZBOX-Bildschirm**. Oben stehen Genre und Subgenre, darunter Tempo,
Tonart und eine vierstellige Zahl, der **Seed**.

1. **Regler 1** drehen: das Genre (zum Beispiel TECHNO).
2. **Regler 2** drehen: die Unterart (zum Beispiel DUB TECHNO).
3. **PLAY** drücken. Der Song beginnt.
4. Noch einmal **PLAY**: Stopp.

Das ist schon alles. Der Song läuft von selbst durch alle Teile und hört am Ende auf (oder läuft endlos, siehe
Abschnitt 7).

> **Gut zu wissen:** Derselbe Seed mit denselben Reglerstellungen ergibt **immer denselben Song** – Ton für Ton. Ein
> anderer Seed ergibt einen anderen Song im selben Stil. So kannst du dir Songs merken (Abschnitt 5).

---

## 3. Alle Regler und Tasten

### Die Regler

| Regler | Was er tut |
| --- | --- |
| **Regler 1 – GENRE** | Die Stilrichtung: HOUSE, TECHNO, ELECTRO, TRANCE, BREAKS, DRUM & BASS, DUBSTEP, HIP-HOP, AMBIENT, HARD, AFRO & LATIN. |
| **Regler 2 – SUBGENRE** | Die Unterart innerhalb des Genres (4 bis 8 je Genre, Liste in Abschnitt 9). |
| **Regler 3 – ENERGIE** (0–100) | Wie intensiv der Song wird: wie dicht, wie viele Instrumente, wie hart die Drops. Bei 0 bleibt er gemütlich, bei 100 geht er voll los. |
| **Regler 4 – VARIATION** (0–100) | Wie sehr sich der Song verändert: Bei 0 wiederholen sich die Teile fast gleich, bei 100 gibt es neue Melodien, mehr Fills und überraschendere Übergänge. Der Aufbau des Songs bleibt. |
| **SELECT – TEMPO** | Das Tempo in BPM, in Einerschritten. Ohne Drehen wählt die Vizzbox ein passendes Tempo für den Stil. |
| **ALGORITHM – LÄNGE** | KURZ (gut 2 bis knapp 4 Minuten), NORMAL (4½ bis 6 Minuten) oder ENDLOS. Das Tempo bestimmt mit: Ein schneller Stil spielt mehr Takte in derselben Zeit. |
| **PRESETS – SEED** | Der Seed, also welcher Song in diesem Stil. Jeder Schritt ist ein anderer Song. |
| **MASTER** | Die Lautstärke, wie immer. |

Beim Drehen zeigt der Bildschirm den neuen Wert groß an. Das gilt für die Seite **SONG**; auf den Seiten KLANG und
MOD steuern die Regler den Klang der Fokus-Spur (Abschnitt 6).

### Die Tasten

| Taste | Was sie tut |
| --- | --- |
| **PLAY** | Start und Stopp. |
| **REC – NEU** | Ein neuer, zufälliger Seed: gestoppt ein neuer Song; beim Spielen leitet die Vizzbox über einen Break und einen Aufbau in den neuen Song über. |
| **FX antippen – DROP JETZT** | Beim Spielen: Nach höchstens zwei Takten ein kurzer Aufbau (4 Takte, nach Intro oder Break 8), dann der Drop. Es zählt beim Loslassen. |
| **FX halten** | Die Effekte (Abschnitt 6). |
| **ARP antippen – BREAK JETZT** | Beim Spielen: Nach höchstens zwei Takten ein Break (8 Takte), dann Aufbau und Drop. |
| **ARP halten** | PERFORM: Regler werfen Filter, Hall, Delay und Verzerrung hoch (Abschnitt 6). |
| **GLO halten** | Die Busse (Hall, Delay, Chorus) auf den Reglern; dazu Favoriten laden und SOLO wie bisher. |
| **SEQ – HALTEN** | Der laufende Teil wiederholt sich, bis du SEQ noch einmal drückst. |
| **EDIT** / **LFO** | Die Seiten KLANG und MOD für die Fokus-Spur; dieselbe Taste noch einmal: zurück zu SONG (Abschnitt 6). |
| **SEL + schwarze Taste** | Diese Spur wird die Fokus-Spur. |
| **OCT− / OCT+** | Die Oktave der weißen Tasten. |
| **HOME + PLAY** | In die GROOVEBOX (Abschnitt 8). HOME gedrückt halten, dann PLAY drücken. |
| **HOME + schwarze Taste** / **HOME + EDIT** | Eine Spur / alle Spuren zurück an die Vizzbox (Abschnitt 6). |
| **HOME halten** | Eine Karte mit allen diesen Kombinationen, solange du hältst. |
| **HOME lang halten und loslassen** | Das MENU, wie in Skiff (Einstellungen, MIDI, THEME …). |

### Die Klaviertasten

| Tasten | Was sie tun |
| --- | --- |
| **schwarze Tasten** (die ersten sechs: F♯3, G♯3, A♯3, C♯4, D♯4, F♯4) | Je eine der sechs Spuren: **1 DRUMS, 2 BASS, 3 CHORDS, 4 LEAD, 5 ARP, 6 FX**. **Antippen** schaltet die Spur stumm oder wieder an. **Halten** macht sie stumm, solange du hältst. Mit **GLO** gedrückt gehalten: **SOLO** – nur diese Spur, solange du hältst. |
| **weiße Tasten** | Mitspielen auf der **Fokus-Spur** (am Anfang LEAD): einzelne Töne, eingerastet auf die Tonart des Songs – es klingt nichts schief; auf DRUMS ein Instrument je Taste, auf CHORDS ein Akkord je Taste (Abschnitt 6). |
| **SAVE + weiße Taste** | Den aktuellen Song als **Favorit** speichern (Abschnitt 5). |
| **GLO + weiße Taste** | Einen **Favoriten** laden. |

Das Stummschalten ist nur deins: Die Vizzbox selbst lässt Instrumente im Arrangement aus und wieder einsetzen, ohne
an deinen Stummschaltungen etwas zu ändern.

---

## 4. Der Bildschirm

```
TECHNO                         NORMAL      ← Genre                    Länge
DUB TECHNO                                 ← Subgenre
122 BPM     F MIN               5EED       ← Tempo, Tonart            Seed
BUILD 12/16                  E70 V40       ← Teil und Takt darin      Energie, Variation
  ‾‾\__/‾‾‾‾\___/‾‾‾                       ← die Energiekurve des ganzen Songs, der Strich: wo er gerade ist
[1 DRUMS] [2 BASS M] [3 CHORDS]            ← die sechs Spuren: farbig = spielt gerade,
[4 LEAD ] [5 ARP   ] [6 FX    ]               M = stumm (Schrift blass), S = solo
FX DROP  ARP BREAK  SEQ HOLD  REC NEW      ← was die Tasten gerade tun
```

Dazu hat die **Fokus-Spur** einen Rahmen, und ein **Punkt** an einer Spur zeigt: Da hast du etwas übernommen. Auf den
Seiten KLANG und MOD zeigt der Bildschirm Skiffs Seiten: oben die vier Regler, darunter ihre Grafik, unten die
Fokus-Spur und ihr Klang.

Die Teile eines Songs: **INTRO** (der Anfang), **GROOVE** (der Beat läuft), **BUILD** (der Aufbau, es wird
spannender), **DROP** (der Höhepunkt), **BREAK** (Pause zum Durchatmen), **OUTRO** (das Ende). Vor dem Drop ist oft
ein Schlag lang Stille – das ist Absicht.

Mit externer Clock (MENU > MIDI > CLOCK) steht statt des Tempos **EXT**: Die Vizzbox folgt dann dem Tempo von außen und
startet mit dem Start-Befehl von dort.

---

## 5. Favoriten

Die Vizzbox merkt sich **16 Favoriten** – einen pro weißer Taste (von links nach rechts 1 bis 16).

- **Speichern:** SAVE gedrückt halten, eine weiße Taste drücken. Gemerkt wird alles, was den Song ausmacht: Genre,
  Subgenre, Seed, Energie, Variation, Länge und Tempo – und was du übernommen hast (Klänge, Regler, Busse; Abschnitt
  6). Beim Halten von SAVE zeigt der Bildschirm die Liste; ein **+** heißt „mit Klängen“.
- **Laden:** GLO gedrückt halten, eine weiße Taste drücken. Gestoppt stehen die Regler dann auf diesem Song – PLAY
  spielt genau ihn. Beim Spielen leitet die Vizzbox über einen Break und einen Aufbau in ihn über.
- Gespeichert wird beim Spielen erst, wenn du stoppst (Speichern würde den Ton kurz unterbrechen).
- Die Favoriten überstehen das Ausschalten und ein Update auf eine neue Vizzbox. Sie liegen getrennt von deinen
  Projekten; Vizz 2.0 und Skiff 2.0.1 lassen sie in Ruhe, falls du zwischendurch eine von ihnen installierst. Die
  Vizzbox 1.0 liest ihre Songs; speicherst du dort über einen Favoriten, verliert nur dieser seine Klänge.

---

## 6. Live spielen

Während die Vizzbox einen Song spielt, kannst du in jede ihrer sechs Spuren eingreifen: einen anderen Klang wählen,
am Filter drehen, Effekte draufwerfen, mitspielen. Sie komponiert weiter – Noten, Aufbau, Drops –, lässt aber genau
das in Ruhe, was du angefasst hast. Das nennen wir **„Hand drauf“**.

### Die Fokus-Spur

Eine der sechs Spuren ist immer die **Fokus-Spur**: Auf sie wirken die Seiten KLANG und MOD, und die weißen Tasten
spielen sie. Nach dem Einschalten ist es **LEAD**.

- **Wechseln:** **SEL** gedrückt halten und die **schwarze Taste** der Spur drücken (1 DRUMS … 6 FX). Auf den Seiten
  KLANG und MOD geht es auch mit **ALGORITHM**.
- Auf der Seite SONG hat die Fokus-Spur einen **Rahmen**. Ein **Punkt** an einer Spur heißt: Da hast du etwas
  übernommen. Ihre schwarze Taste **atmet** (stumm geschaltet: mittelhell).

### Die drei Seiten: SONG, KLANG, MOD

| Taste | Seite | Was du dort machst |
| --- | --- | --- |
| (Start) | **SONG** | Genre, Subgenre, Energie, Variation, Tempo, Länge, Seed – wie bisher. |
| **EDIT** | **KLANG** | Der Klang der Fokus-Spur. Zuerst **LIVE**: die vier wichtigsten Regler dieser Spur (zwei Klangregler, Ausklang, Verzerrung). Mit **SELECT** weiter durch alle Klang-, Hüllkurven- und Effekt-Seiten bis zum MIXER. |
| **LFO** | **MOD** | Die Modulation der Fokus-Spur: die LFO-Seiten (Tempo, Form, Ziel …). |

Dieselbe Taste noch einmal oder **HOME** antippen bringt dich zurück zu SONG. Oben stehen die vier Karten der Regler,
darunter die Grafik der Seite; beim Drehen zeigt die FM-1 den Wert groß. Die offene Seite erkennst du an der leuchtenden
Taste EDIT oder LFO.

### Klänge wählen

Auf KLANG oder MOD wählst du mit **PRESETS** einen anderen Klang für die Fokus-Spur. Die Liste passt zur Spur: auf
DRUMS Kits, auf BASS Bässe, auf CHORDS Flächen und Pianos, und so weiter. Zuerst kommen die Klänge, die der Stil
selbst benutzt (mit `*` markiert), dann die anderen passenden. **HOME + PRESETS** zeigt alle Klänge der FM-1, auch deine
eigenen (USER).

Der gewählte Klang bleibt, bis du ihn zurückgibst – auch wenn die Vizzbox den Stil wechselt, im ENDLOS-Modus
weiterzieht oder du stoppst und wieder startest.

### Filter, Hüllkurve, Modulation

Was du auf KLANG oder MOD drehst, gehört dir: Die Vizzbox fährt diesen Regler nicht mehr (zum Beispiel ihre
Filterfahrt im Aufbau), auch nicht nach einem Stilwechsel. Ihre anderen Fahrten laufen weiter. Das gilt auch, wenn du
denselben Regler in der GROOVEBOX, im Web-Editor oder über einen MIDI-Controller drehst.

**Nur kurz:** **LFO gedrückt halten und einen Regler drehen** (auf KLANG) ändert den Wert nur, solange du LFO hältst;
beim Loslassen gleitet er zurück. Das zählt nicht als Übernahme.

### Effekte: FX und ARP halten

- **FX gedrückt halten** öffnet die Effekte: Die **weißen Tasten** sind die 14 Effekte (REPEAT, FREEZE, OCT, GATE,
  DUB, FLANGE, VINYL, Filter-Sweeps, TAPE STOP, REVERSE …), die **Regler 1–4** die Makros FILTER, CRUSH, THROW und
  DEPTH, die **schwarzen Tasten** schalten Spuren stumm. Beim Loslassen geht alles sanft zurück. Solange du einen
  Effekt oder Makro hältst, setzt die Vizzbox keinen eigenen. **HOME + FX** lässt die Effekte offen, bis du FX noch
  einmal drückst.
- **FX nur antippen** heißt wie bisher **DROP JETZT** – es zählt beim Loslassen.
- **ARP gedrückt halten** öffnet PERFORM: Die **Regler 1–4** werfen CUTOFF, REVERB, DELAY und DIST hoch, die über einen
  Takt zurückgleiten (mit OCT+ bleiben sie stehen); die weißen Tasten spielen die Fokus-Spur. **ARP antippen** heißt
  **BREAK JETZT**.
- **GLO gedrückt halten:** die **Busse** – Regler 1–4 sind Delay-Anteil, Hallgröße, Chorus-Tiefe und Delay-Feedback, mit
  SELECT kommen die ganzen Seiten von Delay, Hall und Chorus (mit Typ und Zeit). Weiße Taste: Favorit laden; schwarze:
  SOLO – wie bisher.

### Mitspielen

Die **weißen Tasten** spielen die Fokus-Spur:

- **DRUMS:** jede Taste ein Instrument des Kits – KICK, SNARE, CLAP, HAT, OFFENE HAT, TOM, RIM, BELL, dann von vorn.
- **CHORDS:** jede Taste ein ganzer Akkord, passend zur Tonart des Songs (Dreiklang oder Septakkord, wie der Stil).
- **alle anderen:** einzelne Töne, eingerastet auf die Tonart des Songs – es klingt nichts schief.

Die Vizzbox lässt dir dafür Platz: Spielst du länger mit, plant sie ab dem übernächsten Takt weniger eigene Stimmen.

### Zurückgeben

- **HOME + schwarze Taste:** Diese Spur gehört wieder ganz der Vizzbox – ihr Klang und alle Regler so, wie sie sie
  jetzt hätte.
- **HOME + EDIT:** alle Spuren und die Busse zurück.
- Was du übernommen hast, hält über Stopp und PLAY und auch über einen Ausflug in die GROOVEBOX – bis du es
  zurückgibst oder die FM-1 ausschaltest. In deinen Projekten wird nichts davon gespeichert.

**HOME gedrückt halten** zeigt alle diese Kombinationen auf dem Bildschirm.

### Favoriten mit Klängen

**SAVE + weiße Taste** speichert jetzt auch, was du übernommen hast: je Spur den Klang, die acht zuletzt gedrehten
Regler und die Busse. **GLO + weiße Taste** stellt sie wieder her – auf den Spuren, die der Favorit enthält, ersetzt
er, was du dort gerade hattest; die anderen bleiben. In der Liste steht bei so einem Favoriten ein **+**. Ein Favorit
ohne Übernahmen lädt nur den Song, wie früher.

> **Achtung bei eigenen Klängen:** Ein Favorit merkt sich bei einem USER-Klang nur dessen **Platz**. Liegt dort
> inzwischen ein anderer Klang, spielt er diesen; ist der Platz leer, spielt die Spur den Klang der Vizzbox.

---

## 7. ENDLOS

Mit **ALGORITHM** auf **ENDLOS** spielt die Vizzbox wie ein DJ-Set ohne Ende: Break, Aufbau und Drop wechseln sich ab,
die Musik verändert sich dabei immer wieder. Nach 4 bis 8 Minuten wechselt sie in ein **verwandtes Subgenre** – eins
mit ähnlichem Tempo, oft aus demselben Genre – über einen Break und einen Aufbau, das Tempo gleitet dabei hinüber. Das
läuft, bis du PLAY drückst.

**Selbst den Stil wechseln, während es spielt:** Regler 1 oder 2 drehen, einen neuen Seed wählen oder einen Favoriten
laden. Die Vizzbox wechselt nicht abrupt, sondern wie ein DJ: Sie spielt einen Break und einen Aufbau, in dem das
Tempo hinübergleitet, und setzt mit dem Drop des neuen Stils ein. Energie, Variation und Länge wirken ab dem nächsten
Teil, das Tempo gleitet über vier Takte.

---

## 8. Zurück in die GROOVEBOX

**HOME gedrückt halten und PLAY drücken.** Jetzt ist die FM-1 wieder die GROOVEBOX – Skiff mit allem, was du kennst.

- **Gestoppt:** Deine eigene Musik ist wieder da, genau wie du sie verlassen hast. Die Vizzbox verändert deine
  gespeicherten Projekte nie, und solange sie spielt, speichert die FM-1 ihre Songs auch nicht als deine Sitzung.
- **Beim Spielen:** Der Song der Vizzbox läuft weiter, bis du stoppst. Skiffs Klang-, LFO- und FX-Seiten wirken
  dabei auf ihre Spuren und zählen als Übernahme (Abschnitt 6), sie bleiben auch zurück in der VIZZBOX. Die
  Pattern-Seiten (SEQ, REC) kannst du öffnen, aber die Vizzbox schreibt jeden Takt neu: Die FM-1 sagt dann „VIZZBOX
  PLAYS IT – NEXT BAR: ITS OWN“.
- **Zurück in die VIZZBOX:** in der GROOVEBOX wieder **HOME gedrückt halten und PLAY drücken**.
- Die FM-1 merkt sich, wo du warst, und startet beim nächsten Einschalten dort.

---

## 9. Die Stile

| Genre (Regler 1) | Subgenres (Regler 2) |
| --- | --- |
| HOUSE | DEEP HOUSE, TECH HOUSE, ACID HOUSE, FILTER HOUSE, AFRO HOUSE, DISCO HOUSE, **PROG HOUSE**, **BASS HOUSE** |
| TECHNO | MINIMAL, PEAK-TIME, DUB TECHNO, HARD TECHNO, DETROIT, MELODIC TECHNO, **ACID TECHNO**, **INDUSTRIAL** |
| ELECTRO | ELECTRO, SYNTHWAVE, ITALO DISCO, **NU-DISCO**, **DARKSYNTH** |
| TRANCE | PROGRESSIVE, UPLIFTING, PSYTRANCE, GOA, **HARD TRANCE** |
| BREAKS | BREAKBEAT, 2-STEP, SPEED GARAGE, **BASSLINE**, **GRIME**, **JERSEY CLUB** |
| DRUM & BASS | LIQUID, NEUROFUNK, JUMP-UP, JUNGLE, **HALFTIME** |
| DUBSTEP | DEEP DUBSTEP, BROSTEP, **RIDDIM**, **FUTURE BASS** |
| HIP-HOP | BOOM BAP, LO-FI, TRAP, **DRILL**, **PHONK** |
| AMBIENT | AMBIENT, CHILL, DUB, **TRIP-HOP** |
| HARD | HARDSTYLE, GABBER, **HARDCORE**, **FRENCHCORE** |
| **AFRO & LATIN** | **AMAPIANO**, **AFROBEATS**, **REGGAETON**, **BAILE FUNK** |

**Fett:** neu in Version 1.1 – 58 Stile statt 36. Die bisherigen behalten ihre Plätze; ein Favorit aus Version 1.0
spielt also weiter denselben Song. AMBIENT, DUB und DUB TECHNO haben keinen Drop: Sie schweben zwischen Groove und
Break. Im ENDLOS-Modus zieht die Vizzbox von einem der neuen Stile auch zu den alten weiter; von einem der 36 alten aus
bleibt sie bei den alten (so bleiben deren Songs dieselben wie in 1.0). Hörproben aller 58 gibt es im Ordner `demos/`.

---

## 10. Mit VIZZ und anderen Programmen

Wie bei Vizz 2.0 sendet die FM-1 über USB-MIDI, was sie spielt (MENU > MIDI > **SEQ MIDI OUT = ON**): die Noten aller
sechs Spuren, die Stummschaltungen, Start, Stopp und die Clock. Die Vizzbox schickt zusätzlich auf **MIDI-Kanal 16**,
wo im Song sie gerade ist – welcher Teil, wie viel Energie, welcher Takt, Genre und Subgenre (Controller 104 bis
109) – und seit 1.1 auch, welcher Effekt des FX-Layers gerade gehalten wird (Controller 110). Der Visualizer VIZZ
kann damit einen Drop schon einen Takt vorher kommen sehen und einen Stotter-Effekt mitzeigen. Was du auf den weißen
Tasten spielst, geht auf dem Kanal der Fokus-Spur hinaus. Die genaue Beschreibung für Programmierer steht in
`docs/VIZZBOX-MIDI.md`.

---

## 11. Wenn etwas nicht geht

| Problem | Lösung |
| --- | --- |
| PLAY startet nichts, oben steht **EXT** | Die FM-1 wartet auf eine Clock von außen. MENU > MIDI > CLOCK auf INTERNAL stellen. |
| Eine Spur ist still | Vielleicht stumm geschaltet: die schwarze Taste der Spur antippen. Oder das Arrangement lässt sie gerade aus – dann kommt sie im nächsten Teil wieder. |
| Der Song klingt anders als gestern | Seed, Regler oder Länge sind andere. Mit einem Favoriten kommt genau derselbe Song wieder. |
| Ich will meine eigene Musik bearbeiten | HOME + PLAY: die GROOVEBOX. |
| Ein Klang wechselt beim Stilwechsel nicht mehr mit, ein Regler bewegt sich nicht mehr von selbst | Du hast ihn übernommen (Abschnitt 6). **HOME + schwarze Taste** gibt die Spur zurück, **HOME + EDIT** alle. |
| Die weißen Tasten spielen eine andere Spur | Sie spielen die Fokus-Spur. **SEL + schwarze Taste** wählt eine andere. |
| Ein Favorit spielt einen anderen eigenen Klang als früher | Er merkt sich nur den Platz des USER-Klangs; dort liegt jetzt ein anderer (Abschnitt 6). |
| Der Installer meldet einen Fehler | USB-Kabel neu stecken und **Install** noch einmal drücken. Die FM-1 bleibt im Update-Modus, bis es geklappt hat. |

---

Die Vizzbox ist eine geänderte Fassung von **Skiff 2.0.1** (illuminus5) auf Basis von **Felucca** (Leo Kuroshita,
Hügelton Instruments), mit den Erweiterungen von **Vizz 2.0**. Sie steht wie diese unter der **GPL-3.0**; die Credits
und Lizenzen von Skiff und Felucca stehen im MENU unter ABOUT und in den Lizenzdateien bei der Firmware. M-VAVE und
FM-1 sind Marken ihrer Inhaber; die Vizzbox ist nicht mit ihnen verbunden.
