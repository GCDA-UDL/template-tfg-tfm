#!/usr/bin/env bash
# PDF with every change since a git ref (tag, commit or branch) marked by latexdiff:
# added text blue sans-serif, deleted text small red. For "revised manuscript with changes marked".
#
#   bash diff.sh <ref> [doc] [--mode final|changes|review]
#
# Run it from the paper's root folder (a git repository). doc defaults to main.
# The new version is compiled in mode=final by default, so revnotes notes do not show.
# Output: build/diff/<doc>_diff.pdf. Needs latexdiff-so (MiKTeX / TeX Live); plain latexdiff
# may miss a Perl module on Windows.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
[ $# -ge 1 ] || { sed -n '2,11p' "$0"; exit 2; }
ref="$1"; shift
doc=main; mode=final
while [ $# -gt 0 ]; do
  case "$1" in
    --mode) mode="$2"; shift 2 ;;
    *) doc="${1%.tex}"; shift ;;
  esac
done
command -v latexdiff-so >/dev/null || { echo "latexdiff-so not found in PATH"; exit 2; }
git rev-parse --verify -q "$ref^{commit}" >/dev/null || { echo "unknown git ref: $ref"; exit 2; }

old="build/diff/old"
rm -rf "$old"; mkdir -p "$old"
git archive "$ref" | tar -x -C "$old"
[ -f "$old/$doc.tex" ] || { echo "$doc.tex does not exist at $ref"; exit 2; }

# Text arguments of the revnotes commands (\<key>add, \<key>del) are diffed like normal text.
keys=$(grep -ohE '\\revauthor\{[A-Za-z]+\}' "$doc.tex" "$old/$doc.tex" | sed -E 's/.*\{(.*)\}/\1/' | sort -u)
textcmd=""; for k in $keys; do textcmd="$textcmd,${k}add,${k}del"; done

latexdiff-so --flatten --encoding=utf8 --type=CFONT --math-markup=off \
  --exclude-textcmd="section,subsection,subsubsection,paragraph" \
  ${textcmd:+--append-textcmd="${textcmd#,}"} \
  --config="PICTUREENV=(?:picture|DIFnomarkup|algorithmic|algorithm|tabular|tabularx|table|adjustbox)[a-z*]*" \
  "$old/$doc.tex" "$doc.tex" > "build/diff/${doc}_diff.tex" 2> "build/diff/${doc}_latexdiff.err"
[ -s "build/diff/${doc}_diff.tex" ] || { echo "latexdiff failed:"; tail -5 "build/diff/${doc}_latexdiff.err"; exit 1; }

bash "$here/build.sh" "build/diff/${doc}_diff" --out build/diff --mode "$mode"
