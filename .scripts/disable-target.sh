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
    ios)     PROP="kmp.target.ios" ;;
    desktop) PROP="kmp.target.desktop" ;;
    web)     PROP="kmp.target.web" ;;
    android) PROP="kmp.target.android" ;;
esac

current_flag=$(read_gradle_prop "$PROP")

if [[ "$current_flag" == "false" ]]; then
    log_info "La cible ${TARGET} est déjà désactivée."
    exit 0
fi

# ── Vérification des dépendances croisées ────────────────────────────────────
push_type=$(read_gradle_prop "push.type")

if [[ "$push_type" == "firebase" && "$TARGET" == "android" ]]; then
    log_warn "Firebase est configuré pour Android+iOS."
    log_warn "Désactiver Android ne supprime pas la config Firebase existante."
    confirm "Continuer quand même ?" || exit 0
fi

if [[ "$push_type" == "firebase" && "$TARGET" == "ios" ]]; then
    log_warn "Firebase est configuré pour Android+iOS."
    log_warn "Désactiver iOS ne supprime pas la config Firebase existante."
    confirm "Continuer quand même ?" || exit 0
fi

# ── Toggle réversible : désactive le flag, conserve le code ──────────────────
write_gradle_prop "$PROP" "false"

log_success "Cible ${TARGET} désactivée (code conservé sur le disque)."
log_info "Pour la réactiver : ./gradlew enableTarget$(echo "${TARGET^}")"
log_info "Pour la supprimer définitivement : ./gradlew removeTarget$(echo "${TARGET^}")"
log_info "Resynchronise Gradle dans Android Studio."
