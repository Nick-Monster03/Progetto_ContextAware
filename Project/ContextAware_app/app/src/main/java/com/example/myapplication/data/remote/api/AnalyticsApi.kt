package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.DashboardResponse
import com.example.myapplication.data.model.HeatmapPoint
import com.example.myapplication.data.model.StatisticaFeedback
import com.example.myapplication.data.model.StatisticaMezzo
import com.example.myapplication.data.model.StatisticaPOI
import retrofit2.http.GET
import retrofit2.http.Query

interface AnalyticsApi {

    @GET("analytics/mezzi")
    suspend fun getStatisticheMezzi(): List<StatisticaMezzo>

    @GET("analytics/feedback")
    suspend fun getStatisticheFeedback(): List<StatisticaFeedback>

    @GET("analytics/poi")
    suspend fun getStatistichePoi(): List<StatisticaPOI>

    @GET("analytics/dashboard")
    suspend fun getDashboardCompleta(): DashboardResponse

    @GET("analytics/heatmap/pois")
    suspend fun getPoiHeatmap(
        @Query("id_utente") idUtente: Int? = null
    ): List<HeatmapPoint>
}