plugins {
    alias(libs.plugins.convention.cmp.library)
}

kotlin {
    sourceSets {
        commonMain.dependencies {
            implementation(projects.feature.featurename.domain)
            implementation(projects.core.presentation)
        }
    }
}
