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

Voraussetzungen in CLion: Unter *Settings → Build, Execution, Deployment → Toolchains* müssen die Toolchains `MinGW` und `Visual Studio 64bit` heißen. Die Presets verweisen per Name darauf. Bei `msvc-debug` zählt die 64-Bit-Variante. Mit der 32-Bit-Toolchain baut das Preset zwar, vergleicht aber etwas anderes als `build-all.ps1`.

Sanitizer gibt es im Gerüst nicht. Ob und wie sie bei Baustein 08 eingesetzt werden, hängt davon ab, was die Toolchain mitbringt. MinGW-GCC liefert `libasan` und `libubsan` üblicherweise nicht mit, MSVC kann nur AddressSanitizer. Baustein 08 baut deshalb nicht darauf auf.

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

### Worum es geht

Jede Ressource hat einen Besitzer: ein Dateihandle, ein Socket, ein Puffer, ein Mutex. Der Besitzer ist dafür verantwortlich, sie genau einmal freizugeben. Im klassischen C++ steht das nirgends im Code. Es steht in Kommentaren, in Namenskonventionen ("`create_` muss mit `destroy_` freigegeben werden") und im Kopf des Entwicklers, der die Funktion geschrieben hat. Jeder zusätzliche `return` und jede Exception ist eine Stelle, an der die Disziplin reißen kann.

In modernem C++ wird der Besitzer ein Objekt, und die Freigabe passiert automatisch, wenn das Objekt verschwindet.

### Grundlagen: Was du für diesen Baustein brauchst

Dieser Abschnitt erklärt die Bausteine, die in den Beispielen vorkommen. Wenn du sie schon kennst, überspring ihn.

#### Der Destruktor läuft immer

Ein lokales Objekt wird am Ende seines Blocks zerstört, und zwar auf **jedem** Weg hinaus: normales Blockende, `return`, `break`, Exception. Dabei wird sein Destruktor aufgerufen. Das ist keine neue Sprachfunktion, das gab es schon in C++98. Neu ist nur, dass wir es konsequent als Werkzeug einsetzen.

```cpp
void f() {
    Logger log;        // Konstruktor
    if (fehler) return; // Destruktor von log läuft hier
    arbeite();          // kann werfen: Destruktor läuft trotzdem
}                       // und hier
```

#### RAII

RAII steht für *Resource Acquisition Is Initialization*. Der Name ist unglücklich, die Idee ist einfach:

- Die Ressource wird im **Konstruktor** erworben (Datei öffnen, Speicher holen, Mutex sperren).
- Sie wird im **Destruktor** freigegeben.
- Damit gilt: Die Ressource lebt genau so lange wie das Objekt.

Du schreibst das `fclose` also nicht mehr an jede Ausstiegsstelle, sondern einmal in den Destruktor. Der Compiler fügt den Aufruf an allen Ausstiegsstellen ein. Du kannst ihn nicht mehr vergessen.

#### Smart pointer, hier `std::unique_ptr`

Ein smart pointer ist ein Objekt, das sich wie ein Zeiger benutzen lässt und zugleich Besitzer ist. `std::unique_ptr<T>` (ab C++11, Header `<memory>`) ist der einfachste:

- Er besitzt genau ein Objekt. Es gibt nie zwei Besitzer.
- Er ist **nicht kopierbar**. Der Compiler lehnt eine Kopie ab. Der Besitz kann nur weitergegeben werden (das ist Baustein 03, move).
- Im Destruktor gibt er das Objekt frei. Standardmäßig mit `delete`.

```cpp
std::unique_ptr<Buffer> p(new Buffer(1024));
p->fill();            // benutzt sich wie ein Zeiger
Buffer* raw = p.get(); // rohen Zeiger ansehen, Besitz bleibt bei p
                       // kein delete nötig
```

Ab C++14 gibt es `std::make_unique<Buffer>(1024)`. Es vermeidet das sichtbare `new`.

Wichtig für die Denkweise: Ein `unique_ptr` in einer Signatur oder einem Member **sagt**, wer besitzt. Ein roher Zeiger `T*` sagt das nicht. Er kann "gehört mir", "gehört dir" oder "nur ansehen" bedeuten.

#### Eigener Deleter: Ressourcen, die nicht mit `delete` enden

Ein `FILE*` wird nicht mit `delete` freigegeben, sondern mit `fclose`. `unique_ptr` nimmt deshalb einen zweiten Typparameter: den **Deleter**. Er wird statt `delete` aufgerufen.

```cpp
std::unique_ptr<FILE, FileCloser> f(std::fopen(path, "r"));
```

Der Deleter muss etwas sein, das man mit dem Zeiger aufrufen kann: `FileCloser{}(ptr)`.

#### Funktionsobjekt

Ein Funktionsobjekt ist ein Objekt einer Klasse, die `operator()` definiert. Man ruft es wie eine Funktion auf:

```cpp
struct FileCloser {
    void operator()(FILE* f) const { std::fclose(f); }
};

FileCloser close;
close(handle);      // sieht aus wie ein Funktionsaufruf, ist aber ein Objekt
```

Warum nicht einfach einen Funktionszeiger `&std::fclose` als Deleter? Das geht, hat aber zwei Nachteile: Der Zeiger wird in jedem `unique_ptr` mitgespeichert, und der Aufruf ist für den Compiler schwerer zu inlinen. Ein leeres Funktionsobjekt kostet dagegen keinen Speicher, der Typ selbst legt fest, was aufgerufen wird. Außerdem kann ein Funktionsobjekt Zustand tragen, eine Funktion nicht. Das braucht man später bei Lambdas (Baustein 07) wieder, ein Lambda ist nichts anderes als ein vom Compiler erzeugtes Funktionsobjekt.

#### Typalias mit `using`

`using FilePtr = std::unique_ptr<FILE, FileCloser>;` ist die C++11-Schreibweise für `typedef`. Sie liest sich von links nach rechts ("FilePtr ist ...") und funktioniert auch für Templates.

### Beispiel a: Datei lesen

Pfad: [`examples/01-ownership-raii/a-file/before`](examples/01-ownership-raii/a-file/before/main.cpp) und [`.../after`](examples/01-ownership-raii/a-file/after/main.cpp).

`read_header` öffnet eine Datei und prüft die Kopfzeile. Hier `before`:

```cpp
FILE* f = tracked_fopen(path, "r");
if (!f) return -1;
if (!std::fgets(out, n, f)) return -1;                // Handle bleibt offen
if (std::strncmp(out, "SEMINAR", 7) != 0) return -1;  // Handle bleibt offen
tracked_fclose(f);
return 0;
```

Der Fehlerpfad vergisst das `fclose`. Der Zähler im Beispiel zeigt nach vier Aufrufen zwei offene Handles. Den Fehler findet man beim Lesen nur, wenn man bei jedem `return` nachzählt.

In `after` hält ein `FilePtr` das Handle:

```cpp
FilePtr f = tracked_fopen(path, "r");
if (!f) return false;
if (!std::fgets(buf, sizeof buf, f.get())) return false;
```

Es gibt kein `fclose` mehr in der Funktion. Jeder Ausstieg schließt die Datei, und man kann den Fehler nicht mehr machen. Ein früher `return` ist jetzt unproblematisch.

**Frage an dich:** Wo steht in `before`, wer `fclose` aufrufen muss? Und wo steht es in `after`?

## 02 value-semantics

## 03 move

## 04 types-invariants

## 05 error-handling

## 06 compile-time

## 07 expressing-intent

## 08 undefined-behavior

## 09 concurrency-overview

## 10 cpp17-delta
