# Vizzbox 1.1 – Änderungen gegenüber Skiff 2.0.1

> **Stand: Etappe 1 von 8** (BRIEF-VIZZBOX-1.1.md, Abschnitt 10). Die Vizzbox 1.0 ist aus den Patches bytegleich
> nachgebaut, ihre Tests sind grün, das Golden der Songs aus 1.0 steht, der Platz ist gemessen und geplant. Die
> Live-Kontrolle (Etappen 2–8) ist **noch nicht** gebaut; das Paket in `out/` ist bis Etappe 8 noch das der 1.0.
> Was als Nächstes kommt: Abschnitt „Nächste Schritte“.

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

Erste Messung der Live-Kontrolle: der Kern von „Hand drauf“ (Besitz je Spur und Parameter, die Haken in Skiffs
Wegen, der Interrupt-Teil, Zurückgeben, die Übernahmen über einen Besuch in der GROOVEBOX) kostet **1 072 Bytes**
(Probe-Build, noch nicht committet; das Golden bleibt damit gleich). Der Plan, woher der Platz für den Rest kommt, in
der Reihenfolge des Auftrags:

1. **Skiffs Code statt eigenem.** KLANG und MOD sind Skiffs eigene Seiten (EDIT-, ENV-, FX-, LFO-Familie, MIXER) mit
   ihren Karten, Grafiken und Knöpfen; FX, ARP und GLO halten öffnen Skiffs Layer; MOMENTARY, RETURN, Throws, der
   Preset-Browser bleiben Skiffs. Neu ist nur die Weiche (welche Seite, welche Taste wohin) und die Regeln.
2. **Den eigenen Code verkleinern**, ohne die Songs zu ändern – das Golden prüft jede Änderung bitgenau: doppelte
   Helfer (`vb_num`/`vb_hex` neben Skiffs `fmt_int`), Texte, der Takt des Produzenten in der Hauptschleife.
3. **In der GROOVEBOX, was eine FM-1 nicht braucht**: geprüft wird, was im FM-1-Build steckt, ohne gebraucht zu
   werden (SMK-37: nicht im FM-1-Build; Entwicklungs- und Debug-Pfade; doppelte Texte).
4. **Nur für die Pflicht (A)**, falls 1–3 nicht reichen: einzeln gemessene, spürbare GROOVEBOX-Teile. Der erste
   Kandidat sind die Zier-Themes NEON, CRYPT und QUARK (zusammen über 5 KB), weil sie nur das Aussehen betreffen.

Der Flash zwischen App-Bereich (`0x93000`) und den Favoriten (`0x95000`) bleibt liegen: Der Update-Loader schreibt
nur den App-Bereich, sein Paketformat hat eine feste App-Größe, und Skiffs Flash-Karte hat dort keinen Eintrag – das
ohne Risiko zu erweitern, ließe sich ohne Gerät nicht beweisen.

## 4. Tests

| Schritt | Ergebnis |
| --- | --- |
| Release 1.0 aus dem frischen Klon (Datum 28.10.) | bytegleich mit `out/vizzbox-1.0.fwsc` |
| `tests/run_tests.sh` auf dem Nachbau (145 Schritte, 25 min) | **`ALL HOST TESTS PASSED`**, 8 378 Einzelprüfungen „ok“, keine fehlgeschlagen – dieselben Zahlen wie in 1.0 |
| darin `producer_test`, `seqmidi_test` | „producer: all passed“, „seqmidi: all ok“ |
| darin die 176 Regressions-Renders, UI-Goldens, VIZZBOX-Bildschirme | unverändert |
| Golden der Songs aus 1.0 (326 Songs) | gebaut aus dem Baum der 1.0, zweimal gleich |

## Nächste Schritte

Etappe 2: „Hand drauf“ im Produzenten und im Interrupt-Teil, die Wege über die GROOVEBOX und MIDI-CC, mit Tests in
`tests/producer_test.c`. Dann Etappe 3 (Seiten KLANG und MOD, Fokus-Spur, Tasten, GLO-Busse) und weiter nach
Abschnitt 10 des Auftrags.
