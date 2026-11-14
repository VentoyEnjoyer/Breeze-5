#!/usr/bin/env bash
set -euo pipefail
ENGINE="${1:-./Breeze5}"
OUTPUT="$({
  printf 'uci\n'
  printf 'isready\n'
  printf 'setoption name Hash value 16\n'
  printf 'position startpos\n'
  printf 'go searchmoves e2e4 d2d4 depth 3\n'
  sleep 1
  printf 'quit\n'
} | "$ENGINE")"

printf '%s\n' "$OUTPUT"
grep -q '^uciok$' <<< "$OUTPUT"
grep -q '^readyok$' <<< "$OUTPUT"
grep -Eq '^bestmove (e2e4|d2d4)( |$)' <<< "$OUTPUT"
if grep -q 'a1a1' <<< "$OUTPUT"; then
  echo "Invalid null move appeared in principal variation" >&2
  exit 1
fi
