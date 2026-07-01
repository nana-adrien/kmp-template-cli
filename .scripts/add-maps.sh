#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/rename-utils.sh"

# ── Usage ─────────────────────────────────────────────────────────────────────
MAPBOX_TOKEN=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --token) MAPBOX_TOKEN="$2"; shift 2 ;;
        *) log_error "Argument inconnu : $1"; echo "Usage: $0 --token <pk.eyJ...>"; exit 1 ;;
    esac
done

if [[ -z "$MAPBOX_TOKEN" ]]; then
    echo "Usage: $0 --token <pk.eyJ...>"
    exit 1
fi

require_initialized

# ── Validations ───────────────────────────────────────────────────────────────
if [[ ! "$MAPBOX_TOKEN" == pk.eyJ* ]]; then
    log_error "Token Mapbox invalide. Doit commencer par pk.eyJ"
    exit 1
fi

android_enabled=$(read_gradle_prop "kmp.target.android")
if [[ "$android_enabled" != "true" ]]; then
    log_error "La cible Android doit être active pour utiliser Mapbox."
    log_error "Activez-la d'abord : ./gradlew addTargetAndroid"
    exit 1
fi

if [[ -d "feature/geo" ]]; then
    log_info "Le module feature/geo existe déjà. Rien à télécharger."
else
    # ── Téléchargement ──────────────────────────────────────────────────────────
    log_info "Téléchargement du module Mapbox (feature/geo)…"
    degit_fetch "feature/geo" "feature/geo"

    PACKAGE=$(read_gradle_prop "app.package")
    PREFIX=$(read_gradle_prop "app.prefix")
    apply_rename "feature/geo" "$PACKAGE" "$PREFIX"
fi

# ── Credentials ───────────────────────────────────────────────────────────────
ensure_gitignored "local.properties"
if ! grep -q "^MAPBOX_ACCESS_TOKEN=" "local.properties" 2>/dev/null; then
    echo "MAPBOX_ACCESS_TOKEN=${MAPBOX_TOKEN}" >> "local.properties"
    log_success "MAPBOX_ACCESS_TOKEN écrit dans local.properties"
fi

# ── Dépendance Mapbox dans libs.versions.toml ─────────────────────────────────
TOML_FILE="gradle/libs.versions.toml"
if [[ -f "$TOML_FILE" ]] && ! grep -q "mapbox" "$TOML_FILE" 2>/dev/null; then
    log_info "Ajout de la dépendance Mapbox dans libs.versions.toml…"
    # Ajoute la version après la section [versions]
    sed -i.bak '/^\[versions\]/a mapbox = "11.9.0"' "$TOML_FILE"
    # Ajoute la dépendance après la section [libraries]
    sed -i.bak '/^\[libraries\]/a mapbox-maps = { module = "com.mapbox.maps:android", version.ref = "mapbox" }' "$TOML_FILE"
    rm -f "${TOML_FILE}.bak"
fi

write_gradle_prop "maps.enabled" "true"

log_success "Module Mapbox ajouté avec succès."
log_info "Version Mapbox : 11.9.0 — vérifie https://docs.mapbox.com/android/maps/changelog/"
ios_enabled=$(read_gradle_prop "kmp.target.ios")
if [[ "$ios_enabled" == "true" ]]; then
    log_warn "Pour iOS : ajoute le Mapbox Maps SDK dans ton Podfile ou via Swift Package Manager."
    log_warn "Documentation : https://docs.mapbox.com/ios/maps/guides/install/"
fi
log_info "Resynchronise Gradle dans Android Studio."
