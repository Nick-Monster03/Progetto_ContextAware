package com.example.myapplication.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class FeedbackEvento {
    @SerialName("Utile")
    UTILE,

    @SerialName("Non Utile")
    NON_UTILE
}