plugins {
    alias(libs.plugins.convention.kmp.library)
}

kotlin {
    sourceSets {
        commonMain.dependencies {
            implementation(projects.feature.featurename.domain)
            implementation(projects.core.data)
        }
    }
}
