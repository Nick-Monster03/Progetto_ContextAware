package com.example.myapplication.data.repository

import com.example.myapplication.data.local.dao.AuthDao
import com.example.myapplication.data.local.entities.UtenteEntity
import com.example.myapplication.data.model.LoginRequest
import com.example.myapplication.data.model.MezzoSpostamento
import com.example.myapplication.data.model.UtenteCreate
import com.example.myapplication.data.model.UtentePublic
import com.example.myapplication.data.remote.api.AuthApi
import java.io.IOException


class AuthRepository(
    private val api: AuthApi,
    private val authDao: AuthDao
) {

    suspend fun login(request: LoginRequest): Result<UtentePublic> {
        return try {
            val response = api.login(request)
            authDao.saveUtente(response.toEntity(request.password))

            Result.success(response)
        } catch (e: IOException) {
            try {
                val cachedUser = authDao.loginOffline(request.nome, request.cognome, request.password)

                if (cachedUser != null) {
                    Result.success(cachedUser.toUtentePublic())
                } else {
                    Result.failure(Exception("Sei offline o le credenziali sono errate."))
                }
            } catch (dbError: Exception) {
                Result.failure(e)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun register(request: UtenteCreate): Result<UtentePublic> {
        return try {
            val response = api.register(request)
            authDao.saveUtente(response.toEntity(request.password))

            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun UtentePublic.toEntity(passwordInviata: String) = UtenteEntity(
        id = this.id,
        nome = this.nome,
        cognome = this.cognome,
        campus = this.campus,
        mezzoDiSpostamentoStr = this.mezzoDiSpostamento?.name,
        passwordSalvata = passwordInviata
    )

    fun UtenteEntity.toUtentePublic() = UtentePublic(
        id = this.id,
        nome = this.nome,
        cognome = this.cognome,
        campus = this.campus,
        mezzoDiSpostamento = this.mezzoDiSpostamentoStr?.let { MezzoSpostamento.valueOf(it) }
    )
}