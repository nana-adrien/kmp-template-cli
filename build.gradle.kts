// ════════════════════════════════════════════════════════════════
//  kmp-template-cli — Tâches Gradle du groupe "template"
//  Cette tâche reste disponible après l'initialisation du projet.
// ════════════════════════════════════════════════════════════════

fun runScript(args: List<String>) {
    val process = ProcessBuilder(args)
        .directory(projectDir)
        .inheritIO()
        .start()
    val exitCode = process.waitFor()
    if (exitCode != 0)
        throw GradleException("Script '${args[0]}' a échoué (code $exitCode)")
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
        runScript(listOf(".scripts/create-feature.sh", name))
    }
}
