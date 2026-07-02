package com.example.myapplication.data.repository

import com.example.myapplication.data.model.EventoCreate
import com.example.myapplication.data.model.EventoPublic
import com.example.myapplication.data.model.EventoUpdate
import com.example.myapplication.data.remote.api.EventoApi

class EventoRepository(private val api: EventoApi) {

    suspend fun createEvento(eventoIn: EventoCreate): Result<EventoPublic> {
        return try {
            val response = api.createEvento(eventoIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getEvento(eventoId: Int): Result<EventoPublic> {
        return try {
            val response = api.getEvento(eventoId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getEventiByUtente(idUtente: Int): Result<List<EventoPublic>> {
        return try {
            val response = api.getEventiByUtente(idUtente)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updateEvento(eventoId: Int, eventoIn: EventoUpdate): Result<EventoPublic> {
        return try {
            val response = api.updateEvento(eventoId, eventoIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteEvento(eventoId: Int): Result<Unit> {
        return try {
            api.deleteEvento(eventoId)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}