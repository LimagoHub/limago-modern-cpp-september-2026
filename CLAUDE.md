# Projekt: Seminar "Modernes C++" (C++11/14/17)

## Was das hier ist

Dieses Repository enthält das Material für ein mehrtägiges Firmenseminar.
Es ist **kein Produktivprojekt**. Das Ergebnis sind Beispiele, Übungen und
ein durchgehendes Skript — keine auslieferbare Software.

Die Teilnehmer sind erfahrene Entwickler, die seit Jahren C++ schreiben,
aber in C bzw. klassischem C++98 geprägt sind. Das Seminar ist eine
Denkschulung, keine Syntaxschulung: Konzepte zuerst, Syntax dort, wo sie
gebraucht wird.

Roter Faden des gesamten Materials:
> Im klassischen C++ sind Lebensdauer und Eigentümerschaft Konvention,
> Kommentar und Disziplin. In modernem C++ sind sie Teil des Typsystems.

## Arbeitsmodus — WICHTIG

**Standard ist: erst vorschlagen, dann umsetzen.**

- Schreibe oder ändere Dateien **nur**, wenn ich das ausdrücklich verlange.
- Formulierungen wie "Frage:", "Was wäre wenn", "Wie würdest du",
  "Was hältst du von", "Überlegung:" sind **rein hypothetisch**.
  Antworte darauf nur im Chat. Lege nichts an, ändere nichts.
- Erst bei "Umsetzen:", "Mach das", "Leg an", "Schreib das" wird geändert.
- Wenn unklar ist, ob ich eine Frage stelle oder einen Auftrag gebe:
  nachfragen. Nicht raten.
- Bei größeren Änderungen: vorher kurz skizzieren, was du anlegen würdest,
  und auf mein OK warten.
- Arbeite in kleinen Schritten. Lieber ein Baustein sauber als drei grob.
- Nimm keine Aufräum- oder Refactoring-Arbeiten "nebenbei" vor.

## Repository-Struktur

/README.md                 Das Skript (siehe unten)
/CLAUDE.md                 Diese Datei
/docs/                     Kapiteltexte, falls README zu groß wird
/templates/                Vorlagen für ein Teilprojekt und Hilfsskripte
    CMakeLists.txt         Vorlage, in allen Teilprojekten identisch
    CMakePresets.json      Vorlage, in allen Teilprojekten identisch
    build-all.ps1          Findet alle Teilprojekte, konfiguriert und baut einzeln
    sync-templates.ps1     Meldet Abweichungen von den Vorlagen; -Apply verteilt sie
/examples/NN-name/         Ein Verzeichnis je Baustein
    README.md              Notizen zum Baustein, Quelle fürs Skript
    before/                Ausgangscode im klassischen Stil (Teilprojekt)
    after/                 Moderne Fassung (Teilprojekt)
/exercises/NN-name/
    README.md              Abschnittsgerüst wie bei examples
    task.md                Aufgabenstellung für die Teilnehmer
    start/                 Startpunkt (Teilprojekt)
    solution/              Lösung (Teilprojekt; bleibt im Repo, nicht ausgeteilt)

Es gibt keine Wurzel-CMakeLists.txt und keine Wurzel-CMakePresets.json.
Jedes Teilprojekt (before/, after/, start/, solution/) hat eigene
CMakeLists.txt und CMakePresets.json und wird einzeln in CLion geöffnet.
`templates/build-all.ps1` ersetzt den gemeinsamen Build.

Nummerierung der Bausteine:
01 ownership-raii
02 value-semantics
03 move
04 types-invariants
05 error-handling
06 compile-time
07 expressing-intent
08 undefined-behavior
09 concurrency-overview
10 cpp17-delta

## README.md — das Skript

Die README ist das durchgehende Seminarskript und das zentrale Artefakt
dieses Repos. Sie wird **nach jedem abgeschlossenen Schritt fortgeschrieben**,
ohne dass ich das jedes Mal erwähnen muss.

Regeln:
- Struktur der README folgt der Bausteinnummerierung.
- Je Baustein: Worum es geht (Konzept, nicht Syntax) — Die Denkumstellung —
  Beispiele mit Verweis auf den Pfad — Übung — Stolpersteine — Diskussionspunkte.
- Bestehende Abschnitte werden **ergänzt, nicht überschrieben**. Wenn etwas
  ersetzt werden soll, sag mir vorher, was wegfällt.
- Codebeispiele in der README nur als kurze Ausschnitte; das Vollständige
  liegt unter examples/ und wird von dort verlinkt.
- Kein Marketing-Ton, keine Einleitungsfloskeln. Der Text wird im Seminar
  vorgelesen bzw. ausgeteilt.
- Deutsch. Fachbegriffe bleiben englisch (ownership, lifetime, move,
  undefined behavior). Keine erzwungenen Eindeutschungen.
- Du-Form, wie im Seminar gesprochen wird.

## Technische Randbedingungen

- Windows 11, CLion, CMake.
- Toolchains: Referenz ist MinGW-w64 GCC 13.1. MSVC ist vorhanden und
  wird als Portabilitäts-Gegenprobe genutzt. Clang ist nicht installiert.
  Falls Clang später hinzukommt: clang++ mit MinGW-Target, nicht clang-cl.
- C++17 als Projektstandard. Wo ein Beispiel bewusst älteren Stand zeigt,
  wird das im Code kommentiert, nicht über den Standard gesteuert.
- Jedes Beispiel muss ein eigenes, baubares und lauffähiges CMake-Target sein.
- `before/`-Code ist absichtlich schlecht (Leaks, doppelte Freigabe,
  Cleanup-Kaskaden). Er muss trotzdem bauen — Warnungen dort bewusst
  herunterdrehen, nie das ganze Projekt auf niedrige Warnstufe setzen.
- `after/`-Code baut mit hoher Warnstufe warnungsfrei.
- Beispiele klein halten: eine Idee pro Beispiel, möglichst unter 60 Zeilen.
- Keine externen Abhängigkeiten außer der Standardbibliothek. Kein Boost,
  kein vcpkg, kein Test-Framework, solange ich nichts anderes sage.
- Wo Sanitizer sinnvoll sind (Baustein 08), dafür ein eigenes Preset.

## Was in den Beispielen zählt

- Realistisch wirkender Ressourcencode: Dateihandles, Sockets, Geräte,
  Mutexe, eigene Puffer. Kein `Animal`/`Shape`/`Dog`-Vererbungsbeispiel.
- Vererbung wird bewusst vermieden. Objektorientierung wird in diesem
  Seminar über Invarianten und Typen vermittelt, nicht über Hierarchien.
- Zu jedem Beispiel gehört die Frage, die es im Seminar auslösen soll.
  Die kommt in die README des Bausteins.

## Git

- Kleine, thematische Commits, ein Baustein pro Commit-Serie.
- Commit-Messages deutsch, Präfix mit Bausteinnummer, z. B.
  `01: RAII-Wrapper um FILE* als Beispiel ergänzt`
- Committen nur, wenn ich es sage.