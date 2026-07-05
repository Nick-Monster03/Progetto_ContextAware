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
import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import com.example.myapplication.services.TrackingService
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items

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
    val userLocation by viewModel.userLocation.collectAsState()
    val suggestionEvent by viewModel.suggestionEvent.collectAsState()
    val rankingList by viewModel.rankingList.collectAsState()
    val showRankingSheet by viewModel.showRankingSheet.collectAsState()

    var showBottomSheet by remember { mutableStateOf(false) }
    val permissionsToRequest = remember {
        mutableListOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }.toTypedArray()
    }

    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestMultiplePermissions()
    ) { permissionsMap ->
        val fineLocationGranted = permissionsMap[Manifest.permission.ACCESS_FINE_LOCATION] == true
        val coarseLocationGranted = permissionsMap[Manifest.permission.ACCESS_COARSE_LOCATION] == true

        if (fineLocationGranted || coarseLocationGranted) {
            val intent = Intent(context, TrackingService::class.java).apply {
                action = TrackingService.ACTION_START
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }
    val uiMessage by viewModel.uiMessage.collectAsState()

    LaunchedEffect(uiMessage) {
        uiMessage?.let {
            Toast.makeText(context, it, Toast.LENGTH_SHORT).show()
            viewModel.clearUiMessage()
        }
    }

    LaunchedEffect(Unit) {
        val hasFineLocation = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasFineLocation) {
            permissionLauncher.launch(permissionsToRequest)
        } else {
            val intent = Intent(context, TrackingService::class.java).apply {
                action = TrackingService.ACTION_START
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }
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

    //MARKER POI
    LaunchedEffect(poiList) {
        mapView.overlays.removeAll { it !is org.osmdroid.views.overlay.Marker || it.id != "user_location" } // <-- ATTENZIONE QUI

        poiList.forEach { poi ->
            addGeoJsonToMap(
                mapView = mapView,
                poiId = poi.id,
                nome = poi.nome,
                descrizione = poi.descrizione ?: "Campus: ${poi.campus}",
                jsonElement = poi.geometria,
                onClick = {
                    viewModel.selectPoi(poi)
                    viewModel.registraClickMarker(poi)}
            )
        }
        mapView.invalidate()
    }

    //MARKER UTENTE
    LaunchedEffect(userLocation) {
        userLocation?.let { location ->
            Log.d("MapView", "Disegno il marker utente a: ${location.latitude}, ${location.longitude}")

            mapView.overlays.removeAll { it is org.osmdroid.views.overlay.Marker && it.id == "user_location" }
            val userMarker = org.osmdroid.views.overlay.Marker(mapView).apply {
                id = "user_location"
                position = GeoPoint(location.latitude, location.longitude)
                title = "Tu sei qui"
                setAnchor(org.osmdroid.views.overlay.Marker.ANCHOR_CENTER, org.osmdroid.views.overlay.Marker.ANCHOR_BOTTOM)
                icon = ContextCompat.getDrawable(context, R.drawable.ic_blue_dot)
            }
            mapView.overlays.add(userMarker)
            mapView.postInvalidate()
        }
    }

    Box(modifier = Modifier.fillMaxSize().statusBarsPadding()) {
        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { mapView },
            update = { _ -> }
        )

        Column(
            modifier = Modifier
                .align(Alignment.TopStart)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Pulsante filtri
            SmallFloatingActionButton(
                onClick = { showBottomSheet = true },
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MaterialTheme.colorScheme.primary
            ) {
                Icon(
                    painter = painterResource(id = R.drawable.outline_add_2_24),
                    contentDescription = "Filtri"
                )
            }

            // Pulsante top 20 ranking
            SmallFloatingActionButton(
                onClick = { viewModel.fetchRankingList() },
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary
            ) {
                Icon(
                    painter = painterResource(id = org.osmdroid.library.R.drawable.ic_menu_mylocation),
                    contentDescription = "Servizi Vicini"
                )
            }
        }

        if (suggestionEvent != null) {
            Card(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 80.dp, start = 16.dp, end = 16.dp)
                    .fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                elevation = CardDefaults.cardElevation(8.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            painter = painterResource(id = R.drawable.outline_emoji_objects_24),
                            contentDescription = "Suggerimento",
                            tint = MaterialTheme.colorScheme.onPrimaryContainer,
                            modifier = Modifier.padding(end = 8.dp)
                        )

                        Text(
                            text = "Suggerimento Context-Aware",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.onPrimaryContainer,
                            modifier = Modifier.weight(1f)
                        )

                        IconButton(onClick = { viewModel.dismissSuggestion() }) {
                            Icon(painterResource(id = android.R.drawable.ic_menu_close_clear_cancel), contentDescription = "Chiudi")
                        }
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = suggestionEvent!!.messaggio ?: "Nessun messaggio",
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onPrimaryContainer
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = suggestionEvent!!.motivo ?: "",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }

        if (isLoading) {
            CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
        }
    }

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
    if (showRankingSheet) {
        ModalBottomSheet(
            onDismissRequest = { viewModel.dismissRankingSheet() },
            modifier = Modifier.fillMaxHeight(0.8f)
        ) {
            Column(modifier = Modifier.padding(16.dp).fillMaxSize()) {
                Text(
                    "Servizi Consigliati",
                    style = MaterialTheme.typography.headlineMedium,
                    color = MaterialTheme.colorScheme.primary
                )
                Text("Ordinati in base a posizione, orari e preferenze", style = MaterialTheme.typography.bodySmall)
                Spacer(modifier = Modifier.height(16.dp))

                if (rankingList.isEmpty()) {
                    Text("Nessun servizio disponibile o aperto nelle vicinanze.")
                } else {
                    LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        items(rankingList) { item ->
                            Card(
                                modifier = Modifier.fillMaxWidth(),
                                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
                            ) {
                                Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text(item.poi.nome, style = MaterialTheme.typography.titleMedium)
                                        Text("Categoria: ${viewModel.getCategoryNameForPoi(item.poi)}", style = MaterialTheme.typography.bodySmall)
                                    }
                                    Surface(
                                        shape = RoundedCornerShape(8.dp),
                                        color = MaterialTheme.colorScheme.primary
                                    ) {
                                        Text(
                                            text = "Pt: ${String.format("%.2f", item.punteggio)}",
                                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                                            color = MaterialTheme.colorScheme.onPrimary,
                                            style = MaterialTheme.typography.labelLarge
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}