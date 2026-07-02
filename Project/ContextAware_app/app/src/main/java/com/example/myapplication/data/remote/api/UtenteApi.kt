package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.UtenteCreate
import com.example.myapplication.data.model.UtentePublic
import com.example.myapplication.data.model.UtenteUpdate
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.POST
import retrofit2.http.DELETE
import retrofit2.http.PATCH
import okhttp3.OkHttpClient

interface UtenteApi {

    @POST("utenti/")
    suspend fun createUtente(@Body utenteIn: UtenteCreate): UtentePublic

    @GET("utenti/")
    suspend fun getAllUtenti(): List<UtentePublic>

    @GET("utenti/{utenteId}")
    suspend fun getUtente(@Path("utenteId") utenteId: Int): UtentePublic

    @PATCH("utenti/{utenteId}")
    suspend fun updateUtente(
        @Path("utenteId") utenteId: Int,
        @Body utenteIn: UtenteUpdate
    ): UtentePublic

    @DELETE("utenti/{utenteId}")
    suspend fun deleteUtente(@Path("utenteId") utenteId: Int): Unit

    @GET("utenti/campus/{campus}")
    suspend fun getUtentiByCampus(@Path("campus") campus: String): List<UtentePublic>

    @GET("utenti/mezzo/{mezzo}")
    suspend fun getUtentiByMezzo(@Path("mezzo") mezzo: String): List<UtentePublic>

    @GET("utenti/preferenza/{idCategoria}")
    suspend fun getUtentiByPreferenza(@Path("idCategoria") idCategoria: Int): List<UtentePublic>

}