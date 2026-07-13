package com.example.myapplication.utils

import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import com.example.myapplication.data.model.GeofenceConfigResponse
import com.example.myapplication.data.remote.api.GeofenceApi
import com.example.myapplication.data.repository.GeofenceRepository
import com.example.myapplication.receiver.GeofenceReceiver
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingClient
import com.google.android.gms.location.GeofencingRequest
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class GeofenceManager(private val context: Context) {

    private val geofencingClient: GeofencingClient = LocationServices.getGeofencingClient(context)

    private val geofencePendingIntent: PendingIntent by lazy {
        val intent = Intent(context, GeofenceReceiver::class.java)
        PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        )
    }

    //Ottiene i geofence in base alle preferenze dell'utente facendo la chiamta al backend
    fun setupGeofencesFromBackend(userId: Int) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                Log.d("GeofenceManager", "Richiesta configurazioni Geofence per utente $userId...")
                val api = ApiClient.retrofit.create(GeofenceApi::class.java)
                val configs = api.getGeofenceConfig(userId)

                if (configs.isNotEmpty()) {
                    registerGeofences(configs, userId)
                } else {
                    Log.d("GeofenceManager", "Nessun geofence da registrare per l'utente $userId")
                }
            } catch (e: Exception) {
                Log.e("GeofenceManager", "Errore recupero configurazioni: ${e.message}")
            }
        }
    }

//Funzione per la registrazione dei geofence passati tra la lista di GeofenceConfigResponse, viene chiamata da setupGeofencesFromBackend
    @SuppressLint("MissingPermission")
    private fun registerGeofences(configs: List<GeofenceConfigResponse>, userId: Int) {

        val geofenceList = configs.mapNotNull { config ->
            try {
                val centerPoint =
                    config.poi.geometria.getCenterForGeofence() ?: return@mapNotNull null

                Geofence.Builder()
                    .setRequestId("${config.poi.id}_$userId")
                    .setCircularRegion(centerPoint.first, centerPoint.second, config.raggio.toFloat()) //raggio di 10m asseganto dal backend
                    .setExpirationDuration(Geofence.NEVER_EXPIRE)
                    .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER or Geofence.GEOFENCE_TRANSITION_EXIT)
                    .build()
            } catch (e: Exception) {
                null
            }
        }

        if (geofenceList.isEmpty()) return

        val request = GeofencingRequest.Builder()
            .setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER)
            .addGeofences(geofenceList)
            .build()

        geofencingClient.addGeofences(request, geofencePendingIntent)
            .addOnSuccessListener {
                Log.d("GeofenceManager", "Registrati con successo ${geofenceList.size} Geofences:")
                //DEBUG
                //geofenceList.forEach { geofence ->
                //    Log.d("GeofenceManager", "Geofence ID: ${geofence.requestId}")
                //}
            }
            .addOnFailureListener {
                Log.e("GeofenceManager", "Errore durante la registrazione dei Geofence: ${it.message}")
            }
    }
}