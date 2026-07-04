package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.EventoPublic
import com.example.myapplication.data.model.RankingResult
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query

interface RaccomandationApi {

    @GET("raccomandation/ranking")
    suspend fun getRanking(
        @Query("id_utente") idUtente: Int,
        @Query("lat") lat: Double,
        @Query("lon") lon: Double
    ): Response<List<RankingResult>>

    @POST("recommendations/startup-suggestion")
    suspend fun generateStartupSuggestion(
        @Query("id_utente") idUtente: Int,
        @Query("lat") lat: Double,
        @Query("lon") lon: Double
    ): Response<EventoPublic>
}