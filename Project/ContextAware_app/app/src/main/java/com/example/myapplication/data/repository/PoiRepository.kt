package com.example.myapplication.data.repository

import com.example.myapplication.data.model.OrariPoiPublic
import com.example.myapplication.data.model.POICreate
import com.example.myapplication.data.model.POIDistance
import com.example.myapplication.data.model.POIPublic
import com.example.myapplication.data.model.POIUpdate
import com.example.myapplication.data.remote.api.PoiApi

class PoiRepository(private val api: PoiApi) {

    suspend fun createPoi(poi: POICreate): Result<POIPublic> {
        return try {
            val response = api.createPoi(poi)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getAllPois(): Result<List<POIPublic>> {
        return try {
            val response = api.getAllPois()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getPoisNearby(lat: Double, lon: Double, radius: Double = 2000.0): Result<List<POIPublic>> {
        return try {
            val response = api.getPoisNearby(lat, lon, radius)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getPoisNearbyWithDistance(lat: Double, lon: Double, radius: Double = 2000.0): Result<List<POIDistance>> {
        return try {
            val response = api.getPoisNearbyWithDistance(lat, lon, radius)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getFilteredPois(
        lat: Double? = null,
        lon: Double? = null,
        idCategoria: Int? = null,
        maxDistanceMeters: Double? = null,
        orarioApertura: String? = null,
        orarioChiusura: String? = null,
        mezzoSpostamento: String? = null,
        campus: String? = null
    ): Result<List<POIPublic>> {
        return try {
            val response = api.getFilteredPois(
                lat, lon, idCategoria, maxDistanceMeters,
                orarioApertura, orarioChiusura, mezzoSpostamento, campus
            )
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getPoiById(poiId: Int): Result<POIPublic> {
        return try {
            val response = api.getPoiById(poiId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updatePoi(poiId: Int, poiIn: POIUpdate): Result<POIPublic> {
        return try {
            val response = api.updatePoi(poiId, poiIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deletePoi(poiId: Int): Result<POIPublic> {
        return try {
            val response = api.deletePoi(poiId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getPoisByCategoria(idCategoria: Int): Result<List<POIPublic>> {
        return try {
            val response = api.getPoisByCategoria(idCategoria)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getOrariPoi(poiId: Int): Result<List<OrariPoiPublic>> {
        return try {
            val response = api.getOrariPoi(poiId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun checkPoiIsOpen(poiId: Int): Result<Boolean> {
        return try {
            val response = api.checkPoiIsOpen(poiId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}