package __PACKAGE__.feature.featurename.data.remote.dto

import kotlinx.serialization.Serializable
import __PACKAGE__.feature.featurename.domain.models.FeatureName

@Serializable
data class FeatureNameResponse(
    val id: String,
    val name: String
)

fun FeatureNameResponse.toDomain(): FeatureName = FeatureName(
    id = id,
    name = name
)
