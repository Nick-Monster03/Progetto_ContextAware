package com.example.myapplication.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.example.myapplication.data.local.dao.*
import com.example.myapplication.data.local.entities.*

@Database(
    entities = [PoiEntity::class, CategoriaEntity::class, OrarioPoiEntity::class, UtenteEntity::class, AgendaUtenteEntity::class],
    version = 2,
    exportSchema = false
)
abstract class ContextAwareDatabase : RoomDatabase() {

    abstract fun poiDao(): PoiDao
    abstract fun categoriaDao(): CategoriaDao
    abstract fun orarioDao(): OrarioPoiDao
    abstract fun authDao(): AuthDao
    abstract fun agendaUtenteDao(): AgendaUtenteDao

    companion object {
        @Volatile
        private var INSTANCE: ContextAwareDatabase? = null

        val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(db: SupportSQLiteDatabase) {
                db.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS `agenda_table` (
                        `id` INTEGER NOT NULL, 
                        `id_utente` INTEGER NOT NULL, 
                        `id_poi` INTEGER NOT NULL, 
                        `titolo` TEXT NOT NULL, 
                        `orario_inizio` TEXT NOT NULL, 
                        `orario_fine` TEXT NOT NULL, 
                        PRIMARY KEY(`id`)
                    )
                    """.trimIndent()
                )
            }
        }

        fun getDatabase(context: Context): ContextAwareDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    ContextAwareDatabase::class.java,
                    "context_aware_database"
                )
                    .addMigrations(MIGRATION_1_2)
                    .build()

                INSTANCE = instance
                instance
            }
        }
    }
}
