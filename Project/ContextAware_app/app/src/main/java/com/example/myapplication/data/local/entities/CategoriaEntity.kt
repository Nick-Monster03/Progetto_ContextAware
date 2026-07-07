package com.example.myapplication.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "categoria_table")
data class CategoriaEntity(
    @PrimaryKey val id: Int,
    val nomeStr: String
)