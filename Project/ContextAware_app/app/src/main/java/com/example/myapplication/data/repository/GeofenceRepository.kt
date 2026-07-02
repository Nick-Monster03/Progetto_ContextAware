package com.example.myapplication.data.repository

import com.example.myapplication.data.model.EventoPublic
import com.example.myapplication.data.model.GeofenceConfigResponse
import com.example.myapplication.data.model.GeofenceTriggerRequest
import com.example.myapplication.data.remote.api.GeofenceApi

class GeofenceRepository(private val api: GeofenceApi) {

    suspend fun triggerGeofence(request: GeofenceTriggerRequest): Result<EventoPublic> {
        return try {
            val response = api.triggerGeofence(request)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getGeofenceConfig(idUtente: Int): Result<List<GeofenceConfigResponse>> {
        return try {
            val response = api.getGeofenceConfig(idUtente)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}