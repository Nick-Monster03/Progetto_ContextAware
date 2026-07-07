package com.example.myapplication.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.myapplication.data.local.dao.AuthDao
import com.example.myapplication.data.local.dao.CategoriaDao
import com.example.myapplication.data.local.dao.OrarioPoiDao
import com.example.myapplication.data.local.dao.PoiDao
import com.example.myapplication.data.local.entities.CategoriaEntity
import com.example.myapplication.data.local.entities.OrarioPoiEntity
import com.example.myapplication.data.local.entities.PoiEntity
import com.example.myapplication.data.local.entities.UtenteEntity

@Database(
    entities = [PoiEntity::class, CategoriaEntity::class, OrarioPoiEntity::class, UtenteEntity::class],
    version = 1,
    exportSchema = false
)
abstract class ContextAwareDatabase : RoomDatabase() {

    abstract fun poiDao(): PoiDao
    abstract fun categoriaDao(): CategoriaDao
    abstract fun orarioDao(): OrarioPoiDao
    abstract fun authDao(): AuthDao

    companion object {
        @Volatile
        private var INSTANCE: ContextAwareDatabase? = null

        fun getDatabase(context: Context): ContextAwareDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    ContextAwareDatabase::class.java,
                    "context_aware_database"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}