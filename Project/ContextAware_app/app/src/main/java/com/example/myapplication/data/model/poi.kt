package com.example.myapplication.data.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
data class POIPublic(
    val id: Int,
    val nome: String,
    val id_categoria: Int,
    val descrizione: String? = null,
    val geometria: JsonElement, // Gestisce l'oggetto GeoJSON (Point, Polygon, ecc.) proveniente da PostGIS
    val campus: String = "Bologna"
)

@Serializable
data class POICreate(
    val nome: String,
    val id_categoria: Int,
    val descrizione: String? = null,
    val geometria: JsonElement,
    val campus: String = "Bologna"
)

@Serializable
data class POIUpdate(
    val nome: String? = null,
    val id_categoria: Int? = null,
    val descrizione: String? = null,
    val geometria: JsonElement? = null,
    val campus: String? = null
)

@Serializable
data class POIDistance(
    val id: Int,
    val nome: String,
    val id_categoria: Int,
    val descrizione: String? = null,
    val geometria: JsonElement,
    val campus: String,
    val distance: Double // Distanza espressa in metri o km a seconda del backend
)
/*
@Serializable
data class OrariPoiPublic(
    val id: Int,
    val id_poi: Int,
    val giorno: Int,
    val orario_apertura: String, // Formato "HH:MM:SS"
    val orario_chiusura: String
)*/