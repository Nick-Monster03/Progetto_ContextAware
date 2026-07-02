package com.example.myapplication.data.model

import kotlinx.serialization.Serializable

@Serializable
data class StatisticaMezzo(
    val mezzo_di_spostamento: String,
    val conteggio: Int
)

@Serializable
data class StatisticaFeedback(
    val is_utile: Boolean,
    val conteggio: Int
)

@Serializable
data class HeatmapPoint(
    val lat: Double,
    val lon: Double
)

@Serializable
data class StatisticaPOI(
    val id_poi: Int,
    val nome_poi: String,
    val totale_eventi: Int
)

@Serializable
data class DashboardResponse(
    val statistiche_mezzi: List<StatisticaMezzo>,
    val statistiche_feedback: List<StatisticaFeedback>,
    val poi_piu_attivi: List<StatisticaPOI>
)