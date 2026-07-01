package __PACKAGE__.feature.featurename.data.repositories

import __PACKAGE__.feature.featurename.data.remote.datasource.FeatureNameRemoteDataSource
import __PACKAGE__.feature.featurename.domain.models.FeatureName
import __PACKAGE__.feature.featurename.domain.repository.IFeatureNameRepository
import octopusfx.client.mobile.core.domain.network.DataError
import octopusfx.client.mobile.core.shared.util.Result

class FeatureNameRepository(
    private val remoteDataSource: FeatureNameRemoteDataSource
) : IFeatureNameRepository {

    override suspend fun getAll(): Result<List<FeatureName>, DataError.Remote> {
        return remoteDataSource.getAll()
    }
}
