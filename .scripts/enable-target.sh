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

# Vérifie que le code est présent sur le disque
all_exist=true
for d in "${DIRS[@]}"; do
    if [[ ! -d "$d" ]]; then
        all_exist=false
        break
    fi
done

if ! $all_exist; then
    log_warn "Le code de la cible ${TARGET} n'est pas présent sur le disque."
    log_info "Utilisez plutôt : ./gradlew addTarget$(echo "${TARGET^}")"
    "${SCRIPT_DIR}/add-target.sh" "$TARGET"
    exit 0
fi

current_flag=$(read_gradle_prop "$PROP")

if [[ "$current_flag" == "true" ]]; then
    log_info "La cible ${TARGET} est déjà active."
    exit 0
fi

write_gradle_prop "$PROP" "true"
log_success "Cible ${TARGET} réactivée."
log_info "Resynchronise Gradle dans Android Studio (File → Sync Project with Gradle Files)."
