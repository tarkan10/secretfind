import std.stdio;
import std.file;
import std.path;
import std.string;
import std.regex;
import std.algorithm;
import std.array;

struct SecretPattern {
    string name;
    Regex!char pattern;
}

void main(string[] args) {
    string targetDir = ".";

    if (args.length > 1) {
        targetDir = args[1];
    }

    if (!exists(targetDir) || !isDir(targetDir)) {
        writefln("Error: Invalid directory path -> %s", targetDir);
        return;
    }

    writeln("==================================================");
    writeln("  secretfind - Secret & Key Scanner (D Language)");
    writefln("  Target Directory: %s", buildNormalizedPath(targetDir));
    writeln("==================================================\n");

    SecretPattern[] patterns = [
        SecretPattern("RSA/SSH Private Key", regex(r"-----BEGIN (RSA|OPENSSH|PRIVATE) KEY-----")),
        SecretPattern("Generic API Key", regex(r"(?i)(api[_-]?key|secret[_-]?key|access[_-]?token)\s*[:=]\s*['" ~ `"` ~ r"]([a-zA-Z0-9_-]{16,})['" ~ `"` ~ r"]")),
        SecretPattern("AWS Access Key ID", regex(r"AKIA[0-9A-Z]{16}")),
        SecretPattern("GitHub Personal Access Token", regex(r"ghp_[a-zA-Z0-9]{36}")),
        SecretPattern("Generic Password in Code", regex(r"(?i)(password|passwd|pwd)\s*[:=]\s*['" ~ `"` ~ r"]([^'" ~ `"` ~ r"]{4,})['" ~ `"` ~ r"]")),
        SecretPattern("JWT Token", regex(r"eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+"))
    ];

    string[] ignoredDirs = [".git", "node_modules", "target", "build", ".venv", "dist"];

    ulong totalFiles = 0;
    ulong totalFindings = 0;

    auto files = dirEntries(targetDir, SpanMode.breadth, false);

    foreach (file; files) {
        if (file.isDir) continue;

        bool shouldIgnore = false;
        foreach (ignored; ignoredDirs) {
            if (file.name.canFind(dirSeparator ~ ignored ~ dirSeparator) || 
                file.name.startsWith("." ~ dirSeparator ~ ignored)) {
                shouldIgnore = true;
                break;
            }
        }
        if (shouldIgnore) continue;

        totalFiles++;

        try {
            auto f = File(file.name, "r");
            ulong lineNumber = 0;

            foreach (line; f.byLine()) {
                lineNumber++;
                
                foreach (p; patterns) {
                    auto match = matchFirst(line, p.pattern);
                    if (!match.empty) {
                        totalFindings++;
                        writefln("[%s] \033[1;31m%s\033[0m", p.name, file.name);
                        writefln("  Line %d: \033[33m%s\033[0m\n", lineNumber, line.strip());
                    }
                }
            }
        } catch (Exception e) {
            continue;
        }
    }

    writeln("--------------------------------------------------");
    writefln("Scan Complete: Analyzed %d files, found \033[1;32m%d sensitive pattern(s)\033[0m.", totalFiles, totalFindings);
}
