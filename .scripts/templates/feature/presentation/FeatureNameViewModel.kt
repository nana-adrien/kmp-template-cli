package __PACKAGE__.feature.featurename.presentation

import __PACKAGE__.feature.featurename.domain.use_case.GetFeatureNameUseCase
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import octopusfx.client.mobile.core.shared.util.onFailure
import octopusfx.client.mobile.core.shared.util.onSuccess
import octopusfx.client.mobile.core.presentation.AbstractPageManagerViewModel

class FeatureNameViewModel(
    private val getFeatureNameUseCase: GetFeatureNameUseCase
) : AbstractPageManagerViewModel() {

    private val _state = MutableStateFlow(FeatureNameState())
    val state = _state
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5_000L),
            initialValue = FeatureNameState()
        )

    private val _eventChannel = Channel<FeatureNameEvent>()
    val events = _eventChannel.receiveAsFlow()

    private var hasLoadedInitialData = false

    init {
        if (!hasLoadedInitialData) {
            hasLoadedInitialData = true
            loadData()
        }
    }

    fun onAction(action: FeatureNameAction) {
        when (action) {
            FeatureNameAction.OnRetry     -> loadData()
            FeatureNameAction.OnBackClick -> viewModelScope.launch {
                _eventChannel.send(FeatureNameEvent.OnNavigateBack)
            }
        }
    }

    private fun loadData() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true, errorMessage = null)
            getFeatureNameUseCase()
                .onSuccess { items ->
                    _state.value = _state.value.copy(isLoading = false, items = items)
                }
                .onFailure { error ->
                    _state.value = _state.value.copy(
                        isLoading = false,
                        errorMessage = error.toUiText()
                    )
                }
        }
    }
}
