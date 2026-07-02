package com.example.myapplication.data.model
import kotlinx.serialization.Serializable

@Serializable
data class UtentePublic(
    val id: Int,
    val nome: String,
    val cognome: String,
    val campus: String? = null,
    val mezzoDiSpostamento: MezzoSpostamento? = MezzoSpostamento.A_PIEDI
)

@Serializable
data class UtenteCreate(
    val nome: String,
    val cognome: String,
    val campus: String? = null,
    val mezzoDiSpostamento: MezzoSpostamento? = MezzoSpostamento.A_PIEDI,
    val password: String
)


@Serializable
data class UtenteUpdate(
    val nome: String? = null,
    val cognome: String? = null,
    val campus: String? = null,
    val mezzoDiSpostamento: MezzoSpostamento? = null
)
