#!/bin/sh

current=$(pactl get-default-source) || exit 1
sources=$(pactl list short sources | awk -F '\t' '$2 !~ /\.monitor$/ && !seen[$2]++ { print $2 }')
[ -n "$sources" ] || exit 0

next=$(printf '%s\n' "$sources" | awk -v current="$current" '
  NR == 1 { first = $0 }
  previous == current { print; found = 1; exit }
  { previous = $0 }
  END { if (!found) print first }
')

pactl set-default-source "$next" || exit 1
pactl list short source-outputs | cut -f1 | while IFS= read -r output; do
  pactl move-source-output "$output" "$next"
done
