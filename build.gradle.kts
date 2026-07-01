// ════════════════════════════════════════════════════════════════
//  kmp-template-cli — Tâches Gradle du groupe "template"
//  Aucune dépendance applicative, aucun module KMP.
// ════════════════════════════════════════════════════════════════

// Charge la config utilisateur si le fichier existe (avant applyConfig)
val configFile = file("template.config.gradle.kts")
if (configFile.exists()) {
    apply(from = configFile)
}

// Accesseurs sécurisés vers les extra properties
fun strProp(key: String): String = extra.properties[key] as? String ?: ""
fun boolProp(key: String): Boolean = extra.properties[key] as? Boolean ?: false

// ── Initialisation ────────────────────────────────────────────────────────────
tasks.register("applyConfig") {
    group = "template"
    description = "Initialise le projet depuis template.config.gradle.kts"
    doLast {
        if (!configFile.exists())
            throw GradleException(
                "template.config.gradle.kts introuvable.\n" +
                "Ce fichier est supprimé après la première initialisation.\n" +
                "Si tu veux réinitialiser, supprime .template-initialized et recrée template.config.gradle.kts."
            )

        val appName        = strProp("appName")
        val packageName    = strProp("packageName")
        val componentPrefix = strProp("componentPrefix")
        val backendType    = strProp("backendType")
        val dbUrl          = strProp("dbUrl")
        val dbUser         = strProp("dbUser")
        val dbPassword     = strProp("dbPassword")
        val jwtSecret      = strProp("jwtSecret")
        val supabaseUrl    = strProp("supabaseUrl")
        val supabaseAnonKey = strProp("supabaseAnonKey")
        val pushType       = strProp("pushType")
        val mapboxToken    = strProp("mapboxToken")
        val targetAndroid  = boolProp("targetAndroid")
        val targetIos      = boolProp("targetIos")
        val targetDesktop  = boolProp("targetDesktop")
        val targetWeb      = boolProp("targetWeb")

        if (appName.isBlank())
            throw GradleException("appName est vide dans template.config.gradle.kts")

        val packageRegex = Regex("[a-z][a-z0-9_]*(\\.[a-z][a-z0-9_]*)+")
        if (!packageName.matches(packageRegex))
            throw GradleException("packageName invalide : $packageName\nFormat attendu : com.monentreprise.monapp")

        if (backendType == "ktor-server" &&
            listOf(dbUrl, dbUser, dbPassword, jwtSecret).any { it.isBlank() })
            throw GradleException(
                "backendType=ktor-server : dbUrl, dbUser, dbPassword et jwtSecret sont tous requis"
            )

        if (backendType == "supabase" &&
            (supabaseUrl.isBlank() || supabaseAnonKey.isBlank()))
            throw GradleException(
                "backendType=supabase : supabaseUrl et supabaseAnonKey sont requis"
            )

        if (mapboxToken.isNotBlank() && !mapboxToken.startsWith("pk.eyJ"))
            throw GradleException("mapboxToken invalide : doit commencer par pk.eyJ")

        exec {
            commandLine(
                ".scripts/init.sh",
                "--app-name",     appName,
                "--package",      packageName,
                "--prefix",       componentPrefix,
                "--android",      targetAndroid.toString(),
                "--ios",          targetIos.toString(),
                "--desktop",      targetDesktop.toString(),
                "--web",          targetWeb.toString(),
                "--backend",      backendType,
                "--db-url",       dbUrl,
                "--db-user",      dbUser,
                "--db-password",  dbPassword,
                "--jwt-secret",   jwtSecret,
                "--supabase-url", supabaseUrl,
                "--supabase-key", supabaseAnonKey,
                "--push",         pushType,
                "--mapbox-token", mapboxToken
            )
        }
    }
}

// ── Gestion des cibles ────────────────────────────────────────────────────────
listOf("ios", "desktop", "web").forEach { target ->
    val targetCap = target.replaceFirstChar { it.uppercase() }

    tasks.register("addTarget$targetCap") {
        group = "template"
        description = "Ajoute la cible $target (télécharge le code depuis le repo de référence)"
        doLast { exec { commandLine(".scripts/add-target.sh", target) } }
    }

    tasks.register("disableTarget$targetCap") {
        group = "template"
        description = "Désactive $target temporairement (code conservé sur le disque)"
        doLast { exec { commandLine(".scripts/disable-target.sh", target) } }
    }

    tasks.register("enableTarget$targetCap") {
        group = "template"
        description = "Réactive $target (flag Gradle uniquement)"
        doLast { exec { commandLine(".scripts/enable-target.sh", target) } }
    }

    tasks.register("removeTarget$targetCap") {
        group = "template"
        description = "⚠ Supprime définitivement la cible $target et son code"
        doLast { exec { commandLine(".scripts/remove-target.sh", target) } }
    }
}

// ── Features métier ───────────────────────────────────────────────────────────
// Usage : ./gradlew createFeature -PfeatureName=commandes
tasks.register("createFeature") {
    group = "template"
    description = "Scaffold une nouvelle feature MVI. Usage : -PfeatureName=<nom>"
    doLast {
        val name = project.findProperty("featureName") as String?
            ?: throw GradleException(
                "Paramètre manquant.\nUsage : ./gradlew createFeature -PfeatureName=commandes\n" +
                "Via Android Studio : double-clic sur la tâche → ajouter -PfeatureName=commandes"
            )
        if (name.isBlank() || !name.matches(Regex("[a-z][a-z0-9_]*")))
            throw GradleException(
                "featureName invalide : $name\n" +
                "Minuscules et underscores uniquement. Ex : commandes, mes_livraisons"
            )
        exec { commandLine(".scripts/create-feature.sh", name) }
    }
}

// ── Backend ───────────────────────────────────────────────────────────────────
tasks.register("addServer") {
    group = "template"
    description = "Ajoute le serveur Spring Boot (bascule depuis le mode Ktor-only)"
    doLast { exec { commandLine(".scripts/add-server.sh") } }
}

// ── Modules optionnels ────────────────────────────────────────────────────────
// Usage : ./gradlew addMaps -PmapboxToken=pk.eyJ...
tasks.register("addMaps") {
    group = "template"
    description = "Ajoute le module Mapbox (feature/geo). Usage : -PmapboxToken=pk.eyJ..."
    doLast {
        val token = project.findProperty("mapboxToken") as String?
            ?: throw GradleException(
                "Paramètre manquant.\nUsage : ./gradlew addMaps -PmapboxToken=pk.eyJ...\n" +
                "Via Android Studio : double-clic sur la tâche → ajouter -PmapboxToken=ton_token"
            )
        if (!token.startsWith("pk.eyJ"))
            throw GradleException("mapboxToken invalide : doit commencer par pk.eyJ")
        exec { commandLine(".scripts/add-maps.sh", "--token", token) }
    }
}

// ── Maintenance ───────────────────────────────────────────────────────────────
tasks.register("updateCore") {
    group = "template"
    description = "Re-synchronise core/ avec la dernière version du repo de référence"
    doLast { exec { commandLine(".scripts/update-core.sh") } }
}

tasks.register("doctor") {
    group = "template"
    description = "Vérifie la cohérence du projet (cibles, flags, credentials)"
    doLast { exec { commandLine(".scripts/doctor.sh") } }
}
