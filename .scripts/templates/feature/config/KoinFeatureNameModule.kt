package __PACKAGE__.feature.featurename.config

import __PACKAGE__.feature.featurename.data.remote.datasource.FeatureNameRemoteDataSource
import __PACKAGE__.feature.featurename.data.repositories.FeatureNameRepository
import __PACKAGE__.feature.featurename.domain.repository.IFeatureNameRepository
import __PACKAGE__.feature.featurename.domain.use_case.GetFeatureNameUseCase
import __PACKAGE__.feature.featurename.presentation.FeatureNameViewModel
import org.koin.core.module.dsl.singleOf
import org.koin.core.module.dsl.viewModelOf
import org.koin.dsl.bind
import org.koin.dsl.module

val featureFeatureNameModule = module {
    // Couche data
    singleOf(::FeatureNameRemoteDataSource)
    singleOf(::FeatureNameRepository) bind IFeatureNameRepository::class

    // Couche domain
    singleOf(::GetFeatureNameUseCase)

    // Couche presentation
    viewModelOf(::FeatureNameViewModel)
}
