package com.example.myapplication.data.model

import kotlinx.serialization.Serializable

@Serializable
data class OrariPoiCreate(
    val id_poi: Int,
    val giorno: Int, // 0 (Domenica) a 6 (Sabato)
    val orario_apertura: String,
    val orario_chiusura: String
)

@Serializable
data class OrariPoiPublic(
    val id: Int,
    val id_poi: Int,
    val giorno: Int,
    val orario_apertura: String,
    val orario_chiusura: String
)

@Serializable
data class OrariPoiUpdate(
    val giorno: Int? = null,
    val orario_apertura: String? = null,
    val orario_chiusura: String? = null
)