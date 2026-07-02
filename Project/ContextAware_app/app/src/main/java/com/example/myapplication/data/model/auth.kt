package com.example.myapplication.data.model

import kotlinx.serialization.Serializable

@Serializable
data class LoginRequest(
    val nome: String,
    val cognome: String,
    val password: String
)