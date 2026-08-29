#!/usr/bin/env bash

set -u

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source_dir="$repo_dir/.config"
target_dir="$HOME/.config"
status=0
created_dirs=()
replaced_dirs=()
created_paths=()
replaced_paths=()
skipped_dirs=()

is_under_skipped_directory() {
  local path=$1
  local skipped

  for skipped in "${skipped_dirs[@]}"; do
    if [[ "$path" == "$skipped" || "$path" == "$skipped/"* ]]; then
      return 0
    fi
  done

  return 1
}

if [[ ! -d "$source_dir" ]]; then
  printf 'Source directory does not exist: %s\n' "$source_dir" >&2
  exit 1
fi

mkdir -p -- "$target_dir"

if [[ "$source_dir" -ef "$target_dir" ]]; then
  printf 'Source and target directories resolve to the same location: %s\n' "$source_dir" >&2
  exit 1
fi

while IFS= read -r -d '' source_directory <&3; do
  relative_path=${source_directory#"$source_dir/"}
  target_directory="$target_dir/$relative_path"

  if is_under_skipped_directory "$target_directory"; then
    continue
  fi

  if [[ -L "$target_directory" ]]; then
    printf 'Replace directory symlink with a real directory: %s? [y/N] ' "$target_directory" >&2
    if ! IFS= read -r reply || [[ ! "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]; then
      printf 'Not replaced: %s\n' "$target_directory" >&2
      skipped_dirs+=("$target_directory")
      continue
    fi

    if ! rm -f -- "$target_directory" || ! mkdir -p -- "$target_directory"; then
      status=1
      skipped_dirs+=("$target_directory")
      continue
    fi

    replaced_dirs+=("~/.config/$relative_path")
  elif [[ -e "$target_directory" && ! -d "$target_directory" ]]; then
    printf 'Conflict is not a directory: %s\n' "$target_directory" >&2
    status=1
    skipped_dirs+=("$target_directory")
  elif [[ ! -d "$target_directory" ]]; then
    if mkdir -p -- "$target_directory"; then
      created_dirs+=("~/.config/$relative_path")
    else
      status=1
      skipped_dirs+=("$target_directory")
    fi
  fi
done 3< <(find "$source_dir" -mindepth 1 -type d -print0)

while IFS= read -r -d '' source <&3; do
  relative_path=${source#"$source_dir/"}
  target="$target_dir/$relative_path"
  replacing=0

  if is_under_skipped_directory "$target"; then
    continue
  fi

  if [[ -L "$source" && -d "$source" ]]; then
    printf 'Source is a directory symlink, not linked: %s\n' "$source" >&2
    status=1
    continue
  fi

  if ! mkdir -p -- "$(dirname -- "$target")"; then
    status=1
    continue
  fi

  if [[ -e "$target" && "$source" -ef "$target" ]]; then
    continue
  fi

  if [[ -L "$target" && $(realpath -m -- "$target") == $(realpath -m -- "$source") ]]; then
    continue
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -d "$target" && ! -L "$target" ]]; then
      printf 'Conflict is a directory, not replaced: %s\n' "$target" >&2
      status=1
      continue
    fi

    printf 'Overwrite %s? [y/N] ' "$target" >&2
    if ! IFS= read -r reply || [[ ! "$reply" =~ ^[Yy]([Ee][Ss])?$ ]]; then
      printf 'Not replaced: %s\n' "$target" >&2
      continue
    fi

    if ! rm -f -- "$target"; then
      status=1
      continue
    fi

    replacing=1
  fi

  if ln -s -- "$source" "$target"; then
    if ((replacing)); then
      replaced_paths+=("~/.config/$relative_path")
    else
      created_paths+=("~/.config/$relative_path")
    fi
  else
    status=1
  fi
done 3< <(find "$source_dir" \( -type f -o -type l \) -print0)

printf '\nRun report:\n'
if ((${#created_dirs[@]} == 0 && ${#replaced_dirs[@]} == 0 && ${#created_paths[@]} == 0 && ${#replaced_paths[@]} == 0)); then
  printf '  No changes.\n'
fi

if ((${#created_dirs[@]} > 0)); then
  printf 'Created directories:\n'
  printf '  %s\n' "${created_dirs[@]}"
fi

if ((${#replaced_dirs[@]} > 0)); then
  printf 'Replaced directory symlinks:\n'
  printf '  %s\n' "${replaced_dirs[@]}"
fi

if ((${#created_paths[@]} > 0)); then
  printf 'Created links:\n'
  printf '  %s\n' "${created_paths[@]}"
fi

if ((${#replaced_paths[@]} > 0)); then
  printf 'Replaced files with links:\n'
  printf '  %s\n' "${replaced_paths[@]}"
fi

exit "$status"
