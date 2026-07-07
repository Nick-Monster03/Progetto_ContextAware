package com.example.myapplication.data.repository

import com.example.myapplication.data.local.dao.OrarioPoiDao
import com.example.myapplication.data.local.entities.OrarioPoiEntity
import com.example.myapplication.data.model.OrariPoiCreate
import com.example.myapplication.data.model.OrariPoiPublic
import com.example.myapplication.data.model.OrariPoiUpdate
import com.example.myapplication.data.remote.api.OrariPoiApi
import java.io.IOException

class OrariPoiRepository(
    private val api: OrariPoiApi,
    private val orarioDao: OrarioPoiDao
) {

    suspend fun getOrariByPoi(idPoi: Int): Result<List<OrariPoiPublic>> {
        return try {
            val response = api.getOrariByPoi(idPoi)
            //orarioDao.insertAll(response.map { it.toEntity() })

            Result.success(response)
        } catch (e: IOException) {
            try {
                val cached = orarioDao.getOrariByPoi(idPoi).map { it.toOrariPoiPublic() }
                if (cached.isNotEmpty()) {
                    Result.success(cached)
                } else {
                    Result.failure(e)
                }
            } catch (dbError: Exception) {
                Result.failure(e)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    suspend fun getOrario(orarioId: Int): Result<OrariPoiPublic> {
        return try {
            val response = api.getOrario(orarioId)
            Result.success(response)
        } catch (e: IOException) {
            val cached = orarioDao.getOrarioById(orarioId)?.toOrariPoiPublic()
            if (cached != null) Result.success(cached) else Result.failure(e)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createOrario(orarioIn: OrariPoiCreate): Result<OrariPoiPublic> {
        return try {
            val response = api.createOrario(orarioIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updateOrario(orarioId: Int, orarioIn: OrariPoiUpdate): Result<OrariPoiPublic> {
        return try {
            val response = api.updateOrario(orarioId, orarioIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteOrario(orarioId: Int): Result<Unit> {
        return try {
            api.deleteOrario(orarioId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun OrariPoiPublic.toEntity() = OrarioPoiEntity(
        id = this.id,
        id_poi = this.id_poi,
        giorno = this.giorno,
        orario_apertura = this.orario_apertura,
        orario_chiusura = this.orario_chiusura
    )

    fun OrarioPoiEntity.toOrariPoiPublic() = OrariPoiPublic(
        id = this.id,
        id_poi = this.id_poi,
        giorno = this.giorno,
        orario_apertura = this.orario_apertura,
        orario_chiusura = this.orario_chiusura
    )

    suspend fun salvaOrariPerTuttiIPoi(listaIdPoi: List<Int>): Result<Unit> {
        return try {
            listaIdPoi.forEach { idPoi ->
                try {
                    val response = api.getOrariByPoi(idPoi)
                    if (response.isNotEmpty()) {
                        orarioDao.insertAll(response.map { it.toEntity() })
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            Result.success(Unit)

        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}