package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.EventoPublic
import com.example.myapplication.data.model.GeofenceConfigResponse
import com.example.myapplication.data.model.GeofenceTriggerRequest
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path

interface GeofenceApi {

    @POST("geofence/trigger")
    suspend fun triggerGeofence(
        @Body request: GeofenceTriggerRequest
    ): EventoPublic

    @GET("geofence/config/{id_utente}")
    suspend fun getGeofenceConfig(
        @Path("id_utente") idUtente: Int
    ): List<GeofenceConfigResponse>
}