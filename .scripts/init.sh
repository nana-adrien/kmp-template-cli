#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/rename-utils.sh"

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
    echo "Usage: $0 --app-name <name> --package <pkg> --prefix <prefix>"
    echo "       --android <true|false> --ios <true|false>"
    echo "       --desktop <true|false> --web <true|false>"
    echo "       --backend <ktor|ktor-server|supabase>"
    echo "       [--db-url <url>] [--db-user <user>] [--db-password <pwd>] [--jwt-secret <secret>]"
    echo "       [--supabase-url <url>] [--supabase-key <key>]"
    echo "       --push <firebase|apns|none>"
    echo "       [--mapbox-token <token>]"
    exit 1
}

# ── Parse arguments ───────────────────────────────────────────────────────────
APP_NAME="" PACKAGE="" PREFIX="" BACKEND="" PUSH=""
TARGET_ANDROID="true" TARGET_IOS="true" TARGET_DESKTOP="false" TARGET_WEB="false"
DB_URL="" DB_USER="" DB_PASSWORD="" JWT_SECRET=""
SUPABASE_URL="" SUPABASE_KEY=""
MAPBOX_TOKEN=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --app-name)     APP_NAME="$2";     shift 2 ;;
        --package)      PACKAGE="$2";      shift 2 ;;
        --prefix)       PREFIX="$2";       shift 2 ;;
        --android)      TARGET_ANDROID="$2"; shift 2 ;;
        --ios)          TARGET_IOS="$2";   shift 2 ;;
        --desktop)      TARGET_DESKTOP="$2"; shift 2 ;;
        --web)          TARGET_WEB="$2";   shift 2 ;;
        --backend)      BACKEND="$2";      shift 2 ;;
        --db-url)       DB_URL="$2";       shift 2 ;;
        --db-user)      DB_USER="$2";      shift 2 ;;
        --db-password)  DB_PASSWORD="$2";  shift 2 ;;
        --jwt-secret)   JWT_SECRET="$2";   shift 2 ;;
        --supabase-url) SUPABASE_URL="$2"; shift 2 ;;
        --supabase-key) SUPABASE_KEY="$2"; shift 2 ;;
        --push)         PUSH="$2";         shift 2 ;;
        --mapbox-token) MAPBOX_TOKEN="$2"; shift 2 ;;
        *) log_error "Argument inconnu : $1"; usage ;;
    esac
done

[[ -z "$APP_NAME" || -z "$PACKAGE" || -z "$BACKEND" ]] && usage

# ── Vérification d'idempotence ────────────────────────────────────────────────
if [[ -f ".template-initialized" ]]; then
    log_error "Le projet est déjà initialisé (.template-initialized présent)."
    log_error "Pour ajouter des cibles, utilisez : ./gradlew addTargetIos (ou Desktop, Web)"
    exit 1
fi

log_info "════════════════════════════════════════════════════"
log_info "  Initialisation du projet KMP"
log_info "  App     : ${APP_NAME}"
log_info "  Package : ${PACKAGE}"
log_info "  Prefix  : ${PREFIX}"
log_info "  Cibles  : android=${TARGET_ANDROID} ios=${TARGET_IOS} desktop=${TARGET_DESKTOP} web=${TARGET_WEB}"
log_info "  Backend : ${BACKEND}"
log_info "════════════════════════════════════════════════════"

# ── Téléchargement des modules communs ───────────────────────────────────────
log_info "Téléchargement des modules communs…"

for module in shared core feature/auth feature/profile feature/notifications feature/settings feature/dashboard; do
    degit_fetch "$module" "$module"
done

# ── Téléchargement selon les cibles ──────────────────────────────────────────
if [[ "$TARGET_ANDROID" == "true" ]]; then
    degit_fetch "composeApp/src/androidMain" "composeApp/src/androidMain"
fi

if [[ "$TARGET_IOS" == "true" ]]; then
    degit_fetch "composeApp/src/iosMain" "composeApp/src/iosMain"
    degit_fetch "iosApp" "iosApp"
fi

if [[ "$TARGET_DESKTOP" == "true" ]]; then
    degit_fetch "composeApp/src/jvmMain" "composeApp/src/jvmMain"
fi

if [[ "$TARGET_WEB" == "true" ]]; then
    degit_fetch "composeApp/src/wasmJsMain" "composeApp/src/wasmJsMain"
fi

# Fichiers racine de l'app (build.gradle.kts, settings.gradle.kts, etc.)
degit_fetch "composeApp/src/commonMain" "composeApp/src/commonMain"
degit_fetch "gradle" "gradle"
degit_fetch "build-logic" "build-logic"

# ── Écriture de gradle.properties ────────────────────────────────────────────
log_info "Écriture de gradle.properties…"
write_gradle_prop "app.name"          "$APP_NAME"
write_gradle_prop "app.package"       "$PACKAGE"
write_gradle_prop "app.prefix"        "$PREFIX"
write_gradle_prop "kmp.target.android" "$TARGET_ANDROID"
write_gradle_prop "kmp.target.ios"     "$TARGET_IOS"
write_gradle_prop "kmp.target.desktop" "$TARGET_DESKTOP"
write_gradle_prop "kmp.target.web"     "$TARGET_WEB"
write_gradle_prop "backend.type"       "$BACKEND"
write_gradle_prop "push.type"          "$PUSH"

# ── Backend : credentials ────────────────────────────────────────────────────
if [[ "$BACKEND" == "ktor-server" ]]; then
    log_info "Configuration backend ktor-server…"
    ensure_gitignored "gradle.properties"
    write_gradle_prop "db.url"      "$DB_URL"
    write_gradle_prop "db.user"     "$DB_USER"
    write_gradle_prop "db.password" "$DB_PASSWORD"
    write_gradle_prop "jwt.secret"  "$JWT_SECRET"
    log_warn "gradle.properties contient des credentials — vérifiez qu'il est gitignored."
fi

if [[ "$BACKEND" == "supabase" ]]; then
    log_info "Configuration backend supabase…"
    ensure_gitignored "local.properties"
    {
        echo "SUPABASE_URL=${SUPABASE_URL}"
        echo "SUPABASE_KEY=${SUPABASE_KEY}"
    } >> "local.properties"
    log_success "Credentials Supabase écrits dans local.properties"
fi

# ── Renommage package / prefix ───────────────────────────────────────────────
log_info "Application du renommage…"
apply_rename "." "$PACKAGE" "$PREFIX"

# ── Mapbox ───────────────────────────────────────────────────────────────────
if [[ -n "$MAPBOX_TOKEN" ]]; then
    log_info "Configuration Mapbox…"
    "${SCRIPT_DIR}/add-maps.sh" --token "$MAPBOX_TOKEN"
fi

# ── Nettoyage du fichier de config (peut contenir des credentials) ────────────
if [[ -f "template.config.gradle.kts" ]]; then
    rm "template.config.gradle.kts"
    log_info "template.config.gradle.kts supprimé."
fi

# ── Marqueur d'initialisation ─────────────────────────────────────────────────
{
    echo "initialized_at=$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "template_version=1.0.0"
} > ".template-initialized"

log_success "════════════════════════════════════════════════════"
log_success "  Projet initialisé avec succès !"
log_success ""
log_success "  Prochaine étape :"
log_success "  git add -A && git commit -m \"chore: init from kmp-template\""
log_success ""
log_success "  Puis ouvre le projet dans Android Studio."
log_success "════════════════════════════════════════════════════"
