package __PACKAGE__.feature.featurename.domain.use_case

import __PACKAGE__.feature.featurename.domain.models.FeatureName
import __PACKAGE__.feature.featurename.domain.repository.IFeatureNameRepository
import octopusfx.client.mobile.core.domain.network.DataError
import octopusfx.client.mobile.core.shared.util.Result

class GetFeatureNameUseCase(
    private val repository: IFeatureNameRepository
) {
    suspend operator fun invoke(): Result<List<FeatureName>, DataError.Remote> {
        return repository.getAll()
    }
}
