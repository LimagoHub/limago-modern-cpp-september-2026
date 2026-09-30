# limago-modern-cpp-september-2026

Seminar „Modernes C++" (C++11/14/17)

## Zweck

Dieses Repository enthält Beispiele, Übungen und das durchgehende Skript für ein mehrtägiges Firmenseminar. Es ist kein Produktivprojekt.

Das Seminar richtet sich an erfahrene Entwickler, die aus C bzw. klassischem C++98 kommen. Es ist eine Denkschulung, keine Syntaxschulung: Konzepte zuerst, Syntax dort, wo sie gebraucht wird.

Der rote Faden:

> Im klassischen C++ sind Lebensdauer und Eigentümerschaft Konvention,
> Kommentar und Disziplin. In modernem C++ sind sie Teil des Typsystems.

## Inhalt

1. [01 ownership-raii](#01-ownership-raii)
2. [02 value-semantics](#02-value-semantics)
3. [03 move](#03-move)
4. [04 types-invariants](#04-types-invariants)
5. [05 error-handling](#05-error-handling)
6. [06 compile-time](#06-compile-time)
7. [07 expressing-intent](#07-expressing-intent)
8. [08 undefined-behavior](#08-undefined-behavior)
9. [09 concurrency-overview](#09-concurrency-overview)
10. [10 cpp17-delta](#10-cpp17-delta)

## Wie dieses Repo benutzt wird

### Aufbau

Zu jedem Baustein gibt es `examples/NN-name/` und `exercises/NN-name/`. Darin liegen die Teilprojekte:

| Verzeichnis | Inhalt |
|---|---|
| `examples/NN-name/before/` | Ausgangscode im klassischen Stil, absichtlich schlecht |
| `examples/NN-name/after/` | Moderne Fassung |
| `exercises/NN-name/start/` | Startpunkt für die Teilnehmer |
| `exercises/NN-name/solution/` | Lösung |

### In CLion öffnen

Jedes Teilprojekt wird **einzeln** geöffnet: *File → Open* und dann das Verzeichnis `before/`, `after/`, `start/` oder `solution/` wählen, nicht die Repo-Wurzel. Es gibt keine Wurzel-`CMakeLists.txt`. Jedes Teilprojekt bringt `CMakeLists.txt` und `CMakePresets.json` mit und ist ein eigenes, baubares und lauffähiges Target.

### Presets

| Preset | Wofür |
|---|---|
| `mingw-debug` | Referenz: MinGW-w64 GCC 13.1. Normaler Arbeitsmodus. |
| `mingw-release` | Referenz mit Optimierung, zum Vergleich von Debug und Release. |
| `msvc-debug` | Gegenprobe: Verhält sich der Code mit MSVC genauso? |

Die Presets setzen C++17 mit `CMAKE_CXX_EXTENSIONS=OFF`. Gebaut wird nach `build/<preset>/` im jeweiligen Teilprojekt.

### Warnstufen

Im `after/`-Code gilt die hohe Warnstufe (MSVC `/W4 /permissive-`, GCC `-Wall -Wextra -Wpedantic` und je nach Version `-Wuse-after-free` und `-Wdangling-reference`). Der Code baut warnungsfrei. Im `before/`-Code ist sie abgeschaltet, weil er absichtlich Leaks und Fehler enthält. Das regelt die `CMakeLists.txt` am Verzeichnisnamen, nur für das jeweilige Target.

### Skripte

Beide liegen unter `templates/`:

```powershell
templates\build-all.ps1                  # alle Teilprojekte, nur MinGW
templates\build-all.ps1 -WithMsvc        # zusätzlich msvc-debug
templates\build-all.ps1 -Path examples\01-ownership-raii

templates\sync-templates.ps1             # meldet Abweichungen von den Vorlagen
templates\sync-templates.ps1 -Apply      # verteilt die Vorlagen in alle Teilprojekte
```

`CMakeLists.txt` und `CMakePresets.json` sind in allen Teilprojekten identisch. Änderungen gehören in `templates/` und werden von dort verteilt.

## 01 ownership-raii

## 02 value-semantics

## 03 move

## 04 types-invariants

## 05 error-handling

## 06 compile-time

## 07 expressing-intent

## 08 undefined-behavior

## 09 concurrency-overview

## 10 cpp17-delta
