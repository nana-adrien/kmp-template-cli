package __PACKAGE__.feature.featurename.data.remote.datasource

import __PACKAGE__.feature.featurename.data.remote.dto.FeatureNameResponse
import __PACKAGE__.feature.featurename.data.remote.dto.toDomain
import __PACKAGE__.feature.featurename.domain.models.FeatureName
import io.ktor.client.HttpClient
import octopusfx.client.mobile.core.data.dto.ApiResponseWithPayload
import octopusfx.client.mobile.core.data.extensions.get
import octopusfx.client.mobile.core.domain.network.DataError
import octopusfx.client.mobile.core.shared.util.Result
import octopusfx.client.mobile.core.shared.util.map

class FeatureNameRemoteDataSource(private val client: HttpClient) {

    suspend fun getAll(): Result<List<FeatureName>, DataError.Remote> {
        return client.get<ApiResponseWithPayload<List<FeatureNameResponse>>>(
            route = "v1/featurename"
        ).map { response ->
            response.payload?.map { it.toDomain() } ?: emptyList()
        }
    }
}
