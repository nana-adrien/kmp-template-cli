#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

require_initialized

current_backend=$(read_gradle_prop "backend.type")

if [[ "$current_backend" == "ktor-server" ]]; then
    log_info "Le backend ktor-server est déjà configuré."
    exit 0
fi

log_info "Ajout du serveur Spring Boot…"
log_info "Tu vas devoir renseigner les credentials de ta base de données PostgreSQL."
echo ""

# ── Collecte interactive des credentials ─────────────────────────────────────
read -rp "URL JDBC PostgreSQL (jdbc:postgresql://...): " DB_URL
read -rp "Utilisateur DB : " DB_USER
read -rsp "Mot de passe DB : " DB_PASSWORD; echo ""
read -rsp "JWT secret (base64, min 32 chars) : " JWT_SECRET; echo ""

if [[ -z "$DB_URL" || -z "$DB_USER" || -z "$DB_PASSWORD" || -z "$JWT_SECRET" ]]; then
    log_error "Tous les champs sont requis."
    exit 1
fi

if [[ ${#JWT_SECRET} -lt 32 ]]; then
    log_error "JWT secret trop court (minimum 32 caractères)."
    exit 1
fi

# ── Téléchargement du module server ──────────────────────────────────────────
degit_fetch "server" "server"

PACKAGE=$(read_gradle_prop "app.package")
PREFIX=$(read_gradle_prop "app.prefix")
source "${SCRIPT_DIR}/lib/rename-utils.sh"
apply_rename "server" "$PACKAGE" "$PREFIX"

# ── Écriture des credentials ──────────────────────────────────────────────────
ensure_gitignored "gradle.properties"
write_gradle_prop "backend.type"  "ktor-server"
write_gradle_prop "db.url"        "$DB_URL"
write_gradle_prop "db.user"       "$DB_USER"
write_gradle_prop "db.password"   "$DB_PASSWORD"
write_gradle_prop "jwt.secret"    "$JWT_SECRET"

log_success "Serveur Spring Boot ajouté avec succès."
log_warn "N'oublie pas de mettre à jour BASE_URL dans HttpConstants.kt"
log_info "  Pointe vers l'URL publique de ton serveur Spring Boot."
log_info "Ajoute le module :server dans settings.gradle.kts si pas déjà présent."
log_info "Resynchronise Gradle dans Android Studio."
