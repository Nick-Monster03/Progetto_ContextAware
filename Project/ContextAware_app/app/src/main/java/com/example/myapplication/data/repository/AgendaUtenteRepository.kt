package com.example.myapplication.data.repository

import com.example.myapplication.data.model.AgendaUtenteContext
import com.example.myapplication.data.model.AgendaUtenteCreate
import com.example.myapplication.data.model.AgendaUtentePublic
import com.example.myapplication.data.model.AgendaUtenteUpdate
import com.example.myapplication.data.remote.api.AgendaUtenteApi

class AgendaUtenteRepository(private val api: AgendaUtenteApi) {

    suspend fun createImpegno(impegnoIn: AgendaUtenteCreate): Result<AgendaUtentePublic> {
        return try {
            val response = api.createImpegno(impegnoIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getAgendaUtente(idUtente: Int, soloFuturi: Boolean = false): Result<List<AgendaUtentePublic>> {
        return try {
            val response = api.getAgendaUtente(idUtente, soloFuturi)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getImpegniCritici(idUtente: Int, lat: Double, lon: Double): Result<List<AgendaUtenteContext>> {
        return try {
            val response = api.getImpegniCritici(idUtente, lat, lon)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getImpegno(impegnoId: Int): Result<AgendaUtentePublic> {
        return try {
            val response = api.getImpegno(impegnoId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updateImpegno(impegnoId: Int, impegnoIn: AgendaUtenteUpdate): Result<AgendaUtentePublic> {
        return try {
            val response = api.updateImpegno(impegnoId, impegnoIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteImpegno(impegnoId: Int): Result<Unit> {
        return try {
            api.deleteImpegno(impegnoId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}