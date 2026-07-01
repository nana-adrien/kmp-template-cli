#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

require_initialized

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

log_info "Récupération de la dernière version de core/ depuis le repo de référence…"
degit_fetch "core" "$TEMP_DIR/core"

log_info "Comparaison avec le core/ local…"
if diff -rq "$TEMP_DIR/core" "core" &>/dev/null; then
    log_success "core/ est déjà à jour. Aucune modification nécessaire."
    exit 0
fi

echo ""
log_warn "Différences détectées :"
diff -rq "$TEMP_DIR/core" "core" || true
echo ""

log_warn "Les fichiers locaux modifiés seront ÉCRASÉS."
confirm "Appliquer la mise à jour de core/ ?" || {
    log_info "Mise à jour annulée."
    exit 0
}

PACKAGE=$(read_gradle_prop "app.package")
PREFIX=$(read_gradle_prop "app.prefix")
source "${SCRIPT_DIR}/lib/rename-utils.sh"

apply_rename "$TEMP_DIR/core" "$PACKAGE" "$PREFIX"

cp -r "$TEMP_DIR/core/." "core/"
log_success "core/ mis à jour avec succès."
log_info "Resynchronise Gradle dans Android Studio."
