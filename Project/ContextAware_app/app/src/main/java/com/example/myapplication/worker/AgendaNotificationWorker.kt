package com.example.myapplication.worker

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.myapplication.MainActivity
import com.example.myapplication.R
import com.example.myapplication.data.local.ContextAwareDatabase
import com.example.myapplication.data.model.EventoCreate
import com.example.myapplication.data.model.TipoEvento
import com.example.myapplication.data.remote.api.AgendaUtenteApi
import com.example.myapplication.data.remote.api.EventoApi
import com.example.myapplication.data.repository.AgendaUtenteRepository
import com.example.myapplication.data.repository.EventoRepository
import com.example.myapplication.utils.ApiClient
import com.example.myapplication.utils.SessionManager
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.tasks.await

// IMPORT DA AGGIUNGERE (Verifica che i percorsi siano corretti per il tuo progetto)
// import com.example.myapplication.data.model.EventoCreate
// import com.example.myapplication.data.model.TipoEvento
// import com.example.myapplication.data.repository.EventoRepository
// import com.example.myapplication.data.remote.api.EventoApi

class AgendaNotificationWorker(
    private val appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {
        //Log.d("AGENDA_WORKER", "Worker avviato - controllo impegni critici tramite Repository")

        val sessionManager = SessionManager(appContext)
        val user = sessionManager.loggedUser.first()

        if (user == null) {
            return Result.success()
        }

        val database = ContextAwareDatabase.getDatabase(appContext)
        val agendaApi = ApiClient.retrofit.create(AgendaUtenteApi::class.java)
        val agendaRepo = AgendaUtenteRepository(agendaApi, database.agendaUtenteDao())

        val eventoApi = ApiClient.retrofit.create(EventoApi::class.java)
        val eventoRepo = EventoRepository(eventoApi)

        var lat = 0.0
        var lon = 0.0

        if (ActivityCompat.checkSelfPermission(appContext, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
            ActivityCompat.checkSelfPermission(appContext, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            try {
                val fusedLocationClient = LocationServices.getFusedLocationProviderClient(appContext)
                val location = fusedLocationClient.lastLocation.await()
                if (location != null) {
                    lat = location.latitude
                    lon = location.longitude
                } else {
                    return Result.success()
                }
            } catch (e: Exception) {
                return Result.success()
            }
        } else {
            //Log.d("AGENDA_WORKER", "Permessi di localizzazione mancanti, impossibile proseguire.")
            return Result.success()
        }

        val result = agendaRepo.getImpegniCritici(user.id, lat, lon)

        result.onSuccess { impegniCritici ->
            impegniCritici.forEach { impegnoContext ->
                showNotification(impegnoContext.id, "Attenzione: Impegno Imminente!", impegnoContext.avviso)

                val nuovoEvento = EventoCreate(
                    id_utente = user.id,
                    id_poi = impegnoContext.id_poi,
                    tipo = TipoEvento.AVVISO_AGENDA,
                    messaggio = "Inviata notifica per l'evento: ${impegnoContext.titolo}",
                    motivo = "Impegno in agenda entro 15 minuti",
                    latitudine = lat,
                    longitudine = lon
                )

                eventoRepo.createEvento(nuovoEvento).fold(
                    onSuccess = { Log.d("AGENDA_WORKER", "Evento notifica salvato con successo: ${impegnoContext.titolo}") },
                    onFailure = { Log.e("AGENDA_WORKER", "Errore salvataggio evento notifica: ${it.message}") }
                )

            }
        }.onFailure { error ->
            Log.e("AGENDA_WORKER", "Errore nel recupero degli impegni critici: ${error.message}")
        }

        return Result.success()
    }

    private fun showNotification(notificaId: Int, titolo: String, message: String) {
        val channelId = "agenda_channel"
        val notificationManager = appContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Avvisi Agenda",
                NotificationManager.IMPORTANCE_HIGH
            )
            notificationManager.createNotificationChannel(channel)
        }

        val intent = Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            appContext, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(appContext, channelId)
            .setContentTitle(titolo)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setSmallIcon(R.drawable.outline_attach_file_24)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        notificationManager.notify(notificaId, builder.build())
    }
}