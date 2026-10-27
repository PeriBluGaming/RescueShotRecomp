
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

apply_patch() {
    local name="$1"
    local repo="$2"
    local patch="$3"

    echo "==> Prüfe $name"

    if [[ ! -d "$repo" ]]; then
        echo "FEHLER: $name fehlt."
        exit 1
    fi

    if git -C "$repo" apply --check "$patch" 2>/dev/null; then
        git -C "$repo" apply "$patch"
        echo "    Patch erfolgreich angewendet."

    elif git -C "$repo" apply --check --reverse "$patch" 2>/dev/null; then
        echo "    Patch bereits vorhanden."

    else
        echo "FEHLER: Patch für $name ist inkompatibel."
        echo "Prüfe die Submodul-Version und lokale Änderungen."
        exit 1
    fi
}

apply_patch \
    "PSXRecomp" \
    "$ROOT_DIR/psxrecomp" \
    "$ROOT_DIR/patches/psxrecomp/0001-native-ps-mouse.patch"

apply_patch \
    "recomp-ui" \
    "$ROOT_DIR/recomp-ui" \
    "$ROOT_DIR/patches/recomp-ui/0001-ps-mouse-launcher.patch"

echo
echo "Alle Framework-Patches sind vorhanden."

