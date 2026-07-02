package com.example.myapplication.utils

import android.graphics.Color
import android.util.Log
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.double
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker
import org.osmdroid.views.overlay.Polygon

private const val TAG = "GeoJsonHelper"

data class PolygonStyle(
    val fillColor: Int = Color.argb(75, 0, 150, 255),
    val strokeColor: Int = Color.BLUE,
    val strokeWidth: Float = 3f
)

private val defaultPolygonStyle = PolygonStyle()
private val multiPolygonStyle = PolygonStyle(
    fillColor = Color.argb(75, 255, 100, 0),
    strokeColor = Color.RED,
    strokeWidth = 3f
)

fun addGeoJsonToMap(
    mapView: MapView,
    poiId: Int,
    nome: String,
    descrizione: String?,
    jsonElement: JsonElement,
    polygonStyle: PolygonStyle = defaultPolygonStyle
): List<Any> {
    val addedOverlays = mutableListOf<Any>()

    try {
        val jsonObj = jsonElement.jsonObject
        val type = jsonObj["type"]?.jsonPrimitive?.content
        val coordinates = jsonObj["coordinates"]?.jsonArray

        if (coordinates == null) {
            Log.w(TAG, "POI $poiId ($nome): geometria senza 'coordinates', skip")
            return addedOverlays
        }

        when (type) {
            "Point" -> {
                createMarker(mapView, coordinates, nome, descrizione)?.let {
                    mapView.overlays.add(it)
                    addedOverlays.add(it)
                }
            }

            "Polygon" -> {
                createPolygon(mapView, coordinates, nome, descrizione, polygonStyle)?.let {
                    mapView.overlays.add(it)
                    addedOverlays.add(it)
                }
            }

            "MultiPolygon" -> {
                coordinates.forEach { polygonCoords ->
                    createPolygon(mapView, polygonCoords.jsonArray, nome, descrizione, multiPolygonStyle)?.let {
                        mapView.overlays.add(it)
                        addedOverlays.add(it)
                    }
                }
            }

            else -> Log.w(TAG, "POI $poiId ($nome): tipo geometria non gestito '$type'")
        }
    } catch (e: Exception) {
        Log.e(TAG, "Errore nel parsing GeoJSON per POI $poiId ($nome)", e)
    }

    return addedOverlays
}

private fun JsonElement.toGeoPoint(): GeoPoint {
    val coords = this.jsonArray
    val lon = coords[0].jsonPrimitive.double
    val lat = coords[1].jsonPrimitive.double
    return GeoPoint(lat, lon)
}

private fun JsonArray.toGeoPoints(): List<GeoPoint> = this.map { it.toGeoPoint() }

private fun createMarker(
    mapView: MapView,
    coordinates: JsonArray,
    nome: String,
    descrizione: String?
): Marker? {
    if (coordinates.size < 2) return null
    return Marker(mapView).apply {
        position = coordinates.toGeoPoint()
        title = nome
        snippet = descrizione
    }
}

private fun createPolygon(
    mapView: MapView,
    coordinates: JsonArray,
    nome: String,
    descrizione: String?,
    style: PolygonStyle
): Polygon? {
    if (coordinates.isEmpty()) return null

    val outerRing = coordinates[0].jsonArray.toGeoPoints()

    return Polygon(mapView).apply {
        points = outerRing
        title = nome
        snippet = descrizione
        fillPaint.color = style.fillColor
        outlinePaint.color = style.strokeColor
        outlinePaint.strokeWidth = style.strokeWidth

        if (coordinates.size > 1) {
            holes = (1 until coordinates.size).map { i ->
                coordinates[i].jsonArray.toGeoPoints()
            }
        }
    }
}