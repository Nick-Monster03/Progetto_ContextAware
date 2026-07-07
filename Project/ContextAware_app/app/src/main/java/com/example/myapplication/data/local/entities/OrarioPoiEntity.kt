package com.example.myapplication.data.local.entities

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "orari_table",
    foreignKeys = [
        ForeignKey(
            entity = PoiEntity::class,
            parentColumns = ["id"],
            childColumns = ["id_poi"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("id_poi")]
)
data class OrarioPoiEntity(
    @PrimaryKey val id: Int,
    val id_poi: Int,
    val giorno: Int,
    val orario_apertura: String,
    val orario_chiusura: String
)