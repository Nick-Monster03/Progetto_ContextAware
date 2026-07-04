package com.example.myapplication.ui.agenda

import android.os.Build
import androidx.annotation.RequiresApi
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.myapplication.data.model.AgendaUtentePublic
import com.example.myapplication.ui.agenda.AgendaUtenteViewModel
import com.example.myapplication.R
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter

@RequiresApi(Build.VERSION_CODES.O)
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AgendaUtenteView(viewModel: AgendaUtenteViewModel) {
    val impegni by viewModel.impegni.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()

    var showCreateDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("La mia Agenda") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { showCreateDialog = true }) {
                Icon(
                    painter = painterResource(id = R.drawable.outline_add_2_24),
                    contentDescription = "Aggiungi Impegno"
                )
            }
        }
    ) { paddingValues ->
        if (isLoading) {
            Box(modifier = Modifier.fillMaxSize().padding(paddingValues), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
        } else if (impegni.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize().padding(paddingValues), contentAlignment = Alignment.Center) {
                Text("Nessun impegno futuro. Goditi il relax!")
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .padding(horizontal = 16.dp),
                contentPadding = PaddingValues(vertical = 16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(impegni, key = { it.id }) { impegno ->
                    ImpegnoCard(impegno)
                }
            }
        }

        if (showCreateDialog) {
            CreaImpegnoDialog(
                viewModel = viewModel,
                onDismiss = { showCreateDialog = false }
            )
        }
    }
}

@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun ImpegnoCard(impegno: AgendaUtentePublic) {

    val dataFormattata = try {
        ZonedDateTime.parse(impegno.orario_inizio).format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))
    } catch (e: Exception) { "" }

    val orarioInizio = try {
        ZonedDateTime.parse(impegno.orario_inizio).format(DateTimeFormatter.ofPattern("HH:mm"))
    } catch (e: Exception) { "N/D" }

    val orarioFine = try {
        ZonedDateTime.parse(impegno.orario_fine).format(DateTimeFormatter.ofPattern("HH:mm"))
    } catch (e: Exception) { "N/D" }

    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(2.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = impegno.titolo,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Luogo: POI #${impegno.id_poi}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Column(horizontalAlignment = Alignment.End) {
                if (dataFormattata.isNotEmpty()) {
                    Text(
                        text = dataFormattata,
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                }
                Text(
                    text = orarioInizio + "-" + orarioFine,
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.secondary,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@RequiresApi(Build.VERSION_CODES.O)
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreaImpegnoDialog(viewModel: AgendaUtenteViewModel, onDismiss: () -> Unit) {
    var titolo by remember { mutableStateOf("") }
    var searchQuery by remember { mutableStateOf("") }
    var selectedPoiId by remember { mutableStateOf<Int?>(null) }
    var isDropdownExpanded by remember { mutableStateOf(false) }

    // 1. Stati per la Data e gli Orari scelti dall'utente
    var selectedDate by remember { mutableStateOf<java.time.LocalDate?>(null) }
    var startTime by remember { mutableStateOf<java.time.LocalTime?>(null) }
    var endTime by remember { mutableStateOf<java.time.LocalTime?>(null) }

    // Stati per controllare la visibilità dei rispettivi Picker Dialog
    var showDatePicker by remember { mutableStateOf(false) }
    var showStartTimePicker by remember { mutableStateOf(false) }
    var showEndTimePicker by remember { mutableStateOf(false) }

    val searchResults by viewModel.poiSearchResults.collectAsState()

    // Controllo di validità temporale: l'inizio deve essere prima della fine
    val isTimeValid = if (startTime != null && endTime != null) {
        startTime!!.isBefore(endTime!!)
    } else {
        true
    }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Nuovo Impegno") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(
                    value = titolo,
                    onValueChange = { titolo = it },
                    label = { Text("Titolo (es. Lezione Analisi 1)") },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )

                // AUTOCOMPLETAMENTO POI
                ExposedDropdownMenuBox(
                    expanded = isDropdownExpanded,
                    onExpandedChange = { isDropdownExpanded = it }
                ) {
                    OutlinedTextField(
                        value = searchQuery,
                        onValueChange = {
                            searchQuery = it
                            isDropdownExpanded = true
                            viewModel.searchPoi(it)
                            if (selectedPoiId != null) selectedPoiId = null
                        },
                        label = { Text("Cerca luogo...") },
                        modifier = Modifier
                            .fillMaxWidth()
                            .menuAnchor(),
                        colors = ExposedDropdownMenuDefaults.outlinedTextFieldColors(),
                        singleLine = true
                    )

                    if (searchResults.isNotEmpty()) {
                        ExposedDropdownMenu(
                            expanded = isDropdownExpanded,
                            onDismissRequest = { isDropdownExpanded = false }
                        ) {
                            searchResults.forEach { poi ->
                                DropdownMenuItem(
                                    text = { Text(poi.nome) },
                                    onClick = {
                                        searchQuery = poi.nome
                                        selectedPoiId = poi.id
                                        isDropdownExpanded = false
                                    }
                                )
                            }
                        }
                    }
                }

                HorizontalDivider(modifier = Modifier.padding(vertical = 4.dp))

                // SELEZIONE DATA
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    val dateText = selectedDate?.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                        ?: "Nessuna data scelta"
                    Text(text = "Data: $dateText", style = MaterialTheme.typography.bodyMedium)
                    Button(onClick = { showDatePicker = true }) {
                        Text("Scegli Data")
                    }
                }

                // SELEZIONE ORARIO INIZIO (Abilitato solo se è stata scelta una data)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    val startText = startTime?.toString() ?: "Non impostato"
                    Text(text = "Inizio: $startText", style = MaterialTheme.typography.bodyMedium)
                    Button(onClick = { showStartTimePicker = true }, enabled = selectedDate != null) {
                        Text("Ora Inizio")
                    }
                }

                // SELEZIONE ORARIO FINE (Abilitato solo se è stata scelta una data)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    val endText = endTime?.toString() ?: "Non impostato"
                    Text(text = "Fine: $endText", style = MaterialTheme.typography.bodyMedium)
                    Button(onClick = { showEndTimePicker = true }, enabled = selectedDate != null) {
                        Text("Ora Fine")
                    }
                }

                // Messaggio d'errore dinamico all'interno del Form
                if (!isTimeValid) {
                    Text(
                        text = "L'orario di fine deve essere successivo a quello di inizio!",
                        color = MaterialTheme.colorScheme.error,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    if (titolo.isNotBlank() && selectedPoiId != null && selectedDate != null && startTime != null && endTime != null && isTimeValid) {

                        // Combiniamo data e orari usando il fuso orario di sistema corrente (es. Europe/Rome)
                        val startZoned = java.time.ZonedDateTime.of(selectedDate, startTime, java.time.ZoneId.systemDefault())
                        val endZoned = java.time.ZonedDateTime.of(selectedDate, endTime, java.time.ZoneId.systemDefault())

                        // Formattazione standard ISO-8601 con offset (es: 2026-07-04T20:00:00+02:00)
                        val formatter = java.time.format.DateTimeFormatter.ISO_OFFSET_DATE_TIME
                        val startFormatted = startZoned.format(formatter)
                        val endFormatted = endZoned.format(formatter)

                        viewModel.createImpegno(titolo, selectedPoiId!!, startFormatted, endFormatted) {
                            onDismiss()
                        }
                    }
                },
                // Il bottone si abilita solo se tutti i dati sono presenti e coerenti
                enabled = titolo.isNotBlank() && selectedPoiId != null && selectedDate != null && startTime != null && endTime != null && isTimeValid
            ) {
                Text("Salva")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Annulla") }
        }
    )

    // ================= PICKER COMPONENTI MATERIAL 3 =================

    // PICKER DELLA DATA (Filtra escludendo il passato)
    if (showDatePicker) {
        val datePickerState = rememberDatePickerState(
            selectableDates = object : SelectableDates {
                override fun isSelectableDate(utcTimeMillis: Long): Boolean {
                    // Ottieni il timestamp dell'inizio della giornata di oggi in UTC
                    val todayStartMillis = java.time.LocalDate.now()
                        .atStartOfDay(java.time.ZoneId.of("UTC"))
                        .toInstant()
                        .toEpochMilli()
                    // Ritorna true solo se la data selezionabile è oggi o futura
                    return utcTimeMillis >= todayStartMillis
                }
            }
        )
        DatePickerDialog(
            onDismissRequest = { showDatePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    selectedDate = datePickerState.selectedDateMillis?.let {
                        java.time.Instant.ofEpochMilli(it)
                            .atZone(java.time.ZoneId.of("UTC"))
                            .toLocalDate()
                    }
                    showDatePicker = false
                }) { Text("OK") }
            },
            dismissButton = {
                TextButton(onClick = { showDatePicker = false }) { Text("Annulla") }
            }
        ) {
            DatePicker(state = datePickerState)
        }
    }

    // PICKER ORARIO INIZIÒ
    if (showStartTimePicker) {
        val timePickerState = rememberTimePickerState()
        TimePickerDialog(
            title = "Seleziona orario di inizio",
            onDismissRequest = { showStartTimePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    startTime = java.time.LocalTime.of(timePickerState.hour, timePickerState.minute)
                    showStartTimePicker = false
                }) { Text("OK") }
            },
            dismissButton = {
                TextButton(onClick = { showStartTimePicker = false }) { Text("Annulla") }
            }
        ) {
            TimePicker(state = timePickerState)
        }
    }

    // PICKER ORARIO FINE
    if (showEndTimePicker) {
        val timePickerState = rememberTimePickerState()
        TimePickerDialog(
            title = "Seleziona orario di fine",
            onDismissRequest = { showEndTimePicker = false },
            confirmButton = {
                TextButton(onClick = {
                    endTime = java.time.LocalTime.of(timePickerState.hour, timePickerState.minute)
                    showEndTimePicker = false
                }) { Text("OK") }
            },
            dismissButton = {
                TextButton(onClick = { showEndTimePicker = false }) { Text("Annulla") }
            }
        ) {
            TimePicker(state = timePickerState)
        }
    }
}

@Composable
fun TimePickerDialog(
    title: String,
    onDismissRequest: () -> Unit,
    confirmButton: @Composable () -> Unit,
    dismissButton: @Composable () -> Unit,
    content: @Composable () -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismissRequest,
        title = { Text(title, style = MaterialTheme.typography.titleMedium) },
        text = { content() },
        confirmButton = confirmButton,
        dismissButton = dismissButton
    )
}