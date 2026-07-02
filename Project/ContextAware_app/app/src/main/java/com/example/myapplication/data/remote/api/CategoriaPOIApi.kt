package com.example.myapplication.data.remote.api

import com.example.myapplication.data.model.CategoriaPOIPublic
import com.example.myapplication.data.model.NomeCategoria
import retrofit2.http.GET
import retrofit2.http.Path

interface CategoriaPOIApi {

    @GET("categorie/")
    suspend fun getAllCategorie(): List<CategoriaPOIPublic>

    @GET("categorie/{categoria_id}")
    suspend fun getCategoriaById(@Path("categoria_id") categoriaId: Int): CategoriaPOIPublic

    @GET("categorie/nome/{nome}")
    suspend fun getCategoriaByNome(@Path("nome") nome: NomeCategoria): CategoriaPOIPublic

    @GET("categorie/poi/{poi_id}")
    suspend fun getCategoriaByPoiId(@Path("poi_id") poiId: Int): CategoriaPOIPublic
}