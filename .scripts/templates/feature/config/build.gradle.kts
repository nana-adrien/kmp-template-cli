plugins {
    alias(libs.plugins.convention.kmp.library)
}

kotlin {
    sourceSets {
        commonMain.dependencies {
            implementation(projects.feature.featurename.data)
            implementation(projects.feature.featurename.presentation)
            implementation(libs.koin.core)
        }
    }
}
