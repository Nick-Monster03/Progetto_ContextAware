package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.PreferenzaUtenteCreate
import com.example.myapplication.data.model.PreferenzaUtentePublic
import retrofit2.http.*

interface PreferenzaUtenteApi {

    @GET("preferenze/utente/{id_utente}")
    suspend fun getCategorieByUtente(@Path("id_utente") idUtente: Int): List<PreferenzaUtentePublic>

    @GET("preferenze/categoria/{id_categoria}")
    suspend fun getUtentiByCategoria(@Path("id_categoria") idCategoria: Int): List<PreferenzaUtentePublic>

    @POST("preferenze/")
    suspend fun createPreferenza(@Body preferenzaIn: PreferenzaUtenteCreate): PreferenzaUtentePublic

    @DELETE("preferenze/")
    suspend fun deletePreferenza(
        @Query("id_utente") idUtente: Int,
        @Query("id_categoria") idCategoria: Int
    ): Unit
}