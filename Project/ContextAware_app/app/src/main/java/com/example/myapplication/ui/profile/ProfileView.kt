package com.example.myapplication.ui.profile

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.myapplication.data.model.MezzoSpostamento

/*Mostra i dati dell'utente loggato e permette di modificare campus,
    mezzo di spostamento e categorie preferite, delegando salvataggio e sincronizzazione al ProfileViewModel*/

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun ProfileView(viewModel: ProfileViewModel) {
    val nome by viewModel.nome.collectAsState()
    val cognome by viewModel.cognome.collectAsState()
    val campus by viewModel.campus.collectAsState()
    val mezzoSpostamento by viewModel.mezzoSpostamento.collectAsState()

    val categories by viewModel.categories.collectAsState()
    val selectedCategories by viewModel.selectedCategories.collectAsState()

    val isLoading by viewModel.isLoading.collectAsState()
    val message by viewModel.message.collectAsState()

    var expandedMezzo by remember { mutableStateOf(false) }

    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(message) {
        message?.let {
            snackbarHostState.showSnackbar(it)
            viewModel.clearMessage()
        }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        modifier = Modifier.fillMaxSize()
    ) { paddingValues ->
        Box(modifier = Modifier.fillMaxSize().padding(paddingValues)) {

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(16.dp)
            ) {
                Text(
                    text = "Profilo Utente",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )

                Spacer(modifier = Modifier.height(24.dp))

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(text = "Informazioni Personali", style = MaterialTheme.typography.titleLarge)
                        Spacer(modifier = Modifier.height(16.dp))

                        Text(text = "Nome: $nome", style = MaterialTheme.typography.bodyLarge)
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(text = "Cognome: $cognome", style = MaterialTheme.typography.bodyLarge)
                        Spacer(modifier = Modifier.height(16.dp))

                        OutlinedTextField(
                            value = campus,
                            onValueChange = { viewModel.setCampus(it) },
                            label = { Text("Campus di preferenza") },
                            modifier = Modifier.fillMaxWidth()
                        )
                        Spacer(modifier = Modifier.height(16.dp))

                        ExposedDropdownMenuBox(
                            expanded = expandedMezzo,
                            onExpandedChange = { expandedMezzo = !expandedMezzo }
                        ) {
                            OutlinedTextField(
                                value = mezzoSpostamento,
                                onValueChange = {},
                                readOnly = true,
                                label = { Text("Mezzo di Spostamento") },
                                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expandedMezzo) },
                                modifier = Modifier.fillMaxWidth().menuAnchor()
                            )
                            ExposedDropdownMenu(
                                expanded = expandedMezzo,
                                onDismissRequest = { expandedMezzo = false }
                            ) {
                                MezzoSpostamento.entries.forEach { mezzo ->
                                    DropdownMenuItem(
                                        text = { Text(mezzo.name) },
                                        onClick = {
                                            viewModel.setMezzoSpostamento(mezzo.name)
                                            expandedMezzo = false
                                        }
                                    )
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                            Button(
                                onClick = { viewModel.updateProfileInfo() },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = Color.Blue,
                                    contentColor = Color.White
                                )
                            ) {
                                Text("Aggiorna Info")
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(32.dp))

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(text = "Le tue Preferenze", style = MaterialTheme.typography.titleLarge)
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "Seleziona le categorie dei servizi che usi più spesso:",
                            style = MaterialTheme.typography.bodyMedium,
                            color = Color.Gray
                        )
                        Spacer(modifier = Modifier.height(16.dp))

                        FlowRow(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            categories.forEach { categoria ->
                                val isSelected = selectedCategories.contains(categoria.id)
                                val nomeFormattato = categoria.nome.name
                                    .replace("_", " ")
                                    .lowercase()
                                    .replaceFirstChar { it.uppercase() }

                                Surface(
                                    onClick = { viewModel.toggleCategory(categoria.id) },
                                    shape = RoundedCornerShape(16.dp),
                                    border = if (!isSelected) BorderStroke(1.dp, Color.Black) else null,
                                    color = if (isSelected) MaterialTheme.colorScheme.primary else Color.White
                                ) {
                                    Text(
                                        text = nomeFormattato,
                                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                                        color = if (isSelected) Color.White else Color.Black
                                    )
                                }
                            }
                        }

                        Spacer(modifier = Modifier.height(24.dp))

                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                            Button(
                                onClick = { viewModel.updatePreferences() },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = Color.Blue,
                                    contentColor = Color.White
                                )
                            ) {
                                Text("Aggiorna Preferenze")
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(32.dp))
            }

            if (isLoading) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }
        }
    }
}