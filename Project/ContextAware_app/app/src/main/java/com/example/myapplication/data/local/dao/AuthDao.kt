package com.example.myapplication.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.myapplication.data.local.entities.UtenteEntity

@Dao
interface AuthDao {

    @Query("SELECT * FROM utente_table WHERE nome = :nome AND cognome = :cognome AND passwordSalvata = :password")
    suspend fun loginOffline(nome: String, cognome: String, password: String): UtenteEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun saveUtente(utente: UtenteEntity)

    @Query("DELETE FROM utente_table")
    suspend fun logout()
}