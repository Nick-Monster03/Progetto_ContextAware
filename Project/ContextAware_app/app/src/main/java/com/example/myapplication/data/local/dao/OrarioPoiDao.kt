package com.example.myapplication.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.myapplication.data.local.entities.OrarioPoiEntity

@Dao
interface OrarioPoiDao {

    @Query("SELECT * FROM orari_table WHERE id_poi = :idPoi ORDER BY giorno ASC, orario_apertura ASC")
    suspend fun getOrariByPoi(idPoi: Int): List<OrarioPoiEntity>

    @Query("SELECT * FROM orari_table WHERE id = :orarioId")
    suspend fun getOrarioById(orarioId: Int): OrarioPoiEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(orari: List<OrarioPoiEntity>)

    @Query("DELETE FROM orari_table")
    suspend fun clearAll()
}