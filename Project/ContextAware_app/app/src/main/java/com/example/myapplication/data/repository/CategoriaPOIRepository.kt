package com.example.myapplication.data.repository

import com.example.myapplication.data.local.dao.CategoriaDao
import com.example.myapplication.data.local.entities.CategoriaEntity
import com.example.myapplication.data.model.CategoriaPOIPublic
import com.example.myapplication.data.model.NomeCategoria
import com.example.myapplication.data.remote.api.CategoriaPOIApi
import java.io.IOException



class CategoriaPOIRepository(
    private val api: CategoriaPOIApi,
    private val categoriaDao: CategoriaDao
) {

    suspend fun getAllCategorie(): Result<List<CategoriaPOIPublic>> {
        return try {
            val response = api.getAllCategorie()

            categoriaDao.insertAll(response.map { it.toEntity() })
            Result.success(response)

        } catch (e: IOException) {
            try {
                val cached = categoriaDao.getAllCategories().map { it.toCategoriaPublic() }
                if (cached.isNotEmpty()) {
                    Result.success(cached)
                } else {
                    Result.failure(e)
                }
            } catch (dbError: Exception) {
                Result.failure(e)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getCategoriaById(categoriaId: Int): Result<CategoriaPOIPublic> {
        return try {
            val response = api.getCategoriaById(categoriaId)
            Result.success(response)
        } catch (e: IOException) {
            val cached = categoriaDao.getCategoriaById(categoriaId)?.toCategoriaPublic()
            if (cached != null) Result.success(cached) else Result.failure(e)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getCategoriaByNome(nome: NomeCategoria): Result<CategoriaPOIPublic> {
        return try {
            val response = api.getCategoriaByNome(nome)
            Result.success(response)
        } catch (e: IOException) {
            val cached = categoriaDao.getCategoriaByNome(nome.name)?.toCategoriaPublic()
            if (cached != null) Result.success(cached) else Result.failure(e)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getCategoriaByPoiId(poiId: Int): Result<CategoriaPOIPublic> {
        return try {
            val response = api.getCategoriaByPoiId(poiId)
            Result.success(response)
        } catch (e: IOException) {
            val cached = categoriaDao.getCategoriaByPoiId(poiId)?.toCategoriaPublic()
            if (cached != null) Result.success(cached) else Result.failure(e)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun CategoriaPOIPublic.toEntity() = CategoriaEntity(
        id = this.id,
        nomeStr = this.nome.name
    )

    // Traduce da Database a Rete (Prima si chiamava toDomain)
    fun CategoriaEntity.toCategoriaPublic() = CategoriaPOIPublic(
        id = this.id,
        nome = NomeCategoria.valueOf(this.nomeStr)
    )
}