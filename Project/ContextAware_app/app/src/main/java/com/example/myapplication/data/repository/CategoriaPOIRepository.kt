package com.example.myapplication.data.repository

import com.example.myapplication.data.model.CategoriaPOIPublic
import com.example.myapplication.data.model.NomeCategoria
import com.example.myapplication.data.remote.api.CategoriaPOIApi

class CategoriaPOIRepository(private val api: CategoriaPOIApi) {

    suspend fun getAllCategorie(): Result<List<CategoriaPOIPublic>> {
        return try {
            val response = api.getAllCategorie()
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getCategoriaById(categoriaId: Int): Result<CategoriaPOIPublic> {
        return try {
            val response = api.getCategoriaById(categoriaId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getCategoriaByNome(nome: NomeCategoria): Result<CategoriaPOIPublic> {
        return try {
            val response = api.getCategoriaByNome(nome)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getCategoriaByPoiId(poiId: Int): Result<CategoriaPOIPublic> {
        return try {
            val response = api.getCategoriaByPoiId(poiId)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}