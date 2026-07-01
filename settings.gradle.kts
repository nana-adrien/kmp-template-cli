rootProject.name = "kmp-template-cli"

// Module de gestion des cibles et modules — toujours présent
include(":manage")

// Module d'initialisation — présent uniquement avant la première init
if (file("init").exists()) {
    include(":init")
}
