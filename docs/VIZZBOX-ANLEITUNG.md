# Vizzbox – Bedienungsanleitung

Die Vizzbox ist eine Firmware für die **M-VAVE FM-1**. Sie macht die Musik selbst: Du wählst eine Stilrichtung, drückst
PLAY, und die FM-1 spielt einen ganzen Track – mit Intro, Aufbau, Drop, Break und Outro, wie ein Produzent oder DJ ihn
bauen würde. Du musst dafür nichts von Musikproduktion verstehen. Mit vier Reglern und ein paar Tasten lenkst du, wohin
die Musik geht.

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
| **Vizz 2.0** oder **Skiff 2.0.1** | Nur die Installation. Deine Projekte, Sounds und Einstellungen bleiben, wie sie sind. |
| **Vizz 1.x**, **Skiff 1.4** oder ein älteres Skiff / Felucca | Zuerst wird eine vollständige Sicherung auf deinem Computer gespeichert (`Vizzbox-backup-DATUM.json`) – das ist dein Weg zurück. Dann die Installation, dann wandelt der Installer um, was Firmware 2.0 nicht mehr lesen kann. Die Liste des Umgewandelten steht danach auf der Seite. |
| die Original-Firmware von M-VAVE | Nur die Installation (es gibt keine Vizzbox-Daten zu sichern). |

**Zurück:** Vizz 2.0 oder Skiff 2.0.1 lassen sich genauso wieder darüber installieren, ohne dass etwas umgewandelt
wird. Zur Original-Firmware führt der Weg über M-VAVEs eigenes Update-Programm (V15).

---

## 2. Der erste Song

Nach dem Einschalten zeigt die FM-1 den **VIZZBOX-Bildschirm**. Oben stehen Genre und Subgenre, darunter Tempo,
Tonart und eine vierstellige Zahl, der **Seed**.

1. **Regler 1** drehen: das Genre (zum Beispiel TECHNO).
2. **Regler 2** drehen: die Unterart (zum Beispiel DUB TECHNO).
3. **PLAY** drücken. Der Song beginnt.
4. Noch einmal **PLAY**: Stopp.

Das ist schon alles. Der Song läuft von selbst durch alle Teile und hört am Ende auf (oder läuft endlos, siehe
Abschnitt 6).

> **Gut zu wissen:** Derselbe Seed mit denselben Reglerstellungen ergibt **immer denselben Song** – Ton für Ton. Ein
> anderer Seed ergibt einen anderen Song im selben Stil. So kannst du dir Songs merken (Abschnitt 5).

---

## 3. Alle Regler und Tasten

### Die Regler

| Regler | Was er tut |
| --- | --- |
| **Regler 1 – GENRE** | Die Stilrichtung: HOUSE, TECHNO, ELECTRO, TRANCE, BREAKS, DRUM & BASS, DUBSTEP, HIP-HOP, AMBIENT, HARD. |
| **Regler 2 – SUBGENRE** | Die Unterart innerhalb des Genres (2 bis 6 je Genre, Liste in Abschnitt 8). |
| **Regler 3 – ENERGIE** (0–100) | Wie intensiv der Song wird: wie dicht, wie viele Instrumente, wie hart die Drops. Bei 0 bleibt er gemütlich, bei 100 geht er voll los. |
| **Regler 4 – VARIATION** (0–100) | Wie sehr sich der Song verändert: Bei 0 wiederholen sich die Teile fast gleich, bei 100 gibt es neue Melodien, mehr Fills und überraschendere Übergänge. Der Aufbau des Songs bleibt. |
| **SELECT – TEMPO** | Das Tempo in BPM, in Einerschritten. Ohne Drehen wählt die Vizzbox ein passendes Tempo für den Stil. |
| **ALGORITHM – LÄNGE** | KURZ (gut 2 bis knapp 4 Minuten), NORMAL (4½ bis 6 Minuten) oder ENDLOS. Das Tempo bestimmt mit: Ein schneller Stil spielt mehr Takte in derselben Zeit. |
| **PRESETS – SEED** | Der Seed, also welcher Song in diesem Stil. Jeder Schritt ist ein anderer Song. |
| **MASTER** | Die Lautstärke, wie immer. |

Beim Drehen zeigt der Bildschirm den neuen Wert groß an.

### Die Tasten

| Taste | Was sie tut |
| --- | --- |
| **PLAY** | Start und Stopp. |
| **REC – NEU** | Ein neuer, zufälliger Seed: gestoppt ein neuer Song; beim Spielen leitet die Vizzbox über einen Break und einen Aufbau in den neuen Song über. |
| **FX – DROP JETZT** | Beim Spielen: Nach höchstens zwei Takten ein kurzer Aufbau (4 Takte, nach Intro oder Break 8), dann der Drop. |
| **ARP – BREAK JETZT** | Beim Spielen: Nach höchstens zwei Takten ein Break (8 Takte), dann Aufbau und Drop. |
| **SEQ – HALTEN** | Der laufende Teil wiederholt sich, bis du SEQ noch einmal drückst. |
| **OCT− / OCT+** | Die Oktave der weißen Tasten. |
| **HOME + PLAY** | In die GROOVEBOX (Abschnitt 7). HOME gedrückt halten, dann PLAY drücken. |
| **HOME lang** | Das MENU, wie in Skiff (Einstellungen, MIDI, THEME …). |

### Die Klaviertasten

| Tasten | Was sie tun |
| --- | --- |
| **schwarze Tasten** (die ersten sechs: F♯3, G♯3, A♯3, C♯4, D♯4, F♯4) | Je eine der sechs Spuren: **1 DRUMS, 2 BASS, 3 CHORDS, 4 LEAD, 5 ARP, 6 FX**. **Antippen** schaltet die Spur stumm oder wieder an. **Halten** macht sie stumm, solange du hältst. Mit **GLO** gedrückt gehalten: **SOLO** – nur diese Spur, solange du hältst. |
| **weiße Tasten** | Mitspielen mit dem Sound der LEAD-Spur. Die Töne rasten auf die Tonart des Songs ein, es klingt also nichts schief. |
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

Die Teile eines Songs: **INTRO** (der Anfang), **GROOVE** (der Beat läuft), **BUILD** (der Aufbau, es wird
spannender), **DROP** (der Höhepunkt), **BREAK** (Pause zum Durchatmen), **OUTRO** (das Ende). Vor dem Drop ist oft
ein Schlag lang Stille – das ist Absicht.

Mit externer Clock (MENU > MIDI > CLOCK) steht statt des Tempos **EXT**: Die Vizzbox folgt dann dem Tempo von außen und
startet mit dem Start-Befehl von dort.

---

## 5. Favoriten

Die Vizzbox merkt sich **16 Favoriten** – einen pro weißer Taste (von links nach rechts 1 bis 16).

- **Speichern:** SAVE gedrückt halten, eine weiße Taste drücken. Gemerkt wird alles, was den Song ausmacht: Genre,
  Subgenre, Seed, Energie, Variation, Länge und Tempo. Beim Halten von SAVE zeigt der Bildschirm die Liste.
- **Laden:** GLO gedrückt halten, eine weiße Taste drücken. Gestoppt stehen die Regler dann auf diesem Song – PLAY
  spielt genau ihn. Beim Spielen leitet die Vizzbox über einen Break und einen Aufbau in ihn über.
- Gespeichert wird beim Spielen erst, wenn du stoppst (Speichern würde den Ton kurz unterbrechen).
- Die Favoriten überstehen das Ausschalten und ein Update auf eine neue Vizzbox. Sie liegen getrennt von deinen
  Projekten; Vizz 2.0 und Skiff 2.0.1 lassen sie in Ruhe, falls du zwischendurch eine von ihnen installierst.

---

## 6. ENDLOS

Mit **ALGORITHM** auf **ENDLOS** spielt die Vizzbox wie ein DJ-Set ohne Ende: Break, Aufbau und Drop wechseln sich ab,
die Musik verändert sich dabei immer wieder. Nach 4 bis 8 Minuten wechselt sie in ein **verwandtes Subgenre** – eins
mit ähnlichem Tempo, oft aus demselben Genre – über einen Break und einen Aufbau, das Tempo gleitet dabei hinüber. Das
läuft, bis du PLAY drückst.

**Selbst den Stil wechseln, während es spielt:** Regler 1 oder 2 drehen, einen neuen Seed wählen oder einen Favoriten
laden. Die Vizzbox wechselt nicht abrupt, sondern wie ein DJ: Sie spielt einen Break und einen Aufbau, in dem das
Tempo hinübergleitet, und setzt mit dem Drop des neuen Stils ein. Energie, Variation und Länge wirken ab dem nächsten
Teil, das Tempo gleitet über vier Takte.

---

## 7. Zurück in die GROOVEBOX

**HOME gedrückt halten und PLAY drücken.** Jetzt ist die FM-1 wieder die GROOVEBOX – Skiff mit allem, was du kennst.

- **Gestoppt:** Deine eigene Musik ist wieder da, genau wie du sie verlassen hast. Die Vizzbox verändert deine
  gespeicherten Projekte nie, und solange sie spielt, speichert die FM-1 ihre Songs auch nicht als deine Sitzung.
- **Beim Spielen:** Der Song der Vizzbox läuft weiter, bis du stoppst.
- **Zurück in die VIZZBOX:** in der GROOVEBOX wieder **HOME gedrückt halten und PLAY drücken**.
- Die FM-1 merkt sich, wo du warst, und startet beim nächsten Einschalten dort.

---

## 8. Die Stile

| Genre (Regler 1) | Subgenres (Regler 2) |
| --- | --- |
| HOUSE | DEEP HOUSE, TECH HOUSE, ACID HOUSE, FILTER HOUSE, AFRO HOUSE, DISCO HOUSE |
| TECHNO | MINIMAL, PEAK-TIME, DUB TECHNO, HARD TECHNO, DETROIT, MELODIC TECHNO |
| ELECTRO | ELECTRO, SYNTHWAVE, ITALO DISCO |
| TRANCE | PROGRESSIVE, UPLIFTING, PSYTRANCE, GOA |
| BREAKS | BREAKBEAT, 2-STEP, SPEED GARAGE |
| DRUM & BASS | LIQUID, NEUROFUNK, JUMP-UP, JUNGLE |
| DUBSTEP | DEEP DUBSTEP, BROSTEP |
| HIP-HOP | BOOM BAP, LO-FI, TRAP |
| AMBIENT | AMBIENT, CHILL, DUB |
| HARD | HARDSTYLE, GABBER |

AMBIENT, DUB und DUB TECHNO haben keinen Drop: Sie schweben zwischen Groove und Break. Hörproben aller 36 gibt es im
Ordner `demos/`.

---

## 9. Mit VIZZ und anderen Programmen

Wie bei Vizz 2.0 sendet die FM-1 über USB-MIDI, was sie spielt (MENU > MIDI > **SEQ MIDI OUT = ON**): die Noten aller
sechs Spuren, die Stummschaltungen, Start, Stopp und die Clock. Die Vizzbox schickt zusätzlich auf **MIDI-Kanal 16**,
wo im Song sie gerade ist – welcher Teil, wie viel Energie, welcher Takt, Genre und Subgenre (Controller 104 bis
109). Der Visualizer VIZZ kann damit einen Drop schon einen Takt vorher kommen sehen. Die genaue Beschreibung für
Programmierer steht in `docs/VIZZBOX-MIDI.md`.

---

## 10. Wenn etwas nicht geht

| Problem | Lösung |
| --- | --- |
| PLAY startet nichts, oben steht **EXT** | Die FM-1 wartet auf eine Clock von außen. MENU > MIDI > CLOCK auf INTERNAL stellen. |
| Eine Spur ist still | Vielleicht stumm geschaltet: die schwarze Taste der Spur antippen. Oder das Arrangement lässt sie gerade aus – dann kommt sie im nächsten Teil wieder. |
| Der Song klingt anders als gestern | Seed, Regler oder Länge sind andere. Mit einem Favoriten kommt genau derselbe Song wieder. |
| Ich will meine eigene Musik bearbeiten | HOME + PLAY: die GROOVEBOX. |
| Der Installer meldet einen Fehler | USB-Kabel neu stecken und **Install** noch einmal drücken. Die FM-1 bleibt im Update-Modus, bis es geklappt hat. |

---

Die Vizzbox ist eine geänderte Fassung von **Skiff 2.0.1** (illuminus5) auf Basis von **Felucca** (Leo Kuroshita,
Hügelton Instruments), mit den Erweiterungen von **Vizz 2.0**. Sie steht wie diese unter der **GPL-3.0**; die Credits
und Lizenzen von Skiff und Felucca stehen im MENU unter ABOUT und in den Lizenzdateien bei der Firmware. M-VAVE und
FM-1 sind Marken ihrer Inhaber; die Vizzbox ist nicht mit ihnen verbunden.
