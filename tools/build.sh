#!/usr/bin/env bash
# Compile a LaTeX paper locally into build/ without touching tracked files, then print a summary:
# errors, undefined references and citations, overfull boxes, pages and the revnotes counts.
#
#   bash build.sh [doc] [--mode review|changes|final] [--engine pdflatex|xelatex|lualatex]
#                 [--out DIR] [--open]
#
# Run it from the paper's root folder. doc defaults to main (main.tex); it may include a folder.
# --mode  overrides the revnotes mode written in the preamble, for this build only.
# --out   output folder; default build/ (or build/<mode> when --mode is given).
# --open  opens the PDF afterwards.
# Exit code: 0 when the last pass has no errors, 1 otherwise, 2 on bad usage.
set -u
src=main; mode=""; engine=""; out=""; open=0
while [ $# -gt 0 ]; do
  case "$1" in
    --mode)   mode="$2"; shift 2 ;;
    --engine) engine="$2"; shift 2 ;;
    --out)    out="$2"; shift 2 ;;
    --open)   open=1; shift ;;
    -h|--help) sed -n '2,13p' "$0"; exit 0 ;;
    -*) echo "unknown option $1"; exit 2 ;;
    *)  src="${1%.tex}"; shift ;;
  esac
done
[ -f "$src.tex" ] || { echo "no $src.tex in $(pwd)"; exit 2; }
job="$(basename "$src")"
[ -n "$out" ] || { if [ -n "$mode" ]; then out="build/$mode"; else out="build"; fi; }

# Engine: --engine, else the "% !TEX program = ..." magic comment, else pdflatex.
if [ -z "$engine" ]; then
  engine=$(grep -m1 -oiE '^%[[:space:]]*!TEX[[:space:]]+(TS-)?program[[:space:]]*=[[:space:]]*[a-z]+' "$src.tex" \
           | sed -E 's/.*=[[:space:]]*//' | tr 'A-Z' 'a-z')
  [ -n "$engine" ] || engine=pdflatex
fi
command -v "$engine" >/dev/null || { echo "$engine not found in PATH"; exit 2; }

# \include writes one .aux per included file: mirror the source folders inside $out.
mkdir -p "$out"
find . \( -name .git -o -name build -o -name node_modules \) -prune -o -type d -print |
  while IFS= read -r d; do mkdir -p "$out/$d"; done

if [ -n "$mode" ]; then texin="\\def\\revnotesforcemode{$mode}\\input{$src}"; else texin="$src.tex"; fi
run_tex() {
  "$engine" -interaction=nonstopmode -output-directory="$out" -jobname="$job" "$texin" \
    > "$out/${job}_tex.out" 2>&1
}
# bibtex runs inside $out, so .bib/.bst files are copied there at the same relative paths
# (latexmk -outdir loses the bibliography for the same reason).
run_bib() {
  if [ -f "$out/$job.bcf" ]; then
    biber --output-directory="$out" "$job" > "$out/${job}_bib.out" 2>&1
  elif grep -q '\\bibdata' "$out/$job.aux" 2>/dev/null; then
    find . \( -name .git -o -name build \) -prune -o \( -name '*.bib' -o -name '*.bst' \) -type f -print |
      while IFS= read -r f; do cp -f "$f" "$out/$f"; done
    ( cd "$out" && bibtex "$job" > "${job}_bib.out" 2>&1 )
  fi
}

run_tex; run_bib; run_tex; run_tex
log="$out/$job.log"
for _ in 1 2; do grep -q 'Rerun to get' "$log" 2>/dev/null && run_tex; done
[ -f "$log" ] || { echo "no log produced; see $out/${job}_tex.out"; exit 1; }

errs=$(grep -c '^!' "$log")
refs=$(grep -c 'LaTeX Warning: Reference' "$log")
cites=$(grep -c 'Warning: Citation' "$log")
overfull=$(grep -c '^Overfull' "$log")
worst=$(grep -oE '^Overfull \\[hv]box \([0-9.]+pt' "$log" | grep -oE '[0-9.]+' | sort -rn | head -1)
pages=$(grep -A4 'Output written on' "$log" | tr -d '\r\n' | grep -oE '\([0-9]+ ?p ?a ?g ?e' | grep -oE '^\([0-9]+' | tr -d '(')
bibw=0; [ -f "$out/$job.blg" ] && bibw=$(grep -c 'Warning' "$out/$job.blg")

echo "pdf:              $out/$job.pdf ($engine${mode:+, mode=$mode})"
echo "pages:            ${pages:-? (no PDF written)}"
echo "errors:           $errs"
echo "undefined refs:   $refs"
echo "undefined cites:  $cites"
echo "bib warnings:     $bibw"
echo "overfull boxes:   $overfull${worst:+ (worst ${worst}pt)}"
grep -m1 '^revnotes: ' "$log" || echo "revnotes:         not loaded"
if [ "$errs" -gt 0 ]; then echo "--- first errors ---"; grep -n '^!' -A3 "$log" | head -24; fi

if [ "$open" = 1 ] && [ -f "$out/$job.pdf" ]; then
  if command -v cygpath >/dev/null; then cmd.exe //c start "" "$(cygpath -w "$out/$job.pdf")"
  elif [ "$(uname)" = Darwin ]; then open "$out/$job.pdf"
  else xdg-open "$out/$job.pdf" >/dev/null 2>&1 &
  fi
fi
[ "$errs" -eq 0 ]
