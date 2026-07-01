// ════════════════════════════════════════════════════════════════
//  Module init — Initialisation du projet (supprimé après applyConfig)
// ════════════════════════════════════════════════════════════════

val configFile = rootProject.file("template.config.gradle.kts")
if (configFile.exists()) {
    apply(from = configFile)
}

fun strProp(key: String): String = rootProject.extra.properties[key] as? String ?: ""
fun boolProp(key: String): Boolean = rootProject.extra.properties[key] as? Boolean ?: false

fun runScript(args: List<String>) {
    val process = ProcessBuilder(args)
        .directory(rootProject.projectDir)
        .inheritIO()
        .start()
    val exitCode = process.waitFor()
    if (exitCode != 0)
        throw GradleException("Script '${args[0]}' a échoué (code $exitCode)")
}

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

        val appName         = strProp("appName")
        val packageName     = strProp("packageName")
        val componentPrefix = strProp("componentPrefix")
        val backendType     = strProp("backendType")
        val dbUrl           = strProp("dbUrl")
        val dbUser          = strProp("dbUser")
        val dbPassword      = strProp("dbPassword")
        val jwtSecret       = strProp("jwtSecret")
        val supabaseUrl     = strProp("supabaseUrl")
        val supabaseAnonKey = strProp("supabaseAnonKey")
        val pushType        = strProp("pushType")
        val mapboxToken     = strProp("mapboxToken")
        val targetAndroid   = boolProp("targetAndroid")
        val targetIos       = boolProp("targetIos")
        val targetDesktop   = boolProp("targetDesktop")
        val targetWeb       = boolProp("targetWeb")

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

        runScript(listOf(
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
        ))

        // Auto-nettoyage : supprime ce module après initialisation réussie.
        // Au prochain sync Gradle, settings.gradle.kts ne détectera plus init/
        // et les tâches d'initialisation disparaîtront automatiquement.
        projectDir.deleteRecursively()
    }
}
