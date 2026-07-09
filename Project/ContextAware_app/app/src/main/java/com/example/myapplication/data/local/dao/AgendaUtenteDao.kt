package com.example.myapplication.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.myapplication.data.local.entities.AgendaUtenteEntity

@Dao
interface AgendaUtenteDao {

    @Query("SELECT * FROM agenda_table WHERE id_utente = :idUtente AND orario_inizio >= :currentTime ORDER BY orario_inizio ASC")
    suspend fun getAgendaUtente(idUtente: Int, currentTime: String): List<AgendaUtenteEntity>

    @Query("SELECT * FROM agenda_table WHERE id = :impegnoId")
    suspend fun getImpegnoById(impegnoId: Int): AgendaUtenteEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(impegni: List<AgendaUtenteEntity>)

    @Query("DELETE FROM agenda_table")
    suspend fun clearAll()
}