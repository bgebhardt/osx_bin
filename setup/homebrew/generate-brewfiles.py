#!/usr/bin/env python3
"""Merge brew bundle dump output with curated source-script structure.

Reads the user's setup/homebrew/*.sh scripts and the authoritative dump at
/tmp/Brewfile.generated, then writes three Brewfiles preserving section
headers, inline annotations, and tap-consumer comments.
"""
from __future__ import annotations
import re
import socket
from datetime import date
from pathlib import Path

HOME = Path("/Users/bryan/bin/setup/homebrew")
MAS_SH = Path("/Users/bryan/bin/setup/appstore/mas.sh")
DUMP = Path("/tmp/Brewfile.generated")
OUT_MIN = HOME / "Brewfile.minimum"
OUT_WORK = HOME / "Brewfile.work"


def snapshot_path() -> Path:
    """Per-machine, per-day dump filename: Brewfile.<hostname>.<YYYY-MM-DD>.

    The hand-curated master lives at setup/homebrew/Brewfile and is NEVER
    written by this generator. Snapshots are diffable references — compare
    one against the master to see drift, or compare snapshots across machines
    or dates.
    """
    hostname = socket.gethostname().split(".")[0]  # strip .local / .lan
    return HOME / f"Brewfile.{hostname}.{date.today().isoformat()}"

# ---------- Parsing source scripts ----------

# section header line in a shell script: starts with one or more '#' optionally
# preceded by blank, contains no trailing code semantics. We treat anything in
# the form "# Title" (where Title is short and capitalized-ish) as a section.
SECTION_RE = re.compile(r"^\s*##?\s+([A-Za-z][A-Za-z0-9 /&\-+,'.]{1,60})\s*$")

# Verbs/prefixes that indicate a sentence comment, not a section header.
NON_SECTION_PREFIXES = (
    "install", "upgrade", "remove", "make", "note", "see", "check", "add",
    "set", "switch", "build", "use", "skim", "consider", "trying", "trying ",
    "alternative", "deprecated", "free", "paid", "warning", "todo", "fix",
    "ensure", "configure", "open", "test", "let", "verify", "decide",
    "switching", "moved", "if ", "the ", "an ", "a ", "this ", "that ",
    "i ", "we ", "they ", "in ", "from ", "to ", "of ", "for ",
    "clean", "non-brew", "non", "skip", "look", "find", "create", "switch",
    "retired", "old",
)
# Words that indicate a sentence comment even if first word is capitalized.
NON_SECTION_KEYWORDS = (
    "http", "://", "broken", "deprecated", "conflict", "no longer",
    "doesn't", "doesn’t", "won't", "won’t", "needs to", "needed",
    "instead", "replaced", "retired", "disabled",
)

# install lines we care about:
#   brew install foo  # comment
#   brew install --cask foo
#   brew install foo --bar  (flags after name still count)
#   brew cask install foo (legacy)
#   brew tap foo/bar
#   mas install 12345 # Name
INSTALL_RE = re.compile(
    r"^\s*brew\s+(?:cask\s+)?install\s+(?:--cask\s+)?([^\s#]+)(?:\s+[^#]*)?(?:\s*#\s*(.*))?$"
)
TAP_RE = re.compile(r"^\s*brew\s+tap\s+([^\s#]+)\s*(?:#\s*(.*))?$")
MAS_RE = re.compile(r"^\s*mas\s+install\s+(\d+)\s*(?:#\s*(.*))?$")


def looks_like_section(title: str, double_hash: bool) -> bool:
    """Strict heuristic: is this comment text a real section header?"""
    t = title.strip()
    if not t:
        return False
    if t.endswith("."):
        return False
    if t.endswith(":"):
        return False
    if "(" in t and ")" in t and len(t) > 30:
        return False
    low = t.lower()
    for kw in NON_SECTION_KEYWORDS:
        if kw in low:
            return False
    # Word count: ≤ 5 for single-#, ≤ 7 for ##.
    word_count = len(t.split())
    if double_hash:
        if word_count > 7:
            return False
    else:
        if word_count > 5:
            return False
    # Skip sentence-starter first words.
    first_word = t.split()[0].lower()
    if first_word in {p.strip() for p in NON_SECTION_PREFIXES}:
        return False
    # Skip hyphenated single-word titles — those look like package names
    # (e.g. "disk-inventory-x"), not section headers.
    if word_count == 1 and "-" in t:
        return False
    return True


def _parse_install_line(
    line: str, file_name: str, line_num: int, commented: bool
) -> dict | None:
    """Match one line as a tap / mas / brew (formula or cask) install entry.

    When `commented` is True, the line was reached by stripping a leading `#`
    and the resulting record is a tombstone — it gets `source_file` /
    `source_line` so the snapshot can annotate where it came from.
    """
    src_file = file_name if commented else None
    src_line = line_num if commented else None
    m = TAP_RE.match(line)
    if m:
        return {
            "kind": "tap",
            "name": m.group(1),
            "comment": (m.group(2) or "").strip() or None,
            "commented_out": commented,
            "source_file": src_file,
            "source_line": src_line,
        }
    m = MAS_RE.match(line)
    if m:
        return {
            "kind": "mas",
            "id": m.group(1),
            "comment": (m.group(2) or "").strip() or None,
            "commented_out": commented,
            "source_file": src_file,
            "source_line": src_line,
        }
    m = INSTALL_RE.match(line)
    if m:
        is_cask = bool(
            re.match(r"^\s*brew\s+(?:cask\s+install|install\s+--cask)\b", line)
        )
        return {
            "kind": "brew",
            "name": m.group(1),
            "comment": (m.group(2) or "").strip() or None,
            "is_cask": is_cask,
            "commented_out": commented,
            "source_file": src_file,
            "source_line": src_line,
        }
    return None


def parse_script(path: Path) -> list[dict]:
    """Parse a shell setup script into an ordered list of records.

    Each record is one of:
      {"kind": "section", "title": str}
      {"kind": "brew",    "name": str, "comment": str|None, "is_cask": bool,
                          "commented_out": bool, "source_file": str|None,
                          "source_line": int|None}
      {"kind": "tap",     "name": str, ...}
      {"kind": "mas",     "id": str,   ...}

    Commented-out `# brew install foo`, `# brew tap foo`, and `# mas install N`
    lines become tombstone records (commented_out=True) so the snapshot
    Brewfile can emit them as `# cask "foo"  # [tombstone …]`. State-sync's
    promotion logic matches against these. Other commented patterns (pipx,
    curl, llm, …) are skipped — they have no Brewfile equivalent.
    """
    records: list[dict] = []
    if not path.exists():
        return records
    raw_lines = path.read_text().splitlines()
    file_name = path.name
    for idx, raw in enumerate(raw_lines):
        line = raw.rstrip("\n")
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("#"):
            uncommented = re.sub(r"^#+\s?", "", stripped)
            # Tombstone-eligible: commented brew/mas/tap lines.
            if re.match(r"^(brew|mas)\b", uncommented):
                rec = _parse_install_line(
                    uncommented, file_name, idx + 1, commented=True
                )
                if rec is not None:
                    records.append(rec)
                continue
            # Other commented install-ish patterns: drop entirely (no Brewfile form).
            if re.match(r"^(pipx|pip|go|npm|llm|curl|echo)\b", uncommented):
                continue
            # Section headers (line is purely a comment).
            m = SECTION_RE.match(line)
            if m:
                title = m.group(1).strip()
                double_hash = stripped.startswith("##")
                # Require: preceded by blank line (or start of file).
                prev_blank = (idx == 0) or (raw_lines[idx - 1].strip() == "")
                if prev_blank and looks_like_section(title, double_hash):
                    records.append({"kind": "section", "title": title})
            continue
        # Active install / tap / mas.
        rec = _parse_install_line(line, file_name, idx + 1, commented=False)
        if rec is not None:
            records.append(rec)
    return records


def index_records(records: list[dict], section_order: list[str]):
    """Build a lookup of active entries plus a list of tombstones.

    Returns (idx, tombstones).
      idx: (kind, name-or-id) -> {section, comment} for active entries only.
      tombstones: list of commented-out records with `section` attached.

    Also extends section_order in place with sections in first-seen order.
    `kind` is 'brew', 'cask', 'tap', or 'mas'.
    """
    idx: dict[tuple[str, str], dict] = {}
    tombstones: list[dict] = []
    current_section = None
    seen_sections = set(section_order)
    for rec in records:
        if rec["kind"] == "section":
            current_section = rec["title"]
            if current_section not in seen_sections:
                section_order.append(current_section)
                seen_sections.add(current_section)
            continue
        if rec.get("commented_out"):
            tombstones.append({**rec, "section": current_section})
            continue
        if rec["kind"] == "brew":
            key_kind = "cask" if rec["is_cask"] else "brew"
            short = rec["name"].split("/")[-1]
            entry = {"section": current_section, "comment": rec["comment"]}
            idx[(key_kind, short)] = entry
            idx[(key_kind, rec["name"])] = entry
        elif rec["kind"] == "tap":
            idx[("tap", rec["name"].lower())] = {
                "section": current_section,
                "comment": rec["comment"],
            }
        elif rec["kind"] == "mas":
            idx[("mas", rec["id"])] = {
                "section": current_section,
                "comment": rec["comment"],
            }
    return idx, tombstones


# ---------- Parsing the brew bundle dump ----------

DUMP_TAP = re.compile(r'^tap\s+"([^"]+)"')
DUMP_BREW = re.compile(r'^brew\s+"([^"]+)"(.*)$')
DUMP_CASK = re.compile(r'^cask\s+"([^"]+)"(.*)$')
DUMP_MAS = re.compile(r'^mas\s+"([^"]+)",\s+id:\s+(\d+)')
DUMP_VSCODE = re.compile(r'^vscode\s+"([^"]+)"')
DUMP_GO = re.compile(r'^go\s+"([^"]+)"')
DUMP_NPM = re.compile(r'^npm\s+"([^"]+)"')
DUMP_UV = re.compile(r'^uv\s+"([^"]+)"')
DUMP_CARGO = re.compile(r'^cargo\s+"([^"]+)"')


def parse_dump(path: Path) -> dict:
    taps: list[str] = []
    brews: list[tuple[str, str, str | None, str]] = []  # (short, full, stock_desc, extra)
    casks: list[tuple[str, str | None, str]] = []  # (full, stock_desc, extra)
    masapps: list[tuple[str, str, str | None]] = []  # (name, id, _)
    vscode: list[str] = []
    gos: list[str] = []
    npms: list[str] = []
    uvs: list[str] = []
    cargos: list[str] = []
    last_desc: str | None = None
    for raw in path.read_text().splitlines():
        line = raw.rstrip()
        if line.startswith("#"):
            last_desc = line[1:].strip()
            continue
        m = DUMP_TAP.match(line)
        if m:
            taps.append(m.group(1))
            last_desc = None
            continue
        m = DUMP_BREW.match(line)
        if m:
            full = m.group(1)
            extra = m.group(2)
            short = full.split("/")[-1]
            brews.append((short, full, last_desc, extra))
            last_desc = None
            continue
        m = DUMP_CASK.match(line)
        if m:
            full = m.group(1)
            extra = m.group(2)
            casks.append((full, last_desc, extra))
            last_desc = None
            continue
        m = DUMP_MAS.match(line)
        if m:
            masapps.append((m.group(1), m.group(2), last_desc))
            last_desc = None
            continue
        m = DUMP_VSCODE.match(line)
        if m:
            vscode.append(m.group(1))
            last_desc = None
            continue
        m = DUMP_GO.match(line)
        if m:
            gos.append(m.group(1))
            last_desc = None
            continue
        m = DUMP_NPM.match(line)
        if m:
            npms.append(m.group(1))
            last_desc = None
            continue
        m = DUMP_UV.match(line)
        if m:
            uvs.append(m.group(1))
            last_desc = None
            continue
        m = DUMP_CARGO.match(line)
        if m:
            cargos.append(m.group(1))
            last_desc = None
            continue
        # blank or anything else
        last_desc = None
    return {
        "taps": taps,
        "brews": brews,
        "casks": casks,
        "mas": masapps,
        "vscode": vscode,
        "go": gos,
        "npm": npms,
        "uv": uvs,
        "cargo": cargos,
    }


# ---------- Tap consumer detection ----------

def tap_consumers(brews, casks) -> dict[str, list[str]]:
    """Map tap (lowercased) -> list of short names of formulae/casks that use it."""
    out: dict[str, list[str]] = {}
    for short, full, _desc, _extra in brews:
        if "/" in full:
            parts = full.split("/")
            if len(parts) >= 3:
                tap = f"{parts[0]}/{parts[1]}".lower()
                out.setdefault(tap, []).append(short)
    for full, _desc, _extra in casks:
        if "/" in full:
            parts = full.split("/")
            if len(parts) >= 3:
                tap = f"{parts[0]}/{parts[1]}".lower()
                out.setdefault(tap, []).append(parts[-1])
    return out


# ---------- Section ordering ----------

DISCOVERED_SECTION = "(not in source scripts — discovered via brew bundle dump)"


# ---------- Output formatting ----------

def fmt_comment(c: str | None) -> str:
    if not c:
        return ""
    return "  # " + c


def fmt_brew(full: str, comment: str | None, extra: str = "") -> str:
    base = f'brew "{full}"{extra.rstrip()}'
    return base + fmt_comment(comment)


def fmt_cask(full: str, comment: str | None, extra: str = "") -> str:
    base = f'cask "{full}"{extra.rstrip()}'
    return base + fmt_comment(comment)


def fmt_tap(name: str, consumers: list[str], user_comment: str | None) -> str:
    base = f'tap "{name}"'
    # Prefer user's explicit comment; else annotate with detected consumers.
    if user_comment:
        return base + "  # " + user_comment
    if consumers:
        seen = sorted(set(consumers))
        return base + f"  # for {', '.join(seen)}"
    return base


def fmt_mas(name: str, idnum: str, comment: str | None) -> str:
    base = f'mas "{name}", id: {idnum}'
    return base + fmt_comment(comment)


def _tombstone_suffix(tomb: dict) -> str:
    """Build the trailing `# [tombstone src:line] comment` annotation."""
    bits: list[str] = []
    src_file = tomb.get("source_file")
    src_line = tomb.get("source_line")
    if src_file and src_line:
        bits.append(f"[tombstone {src_file}:{src_line}]")
    if tomb.get("comment"):
        bits.append(tomb["comment"])
    return ("  # " + " ".join(bits)) if bits else ""


def fmt_tombstone(tomb: dict) -> str:
    """Render a tombstone record as a commented Brewfile entry.

    State-sync's promotion lookup matches `# cask "X"` / `# brew "X"` /
    `# mas "X", id: N` / `# tap "X"` against these lines.
    """
    if tomb["kind"] == "tap":
        return f'# tap "{tomb["name"]}"' + _tombstone_suffix(tomb)
    if tomb["kind"] == "mas":
        name = clean_mas_name(tomb.get("comment"), tomb["id"])
        return f'# mas "{name}", id: {tomb["id"]}' + _tombstone_suffix(tomb)
    # brew formula or cask
    keyword = "cask" if tomb.get("is_cask") else "brew"
    return f'# {keyword} "{tomb["name"]}"' + _tombstone_suffix(tomb)


def clean_mas_name(comment: str | None, idnum: str) -> str:
    """Extract a clean app name from a source-script comment like
    'OwlOCR - Screenshot to Text (6.0.6)' -> 'OwlOCR'.
    """
    if not comment:
        return f"App {idnum}"
    name = comment.split(" - ")[0].split(" — ")[0].split(":")[0]
    name = re.sub(r"\s*\([^)]*\)\s*$", "", name).strip()
    return name or f"App {idnum}"


# ---------- Build the full Brewfile ----------

def _bucket_tombstones(tombstones: list[dict], all_idx: dict) -> dict:
    """Group tombstones for output: by section for brew/cask, flat for tap/mas.

    Dedupes by canonical key (so the same commented entry appearing in multiple
    source scripts is only emitted once). Skips tombstones whose name has an
    active counterpart in `all_idx` — no point listing both.
    """
    by_section: dict[str, dict[str, list[dict]]] = {}
    taps: list[dict] = []
    masapps: list[dict] = []
    seen: set[tuple[str, str]] = set()
    for tomb in tombstones:
        kind = tomb["kind"]
        if kind == "brew":
            short = tomb["name"].split("/")[-1]
            kind_str = "cask" if tomb.get("is_cask") else "brew"
            key = (kind_str, short)
            if key in seen or (kind_str, short) in all_idx or (kind_str, tomb["name"]) in all_idx:
                continue
            seen.add(key)
            section = tomb.get("section") or DISCOVERED_SECTION
            slot = "cask" if tomb.get("is_cask") else "brew"
            by_section.setdefault(section, {"brew": [], "cask": []})[slot].append(tomb)
        elif kind == "tap":
            key = ("tap", tomb["name"].lower())
            if key in seen or key in all_idx:
                continue
            seen.add(key)
            taps.append(tomb)
        elif kind == "mas":
            key = ("mas", tomb["id"])
            if key in seen or key in all_idx:
                continue
            seen.add(key)
            masapps.append(tomb)
    return {"by_section": by_section, "taps": taps, "mas": masapps}


def build_full(
    brew_idx,
    cask_idx,
    all_idx,
    tombstones: list[dict],
    dump,
    section_order,
    snapshot_name: str,
) -> str:
    lines: list[str] = []
    lines.append(f"# {snapshot_name} — per-machine, per-day snapshot of installed packages.")
    lines.append("# Generated from `brew bundle dump --describe`, merged with curated section")
    lines.append("# headers and inline comments from setup/homebrew/brew.sh and brew-cask.sh.")
    lines.append("#")
    lines.append("# THIS IS NOT THE MASTER. The hand-curated master is setup/homebrew/Brewfile,")
    lines.append("# which is never overwritten by the generator. Use this snapshot to:")
    lines.append("#   - diff against the master to find drift")
    lines.append("#   - compare against snapshots from other machines or dates")
    lines.append("#   - regenerate the master from a known-good state if needed")
    lines.append("#")
    lines.append("# Source-of-truth journal (deprecated entries, commentary, history) lives in")
    lines.append("# the brew*.sh scripts — they are unchanged. Tombstone lines (`# cask \"X\"`")
    lines.append("# with `[tombstone …]` annotation) mirror commented `# brew install X` lines")
    lines.append("# from the source scripts, so state-sync can promote manually-installed apps")
    lines.append("# to a brew/mas line without re-parsing the source scripts.")
    lines.append("")

    tomb_buckets = _bucket_tombstones(tombstones, all_idx)

    # Taps
    consumers = tap_consumers(dump["brews"], dump["casks"])
    lines.append("# Taps")
    for tap in sorted(dump["taps"]):
        rec = all_idx.get(("tap", tap.lower()))
        user_comment = rec["comment"] if rec else None
        lines.append(fmt_tap(tap, consumers.get(tap.lower(), []), user_comment))
    for tomb in sorted(tomb_buckets["taps"], key=lambda t: t["name"].lower()):
        lines.append(fmt_tombstone(tomb))
    lines.append("")

    # Group brews and casks by section. Items within a section are kept as
    # (sort-key, formatted-line) tuples so we can sort alphabetically before
    # emission.
    grouped: dict[str, dict[str, list[tuple[str, str]]]] = {}
    for short, full, stock_desc, extra in dump["brews"]:
        rec = brew_idx.get(short) or brew_idx.get(full)
        section = (rec and rec["section"]) or DISCOVERED_SECTION
        comment = (rec and rec["comment"]) or stock_desc
        grouped.setdefault(section, {"brew": [], "cask": []})["brew"].append(
            (short, fmt_brew(full, comment, extra))
        )
    for full, stock_desc, extra in dump["casks"]:
        short = full.split("/")[-1]
        rec = cask_idx.get(short) or cask_idx.get(full)
        # Some casks (e.g. karabiner-elements) are also written as `brew install X`
        # by typo in the source. If we found this short name only as a brew in
        # the index, the section may not have been recorded — fall back to the
        # cask index normally (rec already does this).
        section = (rec and rec["section"]) or DISCOVERED_SECTION
        comment = (rec and rec["comment"]) or stock_desc
        grouped.setdefault(section, {"brew": [], "cask": []})["cask"].append(
            (short, fmt_cask(full, comment, extra))
        )

    # Section emission order: sections in source-script order first, then any
    # extras alphabetically, then the discovered bucket last.
    ordered = [s for s in section_order if s in grouped]
    extras = sorted(
        [s for s in grouped if s not in section_order and s != DISCOVERED_SECTION]
    )
    final_order = ordered + extras
    if DISCOVERED_SECTION in grouped:
        final_order.append(DISCOVERED_SECTION)

    # Sections that have only tombstones (no active dump entries) still need
    # to appear so their tombstones don't get orphaned.
    tomb_sections = set(tomb_buckets["by_section"].keys())
    final_order_with_tombs = list(final_order)
    for s in tomb_sections:
        if s not in final_order_with_tombs:
            final_order_with_tombs.append(s)

    for section in final_order_with_tombs:
        lines.append(f"# {section}")
        # Sort within section by name for stable output.
        active = grouped.get(section, {"brew": [], "cask": []})
        for _name, item in sorted(active["brew"]):
            lines.append(item)
        for _name, item in sorted(active["cask"]):
            lines.append(item)
        # Tombstones for this section, after active entries.
        tombs_here = tomb_buckets["by_section"].get(section, {"brew": [], "cask": []})
        for tomb in sorted(tombs_here["brew"], key=lambda t: t["name"].lower()):
            lines.append(fmt_tombstone(tomb))
        for tomb in sorted(tombs_here["cask"], key=lambda t: t["name"].lower()):
            lines.append(fmt_tombstone(tomb))
        lines.append("")

    # mas
    if dump["mas"] or tomb_buckets["mas"]:
        lines.append("# Mac App Store apps")
        mas_idx = {k[1]: v for k, v in all_idx.items() if k[0] == "mas"}
        for name, idnum, stock_desc in dump["mas"]:
            rec = mas_idx.get(idnum)
            comment = (rec and rec["comment"]) or stock_desc
            lines.append(fmt_mas(name, idnum, comment))
        for tomb in sorted(tomb_buckets["mas"], key=lambda t: t["id"]):
            lines.append(fmt_tombstone(tomb))
        lines.append("")

    # vscode
    if dump["vscode"]:
        lines.append("# VS Code extensions")
        for ext in dump["vscode"]:
            lines.append(f'vscode "{ext}"')
        lines.append("")

    # go
    if dump["go"]:
        lines.append("# Go packages (post-install hooks in brew.sh — `go install …`)")
        for pkg in dump["go"]:
            lines.append(f'go "{pkg}"')
        lines.append("")

    # npm
    if dump["npm"]:
        lines.append("# NPM global packages (installed via `npm install -g`)")
        for pkg in dump["npm"]:
            lines.append(f'npm "{pkg}"')
        lines.append("")

    # uv tools
    if dump["uv"]:
        lines.append("# uv tools (installed via `uv tool install` — Python CLI tools)")
        for pkg in dump["uv"]:
            lines.append(f'uv "{pkg}"')
        lines.append("")

    # cargo crates
    if dump["cargo"]:
        lines.append("# Cargo crates (installed via `cargo install`)")
        for pkg in dump["cargo"]:
            lines.append(f'cargo "{pkg}"')
        lines.append("")

    return "\n".join(lines) + "\n"


# ---------- Build minimum/work from their source scripts ----------

def build_tier_from_script(script_path: Path, header_lines: list[str]) -> str:
    """Emit a Brewfile from a single source script, preserving sections,
    install lines, taps, and mas entries with comments.

    Deduplicates: if a short name appears as both `brew install X` (typo) and
    `brew install --cask X` in the source, keep only the cask form.
    """
    records = parse_script(script_path)

    # First pass: collect cask short-names so we can drop brew formulae that
    # are actually casks-by-typo.
    cask_names = {
        r["name"].split("/")[-1]
        for r in records
        if r["kind"] == "brew" and r["is_cask"]
    }
    # Also dedupe: track names we've already emitted within a kind so we don't
    # print the same `cask "X"` line twice (also a script typo case).
    emitted_brew: set[str] = set()
    emitted_cask: set[str] = set()

    lines: list[str] = list(header_lines)
    lines.append("")

    # Collect taps first.
    taps = [r for r in records if r["kind"] == "tap"]
    seen_taps: set[str] = set()
    if taps:
        lines.append("# Taps")
        for t in taps:
            if t["name"] in seen_taps:
                continue
            seen_taps.add(t["name"])
            lines.append(fmt_tap(t["name"], [], t["comment"]))
        lines.append("")

    current_section_emitted = False
    in_section: str | None = None
    for rec in records:
        if rec["kind"] == "section":
            in_section = rec["title"]
            lines.append("")
            lines.append(f"# {in_section}")
            current_section_emitted = True
            continue
        if rec["kind"] == "tap":
            continue
        # Minimum/work overlays only emit active entries — they're curated
        # manifests, not journals. Tombstones (commented_out records) only
        # belong in the per-day snapshot Brewfile.
        if rec.get("commented_out"):
            continue
        if rec["kind"] == "brew":
            short = rec["name"].split("/")[-1]
            if rec["is_cask"]:
                if short in emitted_cask:
                    continue
                emitted_cask.add(short)
                if not current_section_emitted:
                    lines.append("# Apps")
                    current_section_emitted = True
                lines.append(fmt_cask(rec["name"], rec["comment"]))
            else:
                if short in cask_names:
                    continue  # drop brew "X" if cask "X" also appears
                if short in emitted_brew:
                    continue
                emitted_brew.add(short)
                if not current_section_emitted:
                    lines.append("# Apps")
                    current_section_emitted = True
                lines.append(fmt_brew(rec["name"], rec["comment"]))
        elif rec["kind"] == "mas":
            if not current_section_emitted:
                lines.append("# Mac App Store apps")
                current_section_emitted = True
            display = clean_mas_name(rec["comment"], rec["id"])
            lines.append(fmt_mas(display, rec["id"], rec["comment"]))

    return "\n".join(lines).rstrip() + "\n"


# ---------- main ----------

def main():
    brew_sh = parse_script(HOME / "brew.sh")
    cask_sh = parse_script(HOME / "brew-cask.sh")
    mas_sh = parse_script(MAS_SH)
    min_sh = parse_script(HOME / "brew-cask-minimum.sh")
    work_cask_sh = parse_script(HOME / "brew-cask-work.sh")
    work_sh = parse_script(HOME / "brew-work.sh")

    all_idx: dict = {}
    all_tombstones: list[dict] = []
    section_order: list[str] = []
    # Canonical scripts: contribute both active entries and tombstones.
    # Order matters: brew.sh/brew-cask.sh processed first so their sections
    # take priority in ordering.
    for recs in (brew_sh, cask_sh, mas_sh):
        idx, tombs = index_records(recs, section_order)
        all_idx.update(idx)
        all_tombstones.extend(tombs)
    # Overlay scripts: active entries only — they're not journals.
    for recs in (min_sh, work_cask_sh, work_sh):
        idx, _ = index_records(recs, section_order)
        all_idx.update(idx)

    # brew-cask*.sh writes most lines as `brew install foo` (no --cask flag);
    # the regex correctly marks active entries as is_cask=False, but anyone
    # looking up a cask tombstone (e.g. state-sync) expects to find them as
    # `# cask "foo"`. Override is_cask based on the source file convention.
    for tomb in all_tombstones:
        if tomb["kind"] == "brew" and (tomb.get("source_file") or "").startswith("brew-cask"):
            tomb["is_cask"] = True

    brew_idx = {k[1]: v for k, v in all_idx.items() if k[0] == "brew"}
    cask_idx = {k[1]: v for k, v in all_idx.items() if k[0] == "cask"}

    dump = parse_dump(DUMP)

    out_full = snapshot_path()
    full = build_full(
        brew_idx, cask_idx, all_idx, all_tombstones, dump, section_order, out_full.name
    )
    out_full.write_text(full)

    min_header = [
        "# Brewfile.minimum — essentials for a fresh Mac.",
        "# Mirrors the active entries in setup/homebrew/brew-cask-minimum.sh.",
        "# The source script remains the canonical journal (commented-out entries,",
        "# history, notes); this file is the declarative manifest.",
        "#",
        "# Use:  brew bundle install --file=setup/homebrew/Brewfile.minimum",
    ]
    OUT_MIN.write_text(
        build_tier_from_script(HOME / "brew-cask-minimum.sh", min_header)
    )

    work_header = [
        "# Brewfile.work — work-machine overlay.",
        "# Mirrors active entries in setup/homebrew/brew-cask-work.sh and brew-work.sh.",
        "# These source scripts are older overlays kept for reference; many entries",
        "# may no longer install cleanly. Run `brew bundle check --file=Brewfile.work`",
        "# to see what's missing or stale.",
    ]
    # Combine both work scripts into one Brewfile.
    parts = [
        build_tier_from_script(HOME / "brew-cask-work.sh", work_header).rstrip(),
        "",
        "# --- from brew-work.sh ---",
        build_tier_from_script(HOME / "brew-work.sh", []).rstrip(),
        "",
    ]
    OUT_WORK.write_text("\n".join(parts) + "\n")

    print(f"wrote {out_full} ({out_full.stat().st_size} bytes)")
    print(f"wrote {OUT_MIN} ({OUT_MIN.stat().st_size} bytes)")
    print(f"wrote {OUT_WORK} ({OUT_WORK.stat().st_size} bytes)")
    print(f"note: master at {HOME / 'Brewfile'} is left untouched.")


if __name__ == "__main__":
    main()
