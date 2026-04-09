#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: scripts/publish_note.sh /path/to/note.md [YYYY-MM-DD]"
  exit 1
fi

SOURCE_FILE="$1"
POST_DATE="${2:-$(date +%F)}"

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "Source note not found: $SOURCE_FILE"
  exit 1
fi

mkdir -p "_posts"

extract_title() {
  local file="$1"
  local heading

  heading="$(grep -m1 '^# ' "$file" | sed 's/^# //')"
  if [[ -n "$heading" ]]; then
    printf '%s' "$heading"
    return
  fi

  basename "$file" .md | tr '_' ' '
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

TITLE="$(extract_title "$SOURCE_FILE")"
SLUG="$(slugify "$TITLE")"
DEST_FILE="_posts/${POST_DATE}-${SLUG}.md"

if grep -q '^---$' "$SOURCE_FILE"; then
  cp "$SOURCE_FILE" "$DEST_FILE"
else
  cat > "$DEST_FILE" <<EOF
---
layout: post
title: "$TITLE"
date: $POST_DATE
categories: [Research]
tags: []
---

EOF
  cat "$SOURCE_FILE" >> "$DEST_FILE"
fi

echo "Published: $DEST_FILE"
