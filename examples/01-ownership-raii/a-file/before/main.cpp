// before: klassischer Stil. Wer fclose aufruft, steht nur im Kopf des Entwicklers.
#include <cstdio>
#include <cstring>

static int g_open = 0;  // Zaehler offener Handles, macht das Leck sichtbar
static FILE* tracked_fopen(const char* p, const char* m) {
    FILE* f = std::fopen(p, m);
    if (f) ++g_open;
    return f;
}
static void tracked_fclose(FILE* f) { std::fclose(f); --g_open; }

// Liest die Kopfzeile. Rueckgabe: 0 = ok, -1 = Fehler.
int read_header(const char* path, char* out, int n) {
    FILE* f = tracked_fopen(path, "r");
    if (!f) return -1;
    if (!std::fgets(out, n, f)) return -1;                   // Handle bleibt offen
    if (std::strncmp(out, "SEMINAR", 7) != 0) return -1;     // Handle bleibt offen
    tracked_fclose(f);
    return 0;
}

static void write_file(const char* path, const char* text) {
    FILE* f = std::fopen(path, "w");
    if (!f) return;
    std::fputs(text, f);
    std::fclose(f);
}

int main() {
    write_file("ok.txt", "SEMINAR 1\n");
    write_file("bad.txt", "irgendwas\n");
    write_file("empty.txt", "");

    char line[64];
    const char* files[] = {"ok.txt", "bad.txt", "empty.txt", "missing.txt"};
    for (const char* name : files) {
        int rc = read_header(name, line, sizeof line);
        std::printf("%-12s rc=%2d  offene Handles: %d\n", name, rc, g_open);
    }
    std::remove("ok.txt");
    std::remove("bad.txt");
    std::remove("empty.txt");
}
