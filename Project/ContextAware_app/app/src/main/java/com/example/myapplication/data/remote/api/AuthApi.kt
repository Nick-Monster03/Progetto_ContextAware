package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.LoginRequest
import com.example.myapplication.data.model.UtenteCreate
import com.example.myapplication.data.model.UtentePublic
import retrofit2.http.Body
import retrofit2.http.POST

interface AuthApi {

    @POST("auth/login")
    suspend fun login(
        @Body request: LoginRequest
    ): UtentePublic

    @POST("auth/register")
    suspend fun register(
        @Body request: UtenteCreate
    ): UtentePublic

}