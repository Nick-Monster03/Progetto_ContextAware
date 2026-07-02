package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.OrariPoiPublic
import com.example.myapplication.data.model.POICreate
import com.example.myapplication.data.model.POIDistance
import com.example.myapplication.data.model.POIPublic
import com.example.myapplication.data.model.POIUpdate
import retrofit2.http.*

interface PoiApi {

    @POST("poi/")
    suspend fun createPoi(@Body poi: POICreate): POIPublic

    @GET("poi/")
    suspend fun getAllPois(): List<POIPublic>

    @GET("poi/nearby")
    suspend fun getPoisNearby(
        @Query("lat") lat: Double,
        @Query("lon") lon: Double,
        @Query("radius") radius: Double = 2000.0
    ): List<POIPublic>

    @GET("poi/nearby-with-distance")
    suspend fun getPoisNearbyWithDistance(
        @Query("lat") lat: Double,
        @Query("lon") lon: Double,
        @Query("radius") radius: Double = 2000.0
    ): List<POIDistance>

    @GET("poi/filter")
    suspend fun getFilteredPois(
        @Query("lat") lat: Double? = null,
        @Query("lon") lon: Double? = null,
        @Query("id_categoria") idCategoria: Int? = null,
        @Query("max_distance_meters") maxDistanceMeters: Double? = null,
        @Query("orario_apertura") orarioApertura: String? = null,
        @Query("orario_chiusura") orarioChiusura: String? = null,
        @Query("mezzo_spostamento") mezzoSpostamento: String? = null,
        @Query("campus") campus: String? = null
    ): List<POIPublic>

    @GET("poi/{poi_id}")
    suspend fun getPoiById(@Path("poi_id") poiId: Int): POIPublic

    @PATCH("poi/{poi_id}")
    suspend fun updatePoi(
        @Path("poi_id") poiId: Int,
        @Body poiIn: POIUpdate
    ): POIPublic

    @DELETE("poi/{poi_id}")
    suspend fun deletePoi(@Path("poi_id") poiId: Int): POIPublic

    @GET("poi/categoria/{id_categoria}")
    suspend fun getPoisByCategoria(@Path("id_categoria") idCategoria: Int): List<POIPublic>

    @GET("poi/{poi_id}/orari")
    suspend fun getOrariPoi(@Path("poi_id") poiId: Int): List<OrariPoiPublic>

    @GET("poi/{poi_id}/is-open")
    suspend fun checkPoiIsOpen(@Path("poi_id") poiId: Int): Boolean
}