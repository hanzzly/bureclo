#!/bin/bash

USER="$1"
page=1

repos_file=$(mktemp)

while true; do
    repos=$(curl -s \
      -H "User-Agent: Mozilla/5.0" \
      "https://api.github.com/users/$USER/repos?per_page=100&page=$page" \
      | jq -r '.[].clone_url')

    [ -z "$repos" ] && break

    echo "$repos" >> "$repos_file"

    page=$((page + 1))
done

success=0
failed=0

while read -r repo; do
    [ -z "$repo" ] && continue

    echo "[+] Cloning $repo"

    if git clone --depth 1 "$repo"; then
        echo "[OK] Success"
        success=$((success + 1))
    else
        echo "[FAIL] Failed"
        failed=$((failed + 1))
    fi

    sleep 1
done < "$repos_file"

rm -f "$repos_file"

echo
echo "========== RESULT =========="
echo "[+] Success : $success"
echo "[-] Failed  : $failed"
