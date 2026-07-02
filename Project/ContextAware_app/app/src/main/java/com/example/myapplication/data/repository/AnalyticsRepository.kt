package com.example.myapplication.data.repository

import com.example.myapplication.data.model.DashboardResponse
import com.example.myapplication.data.model.HeatmapPoint
import com.example.myapplication.data.model.StatisticaFeedback
import com.example.myapplication.data.model.StatisticaMezzo
import com.example.myapplication.data.model.StatisticaPOI
import com.example.myapplication.data.remote.api.AnalyticsApi

class AnalyticsRepository(private val api: AnalyticsApi) {

    suspend fun getStatisticheMezzi(): Result<List<StatisticaMezzo>> {
        return try {
            val response = api.getStatisticheMezzi()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getStatisticheFeedback(): Result<List<StatisticaFeedback>> {
        return try {
            val response = api.getStatisticheFeedback()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getStatistichePoi(): Result<List<StatisticaPOI>> {
        return try {
            val response = api.getStatistichePoi()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getDashboardCompleta(): Result<DashboardResponse> {
        return try {
            val response = api.getDashboardCompleta()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getPoiHeatmap(idUtente: Int? = null): Result<List<HeatmapPoint>> {
        return try {
            val response = api.getPoiHeatmap(idUtente)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}