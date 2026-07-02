package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.OrariPoiCreate
import com.example.myapplication.data.model.OrariPoiPublic
import com.example.myapplication.data.model.OrariPoiUpdate
import retrofit2.http.*

interface OrariPoiApi {

    @POST("orari/")
    suspend fun createOrario(@Body orarioIn: OrariPoiCreate): OrariPoiPublic

    @GET("orari/{orario_id}")
    suspend fun getOrario(@Path("orario_id") orarioId: Int): OrariPoiPublic

    @GET("orari/poi/{id_poi}")
    suspend fun getOrariByPoi(@Path("id_poi") idPoi: Int): List<OrariPoiPublic>

    @PATCH("orari/{orario_id}")
    suspend fun updateOrario(
        @Path("orario_id") orarioId: Int,
        @Body orarioIn: OrariPoiUpdate
    ): OrariPoiPublic

    @DELETE("orari/{orario_id}")
    suspend fun deleteOrario(@Path("orario_id") orarioId: Int): Unit
}