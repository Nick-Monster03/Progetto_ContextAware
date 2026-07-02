package com.example.myapplication.data.repository

import com.example.myapplication.data.model.PreferenzaUtenteCreate
import com.example.myapplication.data.model.PreferenzaUtentePublic
import com.example.myapplication.data.remote.api.PreferenzaUtenteApi

class PreferenzaUtenteRepository(private val api: PreferenzaUtenteApi) {

    suspend fun getCategorieByUtente(idUtente: Int): Result<List<PreferenzaUtentePublic>> {
        return try {
            val response = api.getCategorieByUtente(idUtente)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getUtentiByCategoria(idCategoria: Int): Result<List<PreferenzaUtentePublic>> {
        return try {
            val response = api.getUtentiByCategoria(idCategoria)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createPreferenza(preferenzaIn: PreferenzaUtenteCreate): Result<PreferenzaUtentePublic> {
        return try {
            val response = api.createPreferenza(preferenzaIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deletePreferenza(idUtente: Int, idCategoria: Int): Result<Unit> {
        return try {
            api.deletePreferenza(idUtente, idCategoria)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}