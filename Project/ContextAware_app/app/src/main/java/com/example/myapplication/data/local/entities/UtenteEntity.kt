package com.example.myapplication.data.local.entities


import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "utente_table")
data class UtenteEntity(
    @PrimaryKey val id: Int,
    val nome: String,
    val cognome: String,
    val campus: String?,
    val mezzoDiSpostamentoStr: String?,
    val passwordSalvata: String
)