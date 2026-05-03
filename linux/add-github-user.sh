#!/usr/bin/env bash
set -euo pipefail

# github-keys-to-authorized-keys.sh
# Usage:
#   ./github-keys-to-authorized-keys.sh <github-username> [linux-username]
# If linux-username omitted, the current user is used.
#
# The script:
#  - downloads https://github.com/<github-username>.keys
#  - validates basic key format
#  - avoids adding duplicate keys (by exact key text and by ssh-keygen fingerprint if available)
#  - backups existing authorized_keys
#  - appends new keys and ensures correct permissions

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <github-username> [linux-username]"
  exit 2
fi

GITHUB_USER="$1"
TARGET_USER="${2:-$(id -un)}"

# Safety: require explicit permission reminder
cat <<EOF
WARNING: Only run this script for GitHub users you have explicit permission to trust.
This will add their public keys (from https://github.com/${GITHUB_USER}.keys) to
${TARGET_USER}'s authorized_keys.
EOF

# Determine target user's home directory
if ! user_info=$(getent passwd "${TARGET_USER}"); then
  echo "Error: user '${TARGET_USER}' not found on this system." >&2
  exit 3
fi
TARGET_HOME=$(echo "$user_info" | cut -d: -f6)
if [[ -z "$TARGET_HOME" ]]; then
  echo "Could not determine home directory for ${TARGET_USER}." >&2
  exit 4
fi

SSH_DIR="${TARGET_HOME}/.ssh"
AUTHORIZED_KEYS="${SSH_DIR}/authorized_keys"

# If TARGET_USER is not the current user, require root privileges to modify their files
if [[ "$(id -un)" != "${TARGET_USER}" && "$(id -u)" -ne 0 ]]; then
  echo "Error: to modify ${TARGET_USER}'s authorized_keys you must run this as root." >&2
  exit 5
fi

# Create ssh dir if missing
mkdir -p "$SSH_DIR"
chown "${TARGET_USER}":"$(id -gn "${TARGET_USER}")" "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Backup existing authorized_keys (if present)
timestamp=$(date +%Y%m%dT%H%M%S%z)
if [[ -f "$AUTHORIZED_KEYS" ]]; then
  backup="${AUTHORIZED_KEYS}.bak.${timestamp}"
  cp -a "$AUTHORIZED_KEYS" "$backup"
  chown "${TARGET_USER}":"$(id -gn "${TARGET_USER}")" "$backup"
  echo "Backed up existing authorized_keys to: $backup"
else
  touch "$AUTHORIZED_KEYS"
  chown "${TARGET_USER}":"$(id -gn "${TARGET_USER}")" "$AUTHORIZED_KEYS"
  chmod 600 "$AUTHORIZED_KEYS"
fi

# Temporary files
tmpdir=$(mktemp -d)
keys_file="${tmpdir}/github_keys.txt"
new_keys_file="${tmpdir}/to_add.txt"
touch "$new_keys_file"

cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

# Download public keys from GitHub
github_url="https://github.com/${GITHUB_USER}.keys"
echo "Fetching keys from: $github_url"
if ! curl -fsS --connect-timeout 10 -m 15 -o "$keys_file" "$github_url"; then
  echo "Failed to download keys from ${github_url}. Either user doesn't exist or network error." >&2
  exit 6
fi

if [[ ! -s "$keys_file" ]]; then
  echo "No keys found at ${github_url} (empty response)." >&2
  exit 0
fi

# Basic key format validation regex (covers most common OpenSSH public key types)
# Accepts: ssh-rsa, ssh-ed25519, ecdsa-sha2-nistp256, ecdsa-sha2-nistp384, ecdsa-sha2-nistp521,
#          sk-ecdsa-sha2-nistp256@openssh.com, sk-ssh-ed25519@openssh.com
key_regex='^(ssh-(rsa|ed25519)|ecdsa-sha2-nistp(256|384|521)|sk-ecdsa-sha2-nistp256@openssh\.com|sk-ssh-ed25519@openssh\.com)[[:space:]]+[A-Za-z0-9+/=]+(\s+.*)?$'

# Load existing authorized_keys fingerprints and exact-lines for duplicate checking
declare -A existing_exact
declare -A existing_fprint

# Read existing keys lines and store exact text
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  existing_exact["$line"]=1
done < "$AUTHORIZED_KEYS"

# If ssh-keygen available, compute fingerprints of existing keys
if command -v ssh-keygen >/dev/null 2>&1; then
  while IFS= read -r line; do
    tmpkey="${tmpdir}/k.$$"
    echo "$line" > "$tmpkey"
    if fpr=$(ssh-keygen -lf "$tmpkey" 2>/dev/null || true); then
      # store fpr string as key
      existing_fprint["$fpr"]=1
    fi
    rm -f "$tmpkey"
  done < "$AUTHORIZED_KEYS"
fi

# Iterate downloaded keys: validate, dedupe, and prepare to append
added=0
skipped_invalid=0
skipped_dup=0
total=0

while IFS= read -r kline; do
  total=$((total+1))
  # trim whitespace
  kline="$(echo "$kline" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  [[ -z "$kline" ]] && continue

  if ! [[ "$kline" =~ $key_regex ]]; then
    echo "Skipping invalid / unknown-format key: $kline" >&2
    skipped_invalid=$((skipped_invalid+1))
    continue
  fi

  # exact duplicate check
  if [[ -n "${existing_exact[$kline]:-}" ]]; then
    skipped_dup=$((skipped_dup+1))
    continue
  fi

  # fingerprint duplicate check if possible
  unique_by_fpr=true
  if command -v ssh-keygen >/dev/null 2>&1; then
    tmpkey="${tmpdir}/k.$$"
    echo "$kline" > "$tmpkey"
    if fpr=$(ssh-keygen -lf "$tmpkey" 2>/dev/null || true); then
      if [[ -n "${existing_fprint[$fpr]:-}" ]]; then
        unique_by_fpr=false
      fi
    fi
    rm -f "$tmpkey"
  fi

  if [[ "$unique_by_fpr" == false ]]; then
    skipped_dup=$((skipped_dup+1))
    continue
  fi

  # Append to to_add file
  echo "$kline" >> "$new_keys_file"
done < "$keys_file"

# If there are keys to add, append them to authorized_keys as the correct owner
if [[ -s "$new_keys_file" ]]; then
  if [[ "$(id -un)" == "${TARGET_USER}" ]]; then
    cat "$new_keys_file" >> "$AUTHORIZED_KEYS"
  else
    # append as root but set correct ownership afterwards
    cat "$new_keys_file" >> "$AUTHORIZED_KEYS"
  fi
  # ensure permissions and ownership
  chown "${TARGET_USER}":"$(id -gn "${TARGET_USER}")" "$AUTHORIZED_KEYS"
  chmod 600 "$AUTHORIZED_KEYS"

  # Count how many were added
  added=$(wc -l < "$new_keys_file" | tr -d '[:space:]')
fi

echo
echo "Summary for GitHub user: ${GITHUB_USER} -> linux user: ${TARGET_USER}"
echo "  Total keys offered by GitHub: $total"
echo "  New keys added: $added"
echo "  Duplicate keys skipped: $skipped_dup"
echo "  Invalid-format keys skipped: $skipped_invalid"
if [[ $added -gt 0 ]]; then
  echo "Added keys (appended to ${AUTHORIZED_KEYS}):"
  sed -n '1,100p' "$new_keys_file" | sed -n '1,10p'  # show up to first 10 for brevity
fi
echo
echo "Done. Backup (if existed) is at: ${backup:-<none>}"

