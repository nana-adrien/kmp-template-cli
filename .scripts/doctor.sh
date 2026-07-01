#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

ERRORS=0
WARNINGS=0

check_fail()  { log_error "  ✗ $*"; ERRORS=$((ERRORS + 1)); }
check_warn()  { log_warn  "  ⚠ $*"; WARNINGS=$((WARNINGS + 1)); }
check_ok()    { log_success "  ✓ $*"; }

echo ""
log_info "════════════════════════════════════════════════════"
log_info "  Diagnostic du projet kmp-template"
log_info "════════════════════════════════════════════════════"
echo ""

# ── Vérification .template-initialized ────────────────────────────────────────
if [[ -f ".template-initialized" ]]; then
    init_date=$(grep "initialized_at" .template-initialized | cut -d'=' -f2)
    check_ok ".template-initialized présent (initialisé le ${init_date})"
else
    check_fail ".template-initialized absent — projet non initialisé (lance ./gradlew applyConfig)"
fi

# ── Vérification gradle.properties ───────────────────────────────────────────
echo ""
log_info "Vérification des propriétés…"

app_name=$(read_gradle_prop "app.name")
app_package=$(read_gradle_prop "app.package")
app_prefix=$(read_gradle_prop "app.prefix")

[[ -n "$app_name" ]]    && check_ok "app.name = ${app_name}"    || check_fail "app.name non défini dans gradle.properties"
[[ -n "$app_package" ]] && check_ok "app.package = ${app_package}" || check_fail "app.package non défini dans gradle.properties"
[[ -n "$app_prefix" ]]  && check_ok "app.prefix = ${app_prefix}"  || check_fail "app.prefix non défini dans gradle.properties"

# ── Vérification des cibles ───────────────────────────────────────────────────
echo ""
log_info "Vérification des cibles…"

declare -A TARGET_DIRS
TARGET_DIRS["kmp.target.android"]="composeApp/src/androidMain"
TARGET_DIRS["kmp.target.ios"]="composeApp/src/iosMain iosApp"
TARGET_DIRS["kmp.target.desktop"]="composeApp/src/jvmMain"
TARGET_DIRS["kmp.target.web"]="composeApp/src/wasmJsMain"

for prop in "kmp.target.android" "kmp.target.ios" "kmp.target.desktop" "kmp.target.web"; do
    flag=$(read_gradle_prop "$prop")
    if [[ "$flag" == "true" ]]; then
        all_present=true
        for dir in ${TARGET_DIRS[$prop]}; do
            if [[ ! -d "$dir" ]]; then
                all_present=false
                check_fail "${prop}=true mais dossier absent : ${dir}"
            fi
        done
        $all_present && check_ok "${prop}=true et dossiers présents"
    else
        check_ok "${prop}=${flag:-non défini} (cible inactive)"
    fi
done

# ── Vérification Mapbox ───────────────────────────────────────────────────────
echo ""
maps_enabled=$(read_gradle_prop "maps.enabled")
if [[ "$maps_enabled" == "true" ]]; then
    log_info "Vérification Mapbox…"
    [[ -d "feature/geo" ]]       && check_ok "feature/geo présent"           || check_fail "maps.enabled=true mais feature/geo absent"
    [[ -f "local.properties" ]]  && grep -q "^MAPBOX_ACCESS_TOKEN=" "local.properties" \
        && check_ok "MAPBOX_ACCESS_TOKEN dans local.properties" \
        || check_fail "MAPBOX_ACCESS_TOKEN absent de local.properties"
    grep -qxF "local.properties" ".gitignore" 2>/dev/null \
        && check_ok "local.properties gitignored" \
        || check_warn "local.properties n'est pas dans .gitignore — risque d'exposition du token !"
fi

# ── Vérification credentials ──────────────────────────────────────────────────
backend=$(read_gradle_prop "backend.type")
echo ""
log_info "Backend : ${backend:-non défini}"
if [[ "$backend" == "ktor-server" ]]; then
    grep -qxF "gradle.properties" ".gitignore" 2>/dev/null \
        && check_ok "gradle.properties gitignored (credentials DB)" \
        || check_warn "gradle.properties contient des credentials mais n'est pas gitignored !"
fi
if [[ "$backend" == "supabase" ]]; then
    [[ -f "local.properties" ]] && grep -q "^SUPABASE_URL=" "local.properties" \
        && check_ok "SUPABASE_URL dans local.properties" \
        || check_warn "SUPABASE_URL absent de local.properties"
    grep -qxF "local.properties" ".gitignore" 2>/dev/null \
        && check_ok "local.properties gitignored" \
        || check_fail "local.properties contient des credentials Supabase mais n'est pas gitignored !"
fi

# ── Résumé ────────────────────────────────────────────────────────────────────
echo ""
log_info "════════════════════════════════════════════════════"
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    log_success "  ✅ Tout est cohérent."
elif [[ $ERRORS -eq 0 ]]; then
    log_warn "  ⚠ ${WARNINGS} avertissement(s) — vérifiez les points ci-dessus."
else
    log_error "  ✗ ${ERRORS} erreur(s) et ${WARNINGS} avertissement(s)."
    exit 1
fi
log_info "════════════════════════════════════════════════════"
