package com.example.myapplication.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class TipoEvento {
    @SerialName("Avviso_agenda")
    AVVISO_AGENDA,

    @SerialName("Suggerimento")
    SUGGERIMENTO,

    @SerialName("poi_selezionato")
    POI_SELEZIONATO,

    @SerialName("geofencing_enter")
    GEOFENCING_ENTER,

    @SerialName("geofencing_exit")
    GEOFENCING_EXIT
}
