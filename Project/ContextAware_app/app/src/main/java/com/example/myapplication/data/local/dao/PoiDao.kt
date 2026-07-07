package com.example.myapplication.data.local.dao


import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.myapplication.data.local.entities.PoiEntity

@Dao
interface PoiDao {

    @Query("SELECT * FROM poi_table")
    suspend fun getAllPois(): List<PoiEntity>

    @Query("SELECT * FROM poi_table WHERE id = :poiId")
    suspend fun getPoiById(poiId: Int): PoiEntity?

    @Query("SELECT * FROM poi_table WHERE id_categoria = :idCategoria")
    suspend fun getPoisByCategoria(idCategoria: Int): List<PoiEntity>

    @Query("SELECT * FROM poi_table WHERE id_categoria IN (:categories)")
    suspend fun getPoisByCategories(categories: List<Int>): List<PoiEntity>

    @Query("SELECT * FROM poi_table WHERE campus = :campus")
    suspend fun getPoisByCampus(campus: String): List<PoiEntity>

    @Query("SELECT * FROM poi_table WHERE nome LIKE '%' || :searchQuery || '%'")
    suspend fun searchPoisByName(searchQuery: String): List<PoiEntity>

    @Query("SELECT * FROM poi_table WHERE nome LIKE '%' || :searchQuery || '%' AND campus = :campus")
    suspend fun searchPoisByNameAndCampus(searchQuery: String, campus: String): List<PoiEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(pois: List<PoiEntity>)

    @Query("DELETE FROM poi_table")
    suspend fun clearAll()
}
