package __PACKAGE__.feature.featurename.presentation

import __PACKAGE__.feature.featurename.domain.models.FeatureName
import octopusfx.client.mobile.core.presentation.UiText

data class FeatureNameState(
    val items: List<FeatureName> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: UiText? = null
)
