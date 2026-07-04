package com.example.myapplication.ui.storico

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.example.myapplication.data.model.EventoPublic
import com.example.myapplication.data.model.FeedbackEvento
import com.example.myapplication.ui.storico.StoricoViewModel
import com.example.myapplication.R

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StoricoView(viewModel: StoricoViewModel) {
    val eventi by viewModel.eventi.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Storico Notifiche") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { paddingValues ->
        if (isLoading) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator()
            }
        } else if (eventi.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("Nessun evento registrato.")
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
                items(eventi, key = { it.id }) { evento ->
                    EventoCard(evento = evento, onFeedback = { feedback ->
                        viewModel.submitFeedback(evento.id, feedback)
                    })
                }
            }
        }
    }
}

@Composable
fun EventoCard(evento: EventoPublic, onFeedback: (FeedbackEvento) -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.medium,
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = evento.tipo.name ?: "Evento Sconosciuto",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(4.dp))


            Text(
                text = evento.messaggio ?: "Nessun messaggio",
                style = MaterialTheme.typography.bodyLarge
            )

            if (!evento.motivo.isNullOrBlank()) {
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Motivo: ${evento.motivo}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(12.dp))
            Divider(color = MaterialTheme.colorScheme.surfaceVariant)

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp),
                horizontalArrangement = Arrangement.End,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = if (evento.feedback != null) "Feedback registrato" else "È stato utile?",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.weight(1f)
                )

                IconButton(onClick = { onFeedback(FeedbackEvento.UTILE) }) {
                    Icon(
                        painter = painterResource(id = R.drawable.outline_check_24),
                        contentDescription = "Utile",
                        tint = if (evento.feedback == FeedbackEvento.UTILE) Color.Green else MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                IconButton(onClick = { onFeedback(FeedbackEvento.NON_UTILE) }) {
                    Icon(
                        painter = painterResource(id = R.drawable.outline_close_24),
                        contentDescription = "Non Utile",
                        tint = if (evento.feedback == FeedbackEvento.NON_UTILE) Color.Red else MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }
}