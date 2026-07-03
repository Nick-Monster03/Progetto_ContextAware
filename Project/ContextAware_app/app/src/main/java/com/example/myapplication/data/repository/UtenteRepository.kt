package com.example.myapplication.data.repository

import android.util.Log
import com.example.myapplication.data.model.MezzoSpostamento
import com.example.myapplication.data.model.UtenteCreate
import com.example.myapplication.data.model.UtentePublic
import com.example.myapplication.data.model.UtenteUpdate
import com.example.myapplication.data.remote.api.UtenteApi

class UtenteRepository(private val api: UtenteApi) {

    suspend fun createUtente(utenteIn: UtenteCreate): Result<UtentePublic> {
        return try {
            val response = api.createUtente(utenteIn)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getAllUtenti(): Result<List<UtentePublic>> {
        return try {
            val response = api.getAllUtenti()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getUtente(utenteId: Int): Result<UtentePublic> {
        return try {
            val response = api.getUtente(utenteId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updateUtente(utenteId: Int, utenteIn: UtenteUpdate): Result<UtentePublic> {
        return try {
            //Log.d("route", utenteIn.mezzoDiSpostamento?.name?:"-")
            val response = api.updateUtente(utenteId, utenteIn)
            //Log.d("route", response.mezzoDiSpostamento?.name?:"-")
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteUtente(utenteId: Int): Result<Unit> {
        return try {
            val response = api.deleteUtente(utenteId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getUtentiByCampus(campus: String): Result<List<UtentePublic>> {
        return try {
            val response = api.getUtentiByCampus(campus)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getUtentiByMezzo(mezzo: MezzoSpostamento): Result<List<UtentePublic>> {
        return try {
            val response = api.getUtentiByMezzo(mezzo.dbValue)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}