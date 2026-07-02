package com.example.myapplication.data.model

import kotlinx.serialization.Serializable

@Serializable
data class CategoriaPOICreate(
    val nome: NomeCategoria
)

@Serializable
data class CategoriaPOIPublic(
    val id: Int,
    val nome: NomeCategoria
)

@Serializable
data class CategoriaPOIUpdate(
    val nome: NomeCategoria? = null
)