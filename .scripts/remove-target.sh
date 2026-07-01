#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

TARGET="${1:-}"

if [[ -z "$TARGET" ]]; then
    echo "Usage: $0 <ios|desktop|web|android>"
    exit 1
fi

case "$TARGET" in
    ios|desktop|web|android) ;;
    *) log_error "Cible invalide : ${TARGET}. Valeurs acceptées : ios, desktop, web, android"; exit 1 ;;
esac

require_initialized

case "$TARGET" in
    ios)
        PROP="kmp.target.ios"
        DIRS=("composeApp/src/iosMain" "iosApp")
        ;;
    desktop)
        PROP="kmp.target.desktop"
        DIRS=("composeApp/src/jvmMain")
        ;;
    web)
        PROP="kmp.target.web"
        DIRS=("composeApp/src/wasmJsMain")
        ;;
    android)
        PROP="kmp.target.android"
        DIRS=("composeApp/src/androidMain")
        ;;
esac

# ── Avertissement ─────────────────────────────────────────────────────────────
echo ""
log_warn "══════════════════════════════════════════════════════"
log_warn "  SUPPRESSION DÉFINITIVE ET IRRÉVERSIBLE"
log_warn "  Cible  : ${TARGET}"
log_warn "  Dossiers qui seront supprimés :"
for d in "${DIRS[@]}"; do
    log_warn "    - ${d}"
done
log_warn "══════════════════════════════════════════════════════"
echo ""
echo -e "${_YELLOW}Tape le nom de la cible (${TARGET}) pour confirmer : ${_NC}\c" 2>/dev/null || \
    printf "Tape le nom de la cible (%s) pour confirmer : " "$TARGET"
read -r confirmation

if [[ "$confirmation" != "$TARGET" ]]; then
    log_info "Suppression annulée."
    exit 0
fi

# ── Suppression ───────────────────────────────────────────────────────────────
for d in "${DIRS[@]}"; do
    if [[ -d "$d" ]]; then
        rm -rf "$d"
        log_success "Supprimé : ${d}"
    fi
done

# ── Mise à jour gradle.properties ────────────────────────────────────────────
write_gradle_prop "$PROP" "false"

log_success "Cible ${TARGET} supprimée définitivement."
log_info "Resynchronise Gradle dans Android Studio."
log_info "Pour l'ajouter à nouveau : ./gradlew addTarget$(echo "${TARGET^}")"
