# kmp-template-cli

Outil compagnon du repo de référence **kmp-template** — génère un projet
Kotlin Multiplatform / Compose Multiplatform complet depuis Android Studio,
sans terminal interactif.

---

## Flux d'initialisation

### 1. Clone du repo

```bash
git clone git@github.com:ton-compte/kmp-template-cli.git MonProjet
cd MonProjet
```

### 2. Ouvrir dans Android Studio

Ouvre le dossier `MonProjet` dans Android Studio.
Android Studio détecte automatiquement le projet Gradle.

### 3. Remplir `template.config.gradle.kts`

C'est **le seul fichier à modifier**. Il s'ouvre dans Android Studio avec
autocomplétion et coloration syntaxique.

```kotlin
val appName       = "MonApp"            // Nom de l'application
val packageName   = "com.mon.app"       // Package Android/Kotlin
val componentPrefix = "Mon"             // Préfixe UI (MonButton, MonTextField…)

val targetAndroid = true                // Cibles actives
val targetIos     = true
val targetDesktop = false
val targetWeb     = false

val backendType = "ktor"                // "ktor" | "ktor-server" | "supabase"
val pushType    = "none"                // "firebase" | "apns" | "none"
val mapboxToken = ""                    // Laisse vide si non utilisé
```

### 4. Exécuter `applyConfig`

**Via le panneau Gradle d'Android Studio :**
```
Tasks → template → applyConfig  (double-clic)
```

**Ou via terminal :**
```bash
./gradlew applyConfig
```

La tâche valide la config, télécharge le code depuis le repo de référence,
applique les renommages, et supprime `template.config.gradle.kts`.

### 5. Commit initial

```bash
git add -A
git commit -m "chore: init from kmp-template"
```

---

## Tâches disponibles après initialisation

Toutes les tâches apparaissent dans **Gradle → Tasks → template** dans Android Studio.

### Gestion des cibles

| Tâche | Description |
|-------|-------------|
| `addTargetIos` | Ajoute la cible iOS (télécharge depuis le repo) |
| `addTargetDesktop` | Ajoute la cible Desktop |
| `addTargetWeb` | Ajoute la cible Web (WASM) |
| `disableTargetIos` | Désactive iOS temporairement (code conservé) |
| `enableTargetIos` | Réactive iOS |
| `removeTargetIos` | ⚠ Supprime définitivement iOS |
| *(idem pour Desktop et Web)* | |

### Features

```bash
# Via terminal
./gradlew createFeature -PfeatureName=commandes

# Via Android Studio
# Double-clic sur createFeature → Run Gradle Task → ajouter : -PfeatureName=commandes
```

Génère `feature/commandes/` avec les 4 sous-modules (domain, data, presentation, config)
suivant l'architecture Clean Architecture / MVI.

### Backend et modules

| Tâche | Description |
|-------|-------------|
| `addServer` | Ajoute le serveur Spring Boot (mode interactif) |
| `addMaps -PmapboxToken=pk.eyJ...` | Ajoute le module Mapbox |

### Maintenance

| Tâche | Description |
|-------|-------------|
| `updateCore` | Synchronise `core/` avec la dernière version du template |
| `doctor` | Vérifie la cohérence du projet |

---

## Tâches paramétrées — Android Studio sans terminal

Pour les tâches qui nécessitent un paramètre (ex: `createFeature`, `addMaps`) :

1. Double-clic sur la tâche dans le panneau Gradle
2. Android Studio affiche "Run Gradle Task"
3. Dans le champ des arguments, ajouter le paramètre :
   - `createFeature` → `-PfeatureName=commandes`
   - `addMaps` → `-PmapboxToken=pk.eyJ...`

---

## Configuration `.template-meta`

Le fichier `.template-meta` contient l'URL SSH du repo de référence.
À modifier si tu héberges le repo sous ton propre compte :

```
TEMPLATE_REPO=git@github.com:ton-compte/kmp-template.git
```

**Prérequis :** ta clé SSH doit être configurée pour GitHub.
```bash
ssh -T git@github.com
```

---

## Architecture générée

```
MonProjet/
├── composeApp/          # Point d'entrée UI (Android + iOS + Desktop + Web)
├── shared/              # Code partagé multiplateforme
├── core/
│   ├── config/          # DI Koin core
│   ├── data/            # Réseau (Ktor), DTO, extensions
│   ├── domain/          # Modèles partagés, interfaces
│   └── presentation/    # Composables communs, thème
├── feature/
│   ├── auth/            # Authentification
│   ├── profile/         # Profil utilisateur
│   ├── notifications/   # Notifications
│   ├── settings/        # Paramètres
│   └── dashboard/       # Tableau de bord
└── build-logic/         # Convention plugins Gradle
```

Chaque feature suit l'architecture **Clean Architecture + MVI** :
`domain` → `data` → `presentation` → `config`

---

## Stack technique

| Domaine | Bibliothèque | Version |
|---------|-------------|---------|
| UI | Compose Multiplatform | 1.10.3 |
| Réseau | Ktor Client | 3.2.3 |
| DI | Koin | 4.1.0 |
| Sérialisation | Kotlinx Serialization | 1.9.0 |
| Base de données | Room | 2.7.2 |
| Préférences | DataStore | 1.1.7 |
| Images | Coil | 3.3.0 |

---

## Licence

MIT — voir [LICENSE](LICENSE)
