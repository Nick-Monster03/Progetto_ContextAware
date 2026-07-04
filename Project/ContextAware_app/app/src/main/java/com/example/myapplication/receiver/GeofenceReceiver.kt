package com.example.myapplication.receiver

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.example.myapplication.R
import com.example.myapplication.data.model.GeofenceTriggerRequest
import com.example.myapplication.data.remote.api.GeofenceApi
import com.example.myapplication.utils.ApiClient
import com.google.android.gms.location.Geofence
import com.google.android.gms.location.GeofencingEvent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class GeofenceReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val geofencingEvent = GeofencingEvent.fromIntent(intent)
        if (geofencingEvent == null || geofencingEvent.hasError()) {
            Log.e("GeofenceReceiver", "Errore evento Geofence")
            return
        }

        val transitionType = geofencingEvent.geofenceTransition
        val triggeringGeofences = geofencingEvent.triggeringGeofences ?: return
        val triggeringLocation = geofencingEvent.triggeringLocation ?: return

        val isEnter = transitionType == Geofence.GEOFENCE_TRANSITION_ENTER

        triggeringGeofences.forEach { geofence ->
            val rawId = geofence.requestId
            val parts = rawId.split("_")

            if (parts.size == 2) {
                val poiId = parts[0].toIntOrNull()
                val userId = parts[1].toIntOrNull()

                if (poiId != null && userId != null) {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val api = ApiClient.retrofit.create(GeofenceApi::class.java)
                            val request = GeofenceTriggerRequest(
                                id_utente = userId,
                                id_poi = poiId,
                                lat = triggeringLocation.latitude,
                                lon = triggeringLocation.longitude,
                                is_enter = isEnter
                            )
                            val evento = api.triggerGeofence(request)
                            showNotification(context, evento.messaggio ?: "Area raggiunta!")
                            Log.d("GeofenceReceiver", "Successo: ${evento.messaggio}")

                        } catch (e: Exception) {
                            Log.e("GeofenceReceiver", "Errore API Trigger Geofence: ${e.message}")
                        }
                    }
                }
            }
        }
    }

    private fun showNotification(context: Context, message: String) {
        val channelId = "geofence_channel"
        val channelName = "Avvisi Luoghi (Geofence)"
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH)
            manager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setContentTitle("Suggerimento nelle vicinanze")
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setSmallIcon(R.drawable.outline_add_2_24)
            .setAutoCancel(true)
            .build()

        manager.notify(System.currentTimeMillis().toInt(), notification)
    }
}