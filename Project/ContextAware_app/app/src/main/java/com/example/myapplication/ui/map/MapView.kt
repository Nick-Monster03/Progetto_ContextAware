package com.example.myapplication.ui.map

import android.content.Context
import com.example.myapplication.R
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.example.myapplication.utils.addGeoJsonToMap
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView as OsmMapView

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun MapView(viewModel: MapViewModel) {
    val context = LocalContext.current
    val lifecycleOwner = LocalLifecycleOwner.current

    val poiList by viewModel.poiList.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val categories by viewModel.categories.collectAsState()
    val selectedCategories by viewModel.selectedCategories.collectAsState()
    val maxDistance by viewModel.maxDistance.collectAsState()
    val orarioApertura by viewModel.orarioApertura.collectAsState()
    val orarioChiusura by viewModel.orarioChiusura.collectAsState()
    val campus by viewModel.campus.collectAsState()
    val selectedPoi by viewModel.selectedPoi.collectAsState()
    val filterError by viewModel.filterError.collectAsState()

    var showBottomSheet by remember { mutableStateOf(false) }

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

    // CORREZIONE FONDAMENTALE:
    // Spostiamo il disegno dei POI fuori dall'update della View.
    // Questo blocco di codice verrà eseguito SOLO quando la variabile "poiList" cambia.
    LaunchedEffect(poiList) {
        mapView.overlays.clear()
        poiList.forEach { poi ->
            addGeoJsonToMap(
                mapView = mapView,
                poiId = poi.id,
                nome = poi.nome,
                descrizione = poi.descrizione ?: "Campus: ${poi.campus}",
                jsonElement = poi.geometria,
                onClick = { viewModel.selectPoi(poi) }
            )
        }
        mapView.invalidate()
    }

    Box(modifier = Modifier.fillMaxSize().statusBarsPadding()) {
        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { mapView },
            // L'update qui ora rimane vuoto, la gestione degli overlay l'abbiamo demandata al LaunchedEffect in alto
            update = { _ -> }
        )

        SmallFloatingActionButton(
            onClick = { showBottomSheet = true },
            modifier = Modifier
                .align(Alignment.TopStart)
                .padding(16.dp),
            containerColor = MaterialTheme.colorScheme.surface,
            contentColor = MaterialTheme.colorScheme.primary
        ) {
            Icon(
                painter = painterResource(id = R.drawable.outline_add_2_24),
                contentDescription = "Filtri"
            )
        }

        if (isLoading) {
            CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
        }
    }

    // --- BOTTOM SHEET FILTRI ---
    if (showBottomSheet) {
        ModalBottomSheet(
            onDismissRequest = { showBottomSheet = false },
            modifier = Modifier.fillMaxHeight(0.9f)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 16.dp)
                    .padding(bottom = 16.dp)
                    .verticalScroll(rememberScrollState())
            ) {
                Text("Imposta Filtri", style = MaterialTheme.typography.headlineSmall)
                Spacer(modifier = Modifier.height(16.dp))

                Text("Distanza Massima: ${maxDistance?.toInt() ?: "Nessun limite"} metri")
                Slider(
                    value = maxDistance?.toFloat() ?: 10000f,
                    onValueChange = { viewModel.setMaxDistance(it.toDouble()) },
                    valueRange = 500f..10000f,
                    steps = 95
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text("Categorie", style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.height(8.dp))
                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    categories.forEach { categoria ->
                        val isSelected = selectedCategories.contains(categoria.id)
                        val nomeFormattato = categoria.nome.name.replace("_", " ").lowercase().replaceFirstChar { it.uppercase() }

                        Surface(
                            onClick = { viewModel.toggleCategory(categoria.id) },
                            shape = RoundedCornerShape(16.dp),
                            border = if (!isSelected) BorderStroke(1.dp, Color.Black) else null,
                            color = if (isSelected) MaterialTheme.colorScheme.primaryContainer else Color.White
                        ) {
                            Text(
                                text = nomeFormattato,
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                                color = if (isSelected) MaterialTheme.colorScheme.onPrimaryContainer else Color.Black
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text("Fascia Oraria (HH:MM)", style = MaterialTheme.typography.titleMedium)
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedTextField(
                        value = orarioApertura ?: "",
                        onValueChange = { viewModel.setOrarioApertura(it.ifBlank { null }) },
                        label = { Text("Apertura") },
                        modifier = Modifier.weight(1f),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        placeholder = { Text("es. 08:00") }
                    )
                    OutlinedTextField(
                        value = orarioChiusura ?: "",
                        onValueChange = { viewModel.setOrarioChiusura(it.ifBlank { null }) },
                        label = { Text("Chiusura") },
                        modifier = Modifier.weight(1f),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        placeholder = { Text("es. 18:30") }
                    )
                }

                if (filterError != null) {
                    Text(text = filterError!!, color = MaterialTheme.colorScheme.error, modifier = Modifier.padding(top = 4.dp))
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text("Campus", style = MaterialTheme.typography.titleMedium)
                OutlinedTextField(
                    value = campus ?: "",
                    onValueChange = { viewModel.setCampus(it) },
                    label = { Text("Cerca per campus") },
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(24.dp))

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.Start) {
                    Button(
                        onClick = {
                            viewModel.applyFilters()
                            if (filterError == null) {
                                showBottomSheet = false
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Color.Blue, contentColor = Color.White)
                    ) {
                        Text("Applica Filtri")
                    }
                }

                Spacer(modifier = Modifier.height(24.dp))
            }
        }
    }

    if (selectedPoi != null) {
        val poi = selectedPoi!!
        val nomeCategoria = viewModel.getCategoryNameForPoi(poi)

        ModalBottomSheet(
            onDismissRequest = { viewModel.clearSelectedPoi() },
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 16.dp)
            ) {
                Text(
                    text = poi.nome,
                    style = MaterialTheme.typography.headlineSmall
                )

                Spacer(modifier = Modifier.height(4.dp))

                Text(
                    text = "Categoria: $nomeCategoria",
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.primary
                )

                Spacer(modifier = Modifier.height(16.dp))

                if (!poi.descrizione.isNullOrBlank()) {
                    Text(
                        text = poi.descrizione,
                        style = MaterialTheme.typography.bodyLarge
                    )
                } else {
                    Text(
                        text = "Nessuna descrizione",
                        style = MaterialTheme.typography.bodyMedium,
                        color = Color.Gray
                    )
                }

                Spacer(modifier = Modifier.height(48.dp))
            }
        }
    }
}