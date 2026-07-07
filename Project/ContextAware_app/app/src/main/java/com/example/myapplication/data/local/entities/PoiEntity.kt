package com.example.myapplication.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.ForeignKey
import androidx.room.Index

@Entity(
    tableName = "poi_table",
    foreignKeys = [
        ForeignKey(
            entity = CategoriaEntity::class,
            parentColumns = ["id"],
            childColumns = ["id_categoria"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("id_categoria")]
)
data class PoiEntity(
    @PrimaryKey val id: Int,
    val nome: String,
    val id_categoria: Int,
    val descrizione: String?,
    val geometriaStr: String, // Salveremo il JsonElement come stringa
    val campus: String
)