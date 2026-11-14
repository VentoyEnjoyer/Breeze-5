#!/usr/bin/env bash
set -euo pipefail
ENGINE="${1:-./Breeze5}"
NETWORK="${2:-${NETWORK:-}}"
if [[ -z "$NETWORK" ]]; then
  echo "Usage: $0 ./Breeze5 /path/to/nn-68752b755c93.nnue" >&2
  exit 2
fi
if [[ ! -f "$NETWORK" ]]; then
  echo "Network file not found: $NETWORK" >&2
  exit 2
fi
OUT="$({
  printf 'uci\n'
  printf 'setoption name EvalFile value \"%s\"\n' "$NETWORK"
  printf 'isready\nposition startpos\neval\ngo depth 3\n'
  sleep 2
  printf 'quit\n'
} | "$ENGINE")"
printf '%s\n' "$OUT"
grep -q 'SFNNv20 network loaded successfully' <<<"$OUT"
grep -q 'evaluation mode: SFNNv20' <<<"$OUT"
grep -q 'Breeze SFNNv20 evaluation:' <<<"$OUT"
grep -q '^bestmove ' <<<"$OUT"
echo 'SFNNv20 UCI smoke test passed.'
