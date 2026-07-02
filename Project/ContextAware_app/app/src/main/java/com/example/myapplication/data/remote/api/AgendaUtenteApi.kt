package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.AgendaUtenteContext
import com.example.myapplication.data.model.AgendaUtenteCreate
import com.example.myapplication.data.model.AgendaUtentePublic
import com.example.myapplication.data.model.AgendaUtenteUpdate
import retrofit2.http.*

interface AgendaUtenteApi {

    @POST("agenda/")
    suspend fun createImpegno(@Body impegnoIn: AgendaUtenteCreate): AgendaUtentePublic

    @GET("agenda/utente/{id_utente}")
    suspend fun getAgendaUtente(
        @Path("id_utente") idUtente: Int,
        @Query("solo_futuri") soloFuturi: Boolean = false
    ): List<AgendaUtentePublic>

    @GET("agenda/utente/{id_utente}/critici")
    suspend fun getImpegniCritici(
        @Path("id_utente") idUtente: Int,
        @Query("lat") lat: Double,
        @Query("lon") lon: Double
    ): List<AgendaUtenteContext>

    @GET("agenda/{impegno_id}")
    suspend fun getImpegno(@Path("impegno_id") impegnoId: Int): AgendaUtentePublic

    @PATCH("agenda/{impegno_id}")
    suspend fun updateImpegno(
        @Path("impegno_id") impegnoId: Int,
        @Body impegnoIn: AgendaUtenteUpdate
    ): AgendaUtentePublic

    @DELETE("agenda/{impegno_id}")
    suspend fun deleteImpegno(@Path("impegno_id") impegnoId: Int): Unit
}