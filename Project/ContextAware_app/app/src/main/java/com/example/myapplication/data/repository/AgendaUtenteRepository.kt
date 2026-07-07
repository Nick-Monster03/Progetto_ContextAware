package com.example.myapplication.data.repository

import com.example.myapplication.data.local.dao.AgendaUtenteDao
import com.example.myapplication.data.local.entities.AgendaUtenteEntity
import com.example.myapplication.data.model.AgendaUtenteContext
import com.example.myapplication.data.model.AgendaUtenteCreate
import com.example.myapplication.data.model.AgendaUtentePublic
import com.example.myapplication.data.model.AgendaUtenteUpdate
import com.example.myapplication.data.remote.api.AgendaUtenteApi
import java.io.IOException


class AgendaUtenteRepository(
    private val api: AgendaUtenteApi,
    private val agendaDao: AgendaUtenteDao
) {
    suspend fun getAgendaUtente(idUtente: Int, soloFuturi: Boolean = false): Result<List<AgendaUtentePublic>> {
        return try {
            val response = api.getAgendaUtente(idUtente, soloFuturi)

            agendaDao.insertAll(response.map { it.toEntity() })
            Result.success(response)
        } catch (e: IOException) {
            try {
                val cached = agendaDao.getAgendaUtente(idUtente).map { it.toAgendaPublic() }

                if (cached.isNotEmpty()) {
                    Result.success(cached)
                } else {
                    Result.failure(Exception("Sei offline e non hai appuntamenti salvati in memoria."))
                }
            } catch (dbError: Exception) {
                Result.failure(e)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getImpegno(impegnoId: Int): Result<AgendaUtentePublic> {
        return try {
            val response = api.getImpegno(impegnoId)
            Result.success(response)
        } catch (e: IOException) {
            // MANCA INTERNET: Cerca il singolo impegno nel DAO
            val cached = agendaDao.getImpegnoById(impegnoId)?.toAgendaPublic()
            if (cached != null) Result.success(cached) else Result.failure(Exception("Impegno non trovato offline."))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    suspend fun createImpegno(impegnoIn: AgendaUtenteCreate): Result<AgendaUtentePublic> {
        return try {
            val response = api.createImpegno(impegnoIn)
            Result.success(response)
        } catch (e: IOException) {
            // Fallisce elegantemente se offline
            Result.failure(Exception("Connessione necessaria per aggiungere un appuntamento all'agenda."))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updateImpegno(impegnoId: Int, impegnoIn: AgendaUtenteUpdate): Result<AgendaUtentePublic> {
        return try {
            val response = api.updateImpegno(impegnoId, impegnoIn)
            Result.success(response)
        } catch (e: IOException) {
            Result.failure(Exception("Connessione necessaria per modificare un appuntamento."))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteImpegno(impegnoId: Int): Result<Unit> {
        return try {
            api.deleteImpegno(impegnoId)
            Result.success(Unit)
        } catch (e: IOException) {
            Result.failure(Exception("Connessione necessaria per eliminare un appuntamento."))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getImpegniCritici(idUtente: Int, lat: Double, lon: Double): Result<List<AgendaUtenteContext>> {
        return try {
            val response = api.getImpegniCritici(idUtente, lat, lon)
            Result.success(response)
        } catch (e: IOException) {
            Result.failure(Exception("Il calcolo degli impegni critici richiede il GPS e la connessione a Internet."))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun AgendaUtentePublic.toEntity() = AgendaUtenteEntity(
        id = this.id,
        id_utente = this.id_utente,
        id_poi = this.id_poi,
        titolo = this.titolo,
        orario_inizio = this.orario_inizio,
        orario_fine = this.orario_fine
    )

    fun AgendaUtenteEntity.toAgendaPublic() = AgendaUtentePublic(
        id = this.id,
        id_utente = this.id_utente,
        id_poi = this.id_poi,
        titolo = this.titolo,
        orario_inizio = this.orario_inizio,
        orario_fine = this.orario_fine
    )
}

