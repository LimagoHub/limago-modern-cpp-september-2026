# 01-ownership-raii

## Worum es geht

## Die Denkumstellung

## Beispiele

Jedes Beispiel ist ein eigenständiges Teilprojekt mit `before/` und `after/`
und kann einzeln weitergegeben werden.

### a-file: Datei lesen (`FILE*`)

Pfad: [`a-file/before`](a-file/before/main.cpp), [`a-file/after`](a-file/after/main.cpp)

`read_header` öffnet eine Datei und prüft die Kopfzeile. Im Fehlerpfad
(leere Datei, falscher Kopf) fehlt in `before` das `fclose`. Ein Zähler
zeigt es: nach den vier Aufrufen sind zwei Handles offen. Nichts im Code
sagt, wer für das Schließen zuständig ist.

In `after` hält ein `unique_ptr<FILE, FileCloser>` das Handle. `read_header`
enthält kein `fclose`, der Zähler bleibt bei 0, egal welcher Pfad genommen wird.

```cpp
using FilePtr = std::unique_ptr<FILE, FileCloser>;
FilePtr f = tracked_fopen(path, "r");
if (!f) return false;   // früher Ausstieg ist jetzt sicher
```

Frage im Seminar: Wo steht, wer `fclose` aufruft?

## Übung

## Stolpersteine

## Diskussionspunkte
