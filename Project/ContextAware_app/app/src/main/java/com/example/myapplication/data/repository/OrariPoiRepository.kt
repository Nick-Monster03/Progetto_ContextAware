package com.example.myapplication.data.repository

import com.example.myapplication.data.model.OrariPoiCreate
import com.example.myapplication.data.model.OrariPoiPublic
import com.example.myapplication.data.model.OrariPoiUpdate
import com.example.myapplication.data.remote.api.OrariPoiApi

class OrariPoiRepository(private val api: OrariPoiApi) {

    suspend fun createOrario(orarioIn: OrariPoiCreate): Result<OrariPoiPublic> {
        return try {
            val response = api.createOrario(orarioIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getOrario(orarioId: Int): Result<OrariPoiPublic> {
        return try {
            val response = api.getOrario(orarioId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getOrariByPoi(idPoi: Int): Result<List<OrariPoiPublic>> {
        return try {
            val response = api.getOrariByPoi(idPoi)
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
}