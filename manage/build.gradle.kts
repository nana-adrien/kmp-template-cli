// ════════════════════════════════════════════════════════════════
//  Module manage — Gestion des cibles et modules (permanent)
// ════════════════════════════════════════════════════════════════

fun runScript(args: List<String>) {
    val process = ProcessBuilder(args)
        .directory(rootProject.projectDir)
        .inheritIO()
        .start()
    val exitCode = process.waitFor()
    if (exitCode != 0)
        throw GradleException("Script '${args[0]}' a échoué (code $exitCode)")
}

// ── Gestion des cibles ────────────────────────────────────────────────────────
listOf("ios", "desktop", "web").forEach { target ->
    val targetCap = target.replaceFirstChar { it.uppercase() }

    tasks.register("addTarget$targetCap") {
        group = "template"
        description = "Ajoute la cible $target (télécharge le code depuis le repo de référence)"
        doLast { runScript(listOf(".scripts/add-target.sh", target)) }
    }

    tasks.register("disableTarget$targetCap") {
        group = "template"
        description = "Désactive $target temporairement (code conservé sur le disque)"
        doLast { runScript(listOf(".scripts/disable-target.sh", target)) }
    }

    tasks.register("enableTarget$targetCap") {
        group = "template"
        description = "Réactive $target (flag Gradle uniquement)"
        doLast { runScript(listOf(".scripts/enable-target.sh", target)) }
    }

    tasks.register("removeTarget$targetCap") {
        group = "template"
        description = "⚠ Supprime définitivement la cible $target et son code"
        doLast { runScript(listOf(".scripts/remove-target.sh", target)) }
    }
}

// ── Backend ───────────────────────────────────────────────────────────────────
tasks.register("addServer") {
    group = "template"
    description = "Ajoute le serveur Spring Boot (bascule depuis le mode Ktor-only)"
    doLast { runScript(listOf(".scripts/add-server.sh")) }
}

// ── Modules optionnels ────────────────────────────────────────────────────────
// Usage : ./gradlew :manage:addMaps -PmapboxToken=pk.eyJ...
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
        runScript(listOf(".scripts/add-maps.sh", "--token", token))
    }
}

// ── Maintenance ───────────────────────────────────────────────────────────────
tasks.register("updateCore") {
    group = "template"
    description = "Re-synchronise core/ avec la dernière version du repo de référence"
    doLast { runScript(listOf(".scripts/update-core.sh")) }
}

tasks.register("doctor") {
    group = "template"
    description = "Vérifie la cohérence du projet (cibles, flags, credentials)"
    doLast { runScript(listOf(".scripts/doctor.sh")) }
}
