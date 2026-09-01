#!/bin/sh

current=$(pactl get-default-sink) || exit 1
sinks=$(pactl list short sinks | cut -f2 | awk '!seen[$0]++')
[ -n "$sinks" ] || exit 0

next=$(printf '%s\n' "$sinks" | awk -v current="$current" '
  NR == 1 { first = $0 }
  previous == current { print; found = 1; exit }
  { previous = $0 }
  END { if (!found) print first }
')

pactl set-default-sink "$next" || exit 1
pactl list short sink-inputs | cut -f1 | while IFS= read -r input; do
  pactl move-sink-input "$input" "$next"
done
