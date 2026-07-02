package com.example.myapplication.data.model

import kotlinx.serialization.Serializable


@Serializable
data class AgendaUtenteCreate(
    val id_utente: Int,
    val id_poi: Int,
    val titolo: String,
    val orario_inizio: String,
    val orario_fine: String
)

@Serializable
data class AgendaUtentePublic(
    val id: Int,
    val id_utente: Int,
    val id_poi: Int,
    val titolo: String,
    val orario_inizio: String,
    val orario_fine: String
)


@Serializable
data class AgendaUtenteUpdate(
    val id_poi: Int? = null,
    val titolo: String? = null,
    val orario_inizio: String? = null,
    val orario_fine: String? = null
)


@Serializable
data class AgendaUtenteContext(
    val id: Int,
    val id_utente: Int,
    val id_poi: Int,
    val titolo: String,
    val orario_inizio: String,
    val orario_fine: String,
    val distanza_metri: Double,
    val avviso: String
)