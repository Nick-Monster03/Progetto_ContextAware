package com.example.myapplication.data.repository

import com.example.myapplication.data.model.EventoPublic
import com.example.myapplication.data.remote.api.RaccomandationApi
import com.example.myapplication.data.model.RankingResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class RaccomandationRepository(private val api: RaccomandationApi) {

    suspend fun getRanking(idUtente: Int, lat: Double, lon: Double): Result<List<RankingResult>> {
        return withContext(Dispatchers.IO) {
            try {
                val response = api.getRanking(idUtente, lat, lon)
                if (response.isSuccessful) {
                    Result.success(response.body() ?: emptyList())
                } else {
                    Result.failure(Exception("Errore API Ranking: ${response.code()} - ${response.message()}"))
                }
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }

    suspend fun generateStartupSuggestion(idUtente: Int, lat: Double, lon: Double): Result<EventoPublic> {
        return withContext(Dispatchers.IO) {
            try {
                val response = api.generateStartupSuggestion(idUtente, lat, lon)
                val body = response.body()

                if (response.isSuccessful && body != null) {
                    Result.success(body)
                } else {
                    Result.failure(Exception("Errore API Suggerimento: ${response.code()} - ${response.message()}"))
                }
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
}