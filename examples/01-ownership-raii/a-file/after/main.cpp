// after: Der Typ des Handles sagt, wer aufraeumt. Kein fclose im Code von read_header.
#include <cstdio>
#include <cstring>
#include <memory>
#include <string>

static int g_open = 0;  // Zaehler offener Handles, wie in before
static void tracked_fclose(FILE* f) { std::fclose(f); --g_open; }

struct FileCloser {
    void operator()(FILE* f) const { tracked_fclose(f); }
};
using FilePtr = std::unique_ptr<FILE, FileCloser>;

static FilePtr tracked_fopen(const char* p, const char* m) {
    FILE* f = std::fopen(p, m);
    if (f) ++g_open;
    return FilePtr(f);
}

// Liest die Kopfzeile. Rueckgabe: true = ok.
bool read_header(const char* path, std::string& out) {
    FilePtr f = tracked_fopen(path, "r");
    if (!f) return false;
    char buf[64];
    if (!std::fgets(buf, sizeof buf, f.get())) return false;
    if (std::strncmp(buf, "SEMINAR", 7) != 0) return false;
    out = buf;
    return true;
}

static void write_file(const char* path, const char* text) {
    FilePtr f = tracked_fopen(path, "w");
    if (f) std::fputs(text, f.get());
}

int main() {
    write_file("ok.txt", "SEMINAR 1\n");
    write_file("bad.txt", "irgendwas\n");
    write_file("empty.txt", "");

    std::string line;
    const char* files[] = {"ok.txt", "bad.txt", "empty.txt", "missing.txt"};
    for (const char* name : files) {
        bool ok = read_header(name, line);
        std::printf("%-12s ok=%d  offene Handles: %d\n", name, ok, g_open);
    }
    std::remove("ok.txt");
    std::remove("bad.txt");
    std::remove("empty.txt");
}
