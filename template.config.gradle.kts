// ════════════════════════════════════════════════════════════════
//  KMP Template — Configuration du projet
//  1. Remplis les valeurs ci-dessous
//  2. Panneau Gradle → Tasks → template → applyConfig
//     ou : ./gradlew applyConfig
//  Ce fichier est supprimé automatiquement après l'initialisation.
// ════════════════════════════════════════════════════════════════

// ── Identité de l'application ─────────────────────────────────
// Nom affiché dans Android Studio, Xcode et sur l'icône de l'app
val appName = "MonApp"

// Package Android/Kotlin (remplace empire.digiprem.kmptemplate partout)
val packageName = "com.monentreprise.monapp"

// Préfixe des composants UI : "Mon" → MonButton, MonTextField…
val componentPrefix = "Mon"

// ── Cibles plateformes ────────────────────────────────────────
val targetAndroid = true
val targetIos     = true
val targetDesktop = false
val targetWeb     = false

// ── Backend ───────────────────────────────────────────────────
// "ktor"        → client Ktor, appels vers une API externe (défaut)
// "ktor-server" → Spring Boot inclus dans ce repo + PostgreSQL Supabase
// "supabase"    → BaaS Supabase via supabase-kt SDK (client direct)
val backendType = "ktor"

// Renseigner uniquement si backendType = "ktor-server"
val dbUrl      = ""   // jdbc:postgresql://db.xxxx.supabase.co:5432/postgres
val dbUser     = ""   // postgres
val dbPassword = ""
val jwtSecret  = ""   // base64, min 32 chars

// Renseigner uniquement si backendType = "supabase"
val supabaseUrl     = ""   // https://xxxx.supabase.co
val supabaseAnonKey = ""   // eyJhbGci...

// ── Push notifications ────────────────────────────────────────
// "firebase" → FCM Android + iOS
// "apns"     → APNs iOS uniquement
// "none"     → aucune notification push
val pushType = "none"

// ── Mapbox (laisser vide si non utilisé) ──────────────────────
// Token public Mapbox, commence par pk.eyJ…
val mapboxToken = ""

// ── Export pour les tâches Gradle (ne pas modifier) ───────────
extra["appName"]        = appName
extra["packageName"]    = packageName
extra["componentPrefix"] = componentPrefix
extra["targetAndroid"]  = targetAndroid
extra["targetIos"]      = targetIos
extra["targetDesktop"]  = targetDesktop
extra["targetWeb"]      = targetWeb
extra["backendType"]    = backendType
extra["dbUrl"]          = dbUrl
extra["dbUser"]         = dbUser
extra["dbPassword"]     = dbPassword
extra["jwtSecret"]      = jwtSecret
extra["supabaseUrl"]    = supabaseUrl
extra["supabaseAnonKey"] = supabaseAnonKey
extra["pushType"]       = pushType
extra["mapboxToken"]    = mapboxToken
