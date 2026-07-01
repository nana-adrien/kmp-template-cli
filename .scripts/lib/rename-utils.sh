#!/usr/bin/env bash
# Utilitaires de renommage — applique package + prefix sur les fichiers du projet

# Placeholder présents dans le repo de référence
_DEFAULT_PACKAGE="empire.digiprem.kmptemplate"
_DEFAULT_PACKAGE_PATH="empire/digiprem/kmptemplate"
_DEFAULT_PREFIX="KmpTemplate"

# ── apply_rename ──────────────────────────────────────────────────────────────
# Usage : apply_rename <dossier> <nouveau_package> <nouveau_prefix>
# Remplace dans le contenu ET renomme les dossiers/fichiers.
apply_rename() {
    local dir="$1"
    local new_package="$2"
    local new_prefix="$3"

    if [[ ! -d "$dir" ]]; then
        return 0
    fi

    local new_package_path
    new_package_path=$(echo "$new_package" | tr '.' '/')

    # 1. Remplacement dans le contenu des fichiers
    log_info "Remplacement des packages et prefixes dans ${dir}…"
    find "$dir" -type f \( \
        -name "*.kt" -o -name "*.kts" -o -name "*.xml" \
        -o -name "*.swift" -o -name "*.xcconfig" -o -name "*.toml" \
        -o -name "*.gradle" -o -name "*.properties" \
    \) | while IFS= read -r file; do
        # Remplace package
        sed -i.bak \
            -e "s|${_DEFAULT_PACKAGE}|${new_package}|g" \
            "$file"
        # Remplace prefix
        sed -i.bak \
            -e "s|${_DEFAULT_PREFIX}|${new_prefix}|g" \
            "$file"
        rm -f "${file}.bak"
    done

    # 2. Renommage des dossiers de packages (chemin physique)
    if [[ "$new_package_path" != "$_DEFAULT_PACKAGE_PATH" ]]; then
        log_info "Renommage des dossiers de packages dans ${dir}…"
        # Cherche les chemins contenant l'ancien package path
        find "$dir" -type d -name "kmptemplate" | sort -r | while IFS= read -r old_dir; do
            local parent_new
            parent_new=$(echo "$old_dir" | sed "s|${_DEFAULT_PACKAGE_PATH}|${new_package_path}|g")
            if [[ "$old_dir" != "$parent_new" ]]; then
                mkdir -p "$(dirname "$parent_new")"
                mv "$old_dir" "$parent_new"
            fi
        done
    fi

    # 3. Renommage des fichiers contenant le prefix
    if [[ "$new_prefix" != "$_DEFAULT_PREFIX" ]]; then
        log_info "Renommage des fichiers avec le prefix dans ${dir}…"
        find "$dir" -type f -name "*${_DEFAULT_PREFIX}*" | sort -r | while IFS= read -r old_file; do
            local new_file
            new_file=$(echo "$old_file" | sed "s|${_DEFAULT_PREFIX}|${new_prefix}|g")
            if [[ "$old_file" != "$new_file" ]]; then
                mv "$old_file" "$new_file"
            fi
        done
    fi

    log_success "Renommage terminé dans : ${dir}"
}
