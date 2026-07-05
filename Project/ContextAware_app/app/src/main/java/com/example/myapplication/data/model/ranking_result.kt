package com.example.myapplication.data.model

import kotlinx.serialization.Serializable

@Serializable
class RankingResult(
    val poi: POIPublic,
    val punteggio: Double
)