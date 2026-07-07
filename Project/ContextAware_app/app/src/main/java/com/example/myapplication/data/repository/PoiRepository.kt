package com.example.myapplication.data.repository

import android.location.Location
import com.example.myapplication.data.local.dao.PoiDao
import com.example.myapplication.data.local.entities.PoiEntity
import com.example.myapplication.data.model.OrariPoiPublic
import com.example.myapplication.data.model.POICreate
import com.example.myapplication.data.model.POIDistance
import com.example.myapplication.data.model.POIPublic
import com.example.myapplication.data.model.POIUpdate
import com.example.myapplication.data.remote.api.PoiApi
import kotlinx.serialization.json.Json
import java.io.IOException

class PoiRepository(
    private val api: PoiApi,
    private val poiDao: PoiDao
) {

    suspend fun getAllPois(): Result<List<POIPublic>> {
        return try {
            val response = api.getAllPois()
            poiDao.insertAll(response.map { it.toEntity() })
            poiDao.insertAll(response.map { it.toEntity() })
            Result.success(response)
        } catch (e: IOException) {
            try {
                val cached = poiDao.getAllPois().map { it.toPoiPublic() }
                if (cached.isNotEmpty()) Result.success(cached) else Result.failure(e)
            } catch (dbError: Exception) {
                Result.failure(e)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getPoiById(poiId: Int): Result<POIPublic> {
        return try {
            val response = api.getPoiById(poiId)
            Result.success(response)
        } catch (e: IOException) {
            val cached = poiDao.getPoiById(poiId)?.toPoiPublic()
            if (cached != null) Result.success(cached) else Result.failure(e)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getPoisByCategoria(idCategoria: Int): Result<List<POIPublic>> {
        return try {
            val response = api.getPoisByCategoria(idCategoria)
            Result.success(response)
        } catch (e: IOException) {
            val cached = poiDao.getPoisByCategoria(idCategoria).map { it.toPoiPublic() }
            if (cached.isNotEmpty()) Result.success(cached) else Result.failure(e)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun searchPois(query: String, campus: String? = null): Result<List<POIPublic>> {
        return try {
            val response = api.searchPois(query = query, campus = campus)
            Result.success(response)
        } catch (e: IOException) {
            try {
                val cachedEntities = if (campus != null) {
                    poiDao.searchPoisByNameAndCampus(query, campus)
                } else {
                    poiDao.searchPoisByName(query)
                }
                val cached = cachedEntities.map { it.toPoiPublic() }
                if (cached.isNotEmpty()) Result.success(cached) else Result.failure(e)
            } catch (dbError: Exception) {
                Result.failure(e)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getFilteredPois(
        lat: Double? = null,
        lon: Double? = null,
        idCategoria: List<Int>? = null,
        maxDistanceMeters: Double? = null,
        orarioApertura: String? = null,
        orarioChiusura: String? = null,
        campus: String? = null
    ): Result<List<POIPublic>> {
        return try {
            val response = api.getFilteredPois(
                lat, lon, idCategoria, maxDistanceMeters,
                orarioApertura, orarioChiusura, campus
            )
            poiDao.insertAll(response.map { it.toEntity() })

            Result.success(response)
        } catch (e: IOException) {
            try {
                var cached = poiDao.getAllPois().map { it.toPoiPublic() }

                if (!idCategoria.isNullOrEmpty()) {
                    cached = cached.filter { it.id_categoria in idCategoria }
                }
                if (!campus.isNullOrEmpty()) {
                    cached = cached.filter { it.campus.equals(campus, ignoreCase = true) }
                }

                if (cached.isNotEmpty()) Result.success(cached) else Result.failure(e)
            } catch (dbError: Exception) {
                Result.failure(e)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createPoi(poi: POICreate): Result<POIPublic> {
        return try {
            val response = api.createPoi(poi)
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

    fun POIPublic.toEntity() = PoiEntity(
        id = this.id,
        nome = this.nome,
        id_categoria = this.id_categoria,
        descrizione = this.descrizione,
        geometriaStr = this.geometria.toString(),
        campus = this.campus
    )

    fun PoiEntity.toPoiPublic() = POIPublic(
        id = this.id,
        nome = this.nome,
        id_categoria = this.id_categoria,
        descrizione = this.descrizione,
        geometria = Json.parseToJsonElement(this.geometriaStr),
        campus = this.campus
    )
}