#!/usr/bin/env bash
# Fonctions partagées — sourcées par tous les scripts .scripts/*.sh

# ── Couleurs ──────────────────────────────────────────────────────────────────
_RED='\033[0;31m'
_GREEN='\033[0;32m'
_YELLOW='\033[1;33m'
_BLUE='\033[0;34m'
_NC='\033[0m'

log_info()    { echo -e "${_BLUE}[INFO]${_NC}  $*"; }
log_warn()    { echo -e "${_YELLOW}[WARN]${_NC}  $*"; }
log_error()   { echo -e "${_RED}[ERROR]${_NC} $*" >&2; }
log_success() { echo -e "${_GREEN}[OK]${_NC}    $*"; }

# ── Confirmation ──────────────────────────────────────────────────────────────
# Usage : confirm "Continuer ?" && do_something
confirm() {
    local msg="${1:-Continuer ?}"
    echo -e "${_YELLOW}${msg} [y/N]${_NC} \c"
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

# ── Lecture du repo de référence ──────────────────────────────────────────────
_meta_file="$(pwd)/.template-meta"

_get_template_repo() {
    if [[ ! -f "$_meta_file" ]]; then
        log_error ".template-meta introuvable — impossible de déterminer l'URL du repo de référence."
        exit 1
    fi
    local repo
    repo=$(grep '^TEMPLATE_REPO=' "$_meta_file" | cut -d'=' -f2-)
    if [[ -z "$repo" ]]; then
        log_error "TEMPLATE_REPO non défini dans .template-meta"
        exit 1
    fi
    echo "$repo"
}

# ── degit_fetch ───────────────────────────────────────────────────────────────
# Usage : degit_fetch <chemin_dans_repo> <dossier_de_destination>
# Ex    : degit_fetch "core" "core"
# Ex    : degit_fetch "feature/auth" "feature/auth"
degit_fetch() {
    local remote_path="$1"
    local local_path="$2"
    local repo
    repo=$(_get_template_repo)

    log_info "Téléchargement de ${remote_path} depuis ${repo}…"

    if ! command -v npx &>/dev/null; then
        log_error "npx est requis. Installe Node.js : https://nodejs.org"
        exit 1
    fi

    # degit utilise le format repo/sous-dossier
    local degit_src="${repo}/${remote_path}"
    # Convertir git@github.com:compte/repo.git → github:compte/repo
    degit_src=$(echo "$degit_src" | sed 's|git@github.com:||' | sed 's|\.git||')

    if ! npx --yes degit "$degit_src" "$local_path" --force 2>&1; then
        log_error "Échec du téléchargement."
        log_error "Vérifie que ta clé SSH est configurée pour GitHub."
        log_error "  ssh -T git@github.com"
        exit 1
    fi
    log_success "Téléchargé : ${remote_path} → ${local_path}"
}

# ── Vérification d'initialisation ────────────────────────────────────────────
require_initialized() {
    if [[ ! -f ".template-initialized" ]]; then
        log_error "Le projet n'est pas encore initialisé."
        log_error "Lance d'abord : ./gradlew applyConfig"
        exit 1
    fi
}

# ── gradle.properties ─────────────────────────────────────────────────────────
_gradle_props="$(pwd)/gradle.properties"

read_gradle_prop() {
    local key="$1"
    if [[ ! -f "$_gradle_props" ]]; then echo ""; return; fi
    grep "^${key}=" "$_gradle_props" | cut -d'=' -f2- | tr -d '[:space:]'
}

write_gradle_prop() {
    local key="$1"
    local value="$2"
    if [[ ! -f "$_gradle_props" ]]; then touch "$_gradle_props"; fi

    if grep -q "^${key}=" "$_gradle_props" 2>/dev/null; then
        # Remplace la valeur existante
        local escaped_value
        escaped_value=$(printf '%s' "$value" | sed 's/[\/&]/\\&/g')
        sed -i.bak "s|^${key}=.*|${key}=${escaped_value}|" "$_gradle_props"
        rm -f "${_gradle_props}.bak"
    else
        echo "${key}=${value}" >> "$_gradle_props"
    fi
}

# ── Vérification .gitignore ───────────────────────────────────────────────────
ensure_gitignored() {
    local pattern="$1"
    local gitignore="$(pwd)/.gitignore"
    if ! grep -qxF "$pattern" "$gitignore" 2>/dev/null; then
        echo "$pattern" >> "$gitignore"
        log_info "Ajouté à .gitignore : $pattern"
    fi
}
