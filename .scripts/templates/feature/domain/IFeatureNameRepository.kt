package __PACKAGE__.feature.featurename.domain.repository

import __PACKAGE__.feature.featurename.domain.models.FeatureName
import octopusfx.client.mobile.core.domain.network.DataError
import octopusfx.client.mobile.core.shared.util.Result

interface IFeatureNameRepository {
    suspend fun getAll(): Result<List<FeatureName>, DataError.Remote>
}
