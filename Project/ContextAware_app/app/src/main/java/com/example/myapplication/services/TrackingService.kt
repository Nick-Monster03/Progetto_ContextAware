package com.example.myapplication.services

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.lifecycle.LifecycleService
import com.example.myapplication.MainActivity
import com.example.myapplication.R
import com.example.myapplication.data.repository.LocationRepository
import com.example.myapplication.utils.GeofenceManager
import com.example.myapplication.utils.SessionManager
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class TrackingService : LifecycleService() {

    companion object {
        const val ACTION_START = "START_TRACKING"
        const val ACTION_STOP = "STOP_TRACKING"
        const val CHANNEL_ID = "tracking_channel"
        const val NOTIFICATION_ID = 101
    }

    private lateinit var fusedClient: FusedLocationProviderClient
    private var isTracking = false
    private var lastLocation: Location? = null

    override fun onCreate() {
        super.onCreate()
        fusedClient = LocationServices.getFusedLocationProviderClient(this)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        }

        // Inizializza i Geofence in background al lancio del servizio
        setupGeofencing()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        when (intent?.action) {
            ACTION_START -> {
                if (isTracking) return START_STICKY

                startForeground(NOTIFICATION_ID, buildNotification())
                startLocationUpdates()
            }
            ACTION_STOP -> {
                stopLocationUpdates()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()

                getSharedPreferences("campus_prefs", Context.MODE_PRIVATE)
                    .edit()
                    .putBoolean("tracking_running", false)
                    .apply()
            }
        }
        return START_STICKY
    }

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            if (!isTracking) return

            result.locations.forEach { location ->
                Log.d("TrackingService", "Posizione ricevuta: Lat ${location.latitude}, Lon ${location.longitude}")
                lastLocation = location
                LocationRepository.updateLocation(location)
            }
        }
    }

    private fun startLocationUpdates() {
        isTracking = true

        val request = LocationRequest.Builder(
            Priority.PRIORITY_HIGH_ACCURACY,
            15_000L
        ).apply {
            setMinUpdateIntervalMillis(10_000L)
            setMinUpdateDistanceMeters(10f)
        }.build()

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            fusedClient.requestLocationUpdates(request, locationCallback, Looper.getMainLooper())

            getSharedPreferences("campus_prefs", Context.MODE_PRIVATE)
                .edit()
                .putBoolean("tracking_running", true)
                .apply()
        }
    }

    private fun stopLocationUpdates() {
        if (isTracking) {
            fusedClient.removeLocationUpdates(locationCallback)
            LocationRepository.clearLocation()
            isTracking = false
        }
    }

    private fun buildNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Campus Assistant Attivo")
            .setContentText("Ricerca servizi e notifiche contestuali in esecuzione")
            .setSmallIcon(R.drawable.ic_favorite)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Servizio Campus Assistant",
            NotificationManager.IMPORTANCE_LOW
        )
        val manager = getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(channel)
    }

    private fun setupGeofencing() {
        val sessionManager = SessionManager(applicationContext)
        val geofenceManager = GeofenceManager(applicationContext)

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val user = sessionManager.loggedUser.first()
                if (user != null) {
                    Log.d("TrackingService", "Avvio setup Geofence per utente ${user.id}")
                    geofenceManager.setupGeofencesFromBackend(user.id)
                } else {
                    Log.w("TrackingService", "Nessun utente loggato, impossibile avviare i Geofence.")
                }
            } catch (e: Exception) {
                Log.e("TrackingService", "Errore critico durante l'avvio dei Geofence: ${e.message}")
            }
        }
    }

    override fun onDestroy() {
        stopLocationUpdates()
        super.onDestroy()
    }
}