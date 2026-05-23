#!/bin/bash

USER="$1"
page=1

while true; do
    repos=$(curl -s \
      -H "User-Agent: Mozilla/5.0" \
      "https://api.github.com/users/$USER/repos?per_page=100&page=$page" \
      | jq -r '.[].clone_url')

    [ -z "$repos" ] && break

    echo "$repos"

    page=$((page + 1))
done | while read -r repo; do
    [ -z "$repo" ] && continue

    echo "[+] Cloning $repo"
    git clone --depth 1 "$repo"

    sleep 1
done