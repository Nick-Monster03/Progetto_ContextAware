package com.example.myapplication.data.model

import kotlinx.serialization.Serializable

@Serializable
data class EventoCreate(
    val id_utente: Int,
    val id_poi: Int? = null,
    val tipo: TipoEvento = TipoEvento.SUGGERIMENTO,
    val messaggio: String? = null,
    val feedback: FeedbackEvento? = FeedbackEvento.NON_UTILE,
    val motivo: String? = null,
    val latitudine: Double,
    val longitudine: Double
)

@Serializable
data class EventoUpdate(
    val feedback: FeedbackEvento? = FeedbackEvento.UTILE,
    val motivo: String? = null
)

@Serializable
data class EventoPublic(
    val id: Int,
    val id_utente: Int,
    val id_poi: Int? = null,
    val tipo: TipoEvento = TipoEvento.SUGGERIMENTO,
    val messaggio: String? = null,
    val feedback: FeedbackEvento? = FeedbackEvento.NON_UTILE,
    val motivo: String? = null,
    val time_stamp: String,
    val latitudine: Double,
    val longitudine: Double
)