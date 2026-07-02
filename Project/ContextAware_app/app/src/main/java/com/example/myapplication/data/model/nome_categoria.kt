package com.example.myapplication.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class NomeCategoria {
    @SerialName("biblioteca")
    BIBLIOTECA,

    @SerialName("sala_studio")
    SALA_STUDIO,

    @SerialName("mensa")
    MENSA,

    @SerialName("ufficio")
    UFFICIO,

    @SerialName("segreteria")
    SEGRETERIA,

    @SerialName("fermata")
    FERMATA,

    @SerialName("noleggio_bici")
    NOLEGGIO_BICI,

    @SerialName("stazione")
    STAZIONE,

    @SerialName("benzinaio")
    BENZINAIO
}