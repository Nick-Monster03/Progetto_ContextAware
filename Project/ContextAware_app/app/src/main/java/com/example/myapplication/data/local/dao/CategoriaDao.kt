package com.example.myapplication.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.myapplication.data.local.entities.CategoriaEntity

@Dao
interface CategoriaDao {

    @Query("SELECT * FROM categoria_table")
    suspend fun getAllCategories(): List<CategoriaEntity>

    @Query("SELECT * FROM categoria_table WHERE id = :id")
    suspend fun getCategoriaById(id: Int): CategoriaEntity?

    @Query("SELECT * FROM categoria_table WHERE nomeStr = :nomeStr")
    suspend fun getCategoriaByNome(nomeStr: String): CategoriaEntity?

    @Query("""
        SELECT c.* FROM categoria_table c 
        INNER JOIN poi_table p ON c.id = p.id_categoria 
        WHERE p.id = :poiId
    """)
    suspend fun getCategoriaByPoiId(poiId: Int): CategoriaEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(categories: List<CategoriaEntity>)

    @Query("DELETE FROM categoria_table")
    suspend fun clearAll()
}