package com.example.myapplication.data.model

import kotlinx.serialization.Serializable

@Serializable
data class PreferenzaUtenteCreate(
    val id_utente: Int,
    val id_categoria: Int
)

@Serializable
data class PreferenzaUtentePublic(
    val id_utente: Int,
    val id_categoria: Int
)

@Serializable
data class PreferenzaUtenteUpdate(
    val id_utente: Int? = null,
    val id_categoria: Int? = null
)