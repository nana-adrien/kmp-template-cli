#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/rename-utils.sh"

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

# ── Correspondance cible → dossiers et flag gradle ───────────────────────────
case "$TARGET" in
    ios)
        DIRS=("composeApp/src/iosMain" "iosApp")
        PROP="kmp.target.ios"
        ;;
    desktop)
        DIRS=("composeApp/src/jvmMain")
        PROP="kmp.target.desktop"
        ;;
    web)
        DIRS=("composeApp/src/wasmJsMain")
        PROP="kmp.target.web"
        ;;
    android)
        DIRS=("composeApp/src/androidMain")
        PROP="kmp.target.android"
        ;;
esac

current_flag=$(read_gradle_prop "$PROP")

# ── Cas 1 : dossier présent + flag false → réactiver uniquement ──────────────
all_exist=true
for d in "${DIRS[@]}"; do
    [[ ! -d "$d" ]] && all_exist=false && break
done

if $all_exist && [[ "$current_flag" == "false" ]]; then
    log_info "Cible ${TARGET} présente sur le disque mais désactivée. Réactivation du flag."
    write_gradle_prop "$PROP" "true"
    log_success "Cible ${TARGET} réactivée. Resynchronise Gradle dans Android Studio."
    exit 0
fi

# ── Cas 2 : dossier présent + flag true → déjà active ───────────────────────
if $all_exist && [[ "$current_flag" == "true" ]]; then
    log_info "La cible ${TARGET} est déjà active. Rien à faire."
    exit 0
fi

# ── Cas 3 : dossier absent → télécharger depuis le repo de référence ─────────
log_info "Ajout de la cible ${TARGET}…"

PACKAGE=$(read_gradle_prop "app.package")
PREFIX=$(read_gradle_prop "app.prefix")

case "$TARGET" in
    ios)
        degit_fetch "composeApp/src/iosMain" "composeApp/src/iosMain"
        degit_fetch "iosApp" "iosApp"
        apply_rename "composeApp/src/iosMain" "$PACKAGE" "$PREFIX"
        apply_rename "iosApp" "$PACKAGE" "$PREFIX"
        ;;
    desktop)
        degit_fetch "composeApp/src/jvmMain" "composeApp/src/jvmMain"
        apply_rename "composeApp/src/jvmMain" "$PACKAGE" "$PREFIX"
        ;;
    web)
        degit_fetch "composeApp/src/wasmJsMain" "composeApp/src/wasmJsMain"
        apply_rename "composeApp/src/wasmJsMain" "$PACKAGE" "$PREFIX"
        ;;
    android)
        degit_fetch "composeApp/src/androidMain" "composeApp/src/androidMain"
        apply_rename "composeApp/src/androidMain" "$PACKAGE" "$PREFIX"
        ;;
esac

write_gradle_prop "$PROP" "true"

log_success "Cible ${TARGET} ajoutée avec succès."
log_info "Resynchronise Gradle dans Android Studio (File → Sync Project with Gradle Files)."
