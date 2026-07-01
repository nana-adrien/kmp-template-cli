package __PACKAGE__.feature.featurename.presentation

sealed interface FeatureNameAction {
    data object OnRetry : FeatureNameAction
    data object OnBackClick : FeatureNameAction
}
