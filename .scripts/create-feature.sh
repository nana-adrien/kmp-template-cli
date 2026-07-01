#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

FEATURE_NAME="${1:-}"

if [[ -z "$FEATURE_NAME" ]]; then
    echo "Usage: $0 <nom_feature>"
    echo "  Ex : $0 commandes"
    echo "  Le nom doit être en minuscules (underscores autorisés)."
    exit 1
fi

require_initialized

# ── Dérivation des noms ───────────────────────────────────────────────────────
# commandes → Commandes (PascalCase)
FEATURE_PASCAL="$(echo "$FEATURE_NAME" | sed -E 's/(^|_)([a-z])/\U\2/g')"
PACKAGE=$(read_gradle_prop "app.package")
PREFIX=$(read_gradle_prop "app.prefix")
FEATURE_DIR="feature/${FEATURE_NAME}"
TEMPLATES_DIR="${SCRIPT_DIR}/templates/feature"

if [[ -d "$FEATURE_DIR" ]]; then
    log_error "Le module feature/${FEATURE_NAME} existe déjà."
    exit 1
fi

log_info "Création de la feature : ${FEATURE_NAME} (${FEATURE_PASCAL})"

# ── Copie des templates ───────────────────────────────────────────────────────
cp -r "$TEMPLATES_DIR" "$FEATURE_DIR"

# ── Remplacement des placeholders ────────────────────────────────────────────
# Placeholders : FeatureName → ${FEATURE_PASCAL}, __PACKAGE__ → ${PACKAGE}
find "$FEATURE_DIR" -type f | while IFS= read -r file; do
    sed -i.bak \
        -e "s|FeatureName|${FEATURE_PASCAL}|g" \
        -e "s|featurename|${FEATURE_NAME}|g" \
        -e "s|__PACKAGE__|${PACKAGE}|g" \
        -e "s|__PREFIX__|${PREFIX}|g" \
        "$file"
    rm -f "${file}.bak"
done

# ── Renommage des fichiers ────────────────────────────────────────────────────
find "$FEATURE_DIR" -type f -name "*FeatureName*" | sort -r | while IFS= read -r old_file; do
    new_file="${old_file//FeatureName/${FEATURE_PASCAL}}"
    mv "$old_file" "$new_file"
done

log_success "Feature '${FEATURE_NAME}' créée dans ${FEATURE_DIR}/"
echo ""
log_info "Prochaines étapes :"
log_info "  1. Déclarer le module dans settings.gradle.kts :"
log_info "       include(\":feature:${FEATURE_NAME}:domain\")"
log_info "       include(\":feature:${FEATURE_NAME}:data\")"
log_info "       include(\":feature:${FEATURE_NAME}:presentation\")"
log_info "       include(\":feature:${FEATURE_NAME}:config\")"
log_info "  2. Enregistrer le module Koin dans composeApp/di/koinConfig.kt"
log_info "  3. Ajouter les routes dans le NavGraph approprié"
