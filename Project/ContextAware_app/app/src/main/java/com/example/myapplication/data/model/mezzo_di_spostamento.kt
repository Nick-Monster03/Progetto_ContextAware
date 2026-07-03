package com.example.myapplication.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable


@Serializable
enum class MezzoSpostamento(val dbValue: String) {
    @SerialName("A PIEDI")
    A_PIEDI("A PIEDI"),
    @SerialName("BICI A NOLEGGIO")
    BICI_A_NOLEGGIO("BICI A NOLEGGIO"),
    AUTOBUS("AUTOBUS"),
    TRENO("TRENO"),
    MOTO("MOTO"),
    AUTO("AUTO"),
    ALTRO("ALTRO")
}
