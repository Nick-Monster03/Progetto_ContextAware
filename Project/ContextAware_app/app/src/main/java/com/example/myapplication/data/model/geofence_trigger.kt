package com.example.myapplication.data.model

import kotlinx.serialization.Serializable

@Serializable
data class GeofenceTriggerRequest(
    val id_utente: Int,
    val id_poi: Int,
    val lat: Double,
    val lon: Double,
    val is_enter: Boolean
)

@Serializable
data class GeofenceConfigResponse(
    val poi: POIPublic,
    val raggio: Double,
    val motivo: String
)