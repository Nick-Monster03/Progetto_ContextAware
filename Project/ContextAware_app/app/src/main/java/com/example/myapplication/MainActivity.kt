package com.example.myapplication

import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.annotation.RequiresApi
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.adaptive.navigationsuite.NavigationSuiteScaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.example.myapplication.ui.agenda.AgendaUtenteView
import com.example.myapplication.ui.agenda.AgendaUtenteViewModel
import com.example.myapplication.ui.map.MapView
import com.example.myapplication.ui.map.MapViewModel
import com.example.myapplication.ui.navigation.RootNavigation
import com.example.myapplication.ui.profile.ProfileView
import com.example.myapplication.ui.profile.ProfileViewModel
import com.example.myapplication.ui.storico.StoricoView
import com.example.myapplication.ui.storico.StoricoViewModel
import com.example.myapplication.ui.theme.MyApplicationTheme
import com.example.myapplication.worker.AgendaNotificationWorker
import java.util.concurrent.TimeUnit

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                RootNavigation()
            }
        }
        val agendaWorkRequest = PeriodicWorkRequestBuilder<AgendaNotificationWorker>(
            15, TimeUnit.MINUTES
        ).build()

        WorkManager.getInstance(applicationContext).enqueueUniquePeriodicWork(
            "AgendaNotificationWork",
            ExistingPeriodicWorkPolicy.KEEP,
            agendaWorkRequest
        )
    }
}

enum class AppDestinations(
    val label: String,
    val iconRes: Int
) {
    MAPPA("Mappa", R.drawable.baseline_map_24),
    AGENDA("Agenda", R.drawable.outline_attach_file_24),
    STORICO("Storico", R.drawable.outline_article_24),
    PROFILO("Profilo", R.drawable.outline_account_circle_24)
}

@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun MyApplicationApp() {
    var currentDestination by rememberSaveable { mutableStateOf(AppDestinations.MAPPA) }
    val context = LocalContext.current
    val mapViewModel: MapViewModel = viewModel(
        factory = MapViewModel.MapViewModelFactory(context)
    )
    val profileViewModel: ProfileViewModel = viewModel(
        factory = ProfileViewModel.ProfileViewModelFactory(context)
    )

    val storicoViewModel: StoricoViewModel = viewModel(
        factory = StoricoViewModel.StoricoViewModelFactory(context)
    )

    val agendaViewModel: AgendaUtenteViewModel = viewModel(
        factory = AgendaUtenteViewModel.AgendaViewModelFactory(context)
    )

    NavigationSuiteScaffold(
        navigationSuiteItems = {
            AppDestinations.entries.forEach {
                item(
                    icon = {
                        Icon(
                            painter = painterResource(id = it.iconRes),
                            contentDescription = it.label
                        )
                    },
                    label = { Text(it.label) },
                    selected = it == currentDestination,
                    onClick = { currentDestination = it }
                )
            }
        }
    ) {
        Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
            Box(modifier = Modifier.padding(innerPadding)) {
                when (currentDestination) {
                    AppDestinations.MAPPA -> MapView(viewModel = mapViewModel)

                    AppDestinations.AGENDA -> AgendaUtenteView(viewModel = agendaViewModel)
                    AppDestinations.STORICO -> StoricoView(viewModel = storicoViewModel)
                    AppDestinations.PROFILO -> ProfileView(viewModel = profileViewModel)
                }
            }
        }
    }
}

@Composable
fun MapScreenStub() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("Qui andrà la mappa con i POI e il Geo-fencing")
    }
}

@Composable
fun AgendaScreenStub() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("Qui andrà l'Agenda per i suggerimenti pre-lezione")
    }
}

@Composable
fun HistoryScreenStub() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("Qui andranno le preferenze utente (Campus, Mezzi, Categorie POI)")
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
fun ProfileScreenStub() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("Qui andranno le preferenze utente (Campus, Mezzi, Categorie POI)")
    }
}
