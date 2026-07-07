package com.example.myapplication.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "agenda_table")
data class AgendaUtenteEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val id_utente: Int,
    val id_poi: Int,
    val titolo: String,
    val orario_inizio: String,
    val orario_fine: String
)