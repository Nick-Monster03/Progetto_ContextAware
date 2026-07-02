package com.example.myapplication.data.repository

import com.example.myapplication.data.remote.api.AuthApi
import com.example.myapplication.data.model.LoginRequest
import com.example.myapplication.data.model.UtenteCreate
import com.example.myapplication.data.model.UtentePublic

class AuthRepository(private val api: AuthApi) {

    suspend fun login(request: LoginRequest): Result<UtentePublic> {
        return try {
            val response = api.login(request)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun register(request: UtenteCreate): Result<UtentePublic> {
        return try {
            val response = api.register(request)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}