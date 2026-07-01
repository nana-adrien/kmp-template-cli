package __PACKAGE__.feature.featurename.presentation

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun FeatureNameRoot(
    onNavigateBack: () -> Unit,
    viewModel: FeatureNameViewModel = koinViewModel()
) {
    val state by viewModel.state.collectAsStateWithLifecycle()

    ObservableEvent(flow = viewModel.events) { event ->
        when (event) {
            FeatureNameEvent.OnNavigateBack -> onNavigateBack()
        }
    }

    FeatureNameScreen(state = state, onAction = viewModel::onAction)
}

@Composable
fun FeatureNameScreen(
    state: FeatureNameState,
    onAction: (FeatureNameAction) -> Unit,
    modifier: Modifier = Modifier
) {
    if (state.isLoading) {
        Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            // OctopusfxLoadingSpinner()
        }
        return
    }

    LazyColumn(modifier = modifier.fillMaxSize()) {
        items(state.items) { item ->
            Text(text = item.name)
        }
    }
}
