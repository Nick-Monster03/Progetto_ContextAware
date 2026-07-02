package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.EventoCreate
import com.example.myapplication.data.model.EventoPublic
import com.example.myapplication.data.model.EventoUpdate
import retrofit2.http.*

interface EventoApi {

    @POST("eventi/")
    suspend fun createEvento(@Body eventoIn: EventoCreate): EventoPublic

    @GET("eventi/{evento_id}")
    suspend fun getEvento(@Path("evento_id") eventoId: Int): EventoPublic

    @GET("eventi/utente/{id_utente}")
    suspend fun getEventiByUtente(@Path("id_utente") idUtente: Int): List<EventoPublic>

    @PATCH("eventi/{evento_id}")
    suspend fun updateEvento(
        @Path("evento_id") eventoId: Int,
        @Body eventoIn: EventoUpdate
    ): EventoPublic

    @DELETE("eventi/{evento_id}")
    suspend fun deleteEvento(@Path("evento_id") eventoId: Int): Unit
}