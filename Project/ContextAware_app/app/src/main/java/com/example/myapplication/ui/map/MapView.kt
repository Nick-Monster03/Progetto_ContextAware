package com.example.myapplication.ui.map

import android.content.Context
import android.preference.PreferenceManager
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.example.myapplication.utils.addGeoJsonToMap
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView as OsmMapView

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapView(viewModel: MapViewModel) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current

    // Osserviamo tutti gli stati dal ViewModel
    val poiList by viewModel.poiList.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val categories by viewModel.categories.collectAsState()
    val selectedCategoryId by viewModel.selectedCategoryId.collectAsState()

    LaunchedEffect(Unit) {
        Configuration.getInstance().load(
            context,
            context.getSharedPreferences("osmdroid_prefs", Context.MODE_PRIVATE)
        )
    }

    val mapView = remember {
        OsmMapView(context).apply {
            setTileSource(TileSourceFactory.MAPNIK)
            setMultiTouchControls(true)
            controller.setZoom(16.0)
            controller.setCenter(GeoPoint(44.4949, 11.3426)) // Coordinate Bologna
        }
    }

    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            when (event) {
                Lifecycle.Event.ON_RESUME -> mapView.onResume()
                Lifecycle.Event.ON_PAUSE -> mapView.onPause()
                else -> {}
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
            mapView.onDetach()
        }
    }

    Column(modifier = Modifier.fillMaxSize().statusBarsPadding()) {

        LazyRow(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp, vertical = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            item {
                FilterChip(
                    selected = selectedCategoryId == null,
                    onClick = { viewModel.selectCategory(null) },
                    label = { Text("Suggeriti per te") }
                )
            }

            items(categories) { categoria ->
                val nomeFormattato = categoria.nome.name
                    .replace("_", " ")
                    .lowercase()
                    .replaceFirstChar { it.uppercase() }

                FilterChip(
                    selected = selectedCategoryId == categoria.id,
                    onClick = { viewModel.selectCategory(categoria.id) },
                    label = { Text(nomeFormattato) }
                )
            }
        }

        Box(modifier = Modifier.weight(1f).fillMaxWidth()) {
            AndroidView(
                modifier = Modifier.fillMaxSize(),
                factory = { mapView },
                update = { view ->
                    view.overlays.clear()

                    poiList.forEach { poi ->
                        addGeoJsonToMap(
                            mapView = view,
                            poiId = poi.id,
                            nome = poi.nome,
                            descrizione = poi.descrizione ?: "Campus: ${poi.campus}",
                            jsonElement = poi.geometria
                        )
                    }

                    view.invalidate()
                }
            )

            if (isLoading) {
                CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
            }
        }
    }
}