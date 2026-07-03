package com.example.myapplication.utils


import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import com.example.myapplication.data.model.MezzoSpostamento
import com.example.myapplication.data.model.UtentePublic
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "user_session")

class SessionManager(private val context: Context) {

    companion object {
        val USER_ID = intPreferencesKey("user_id")
        val USER_NOME = stringPreferencesKey("user_nome")
        val USER_COGNOME = stringPreferencesKey("user_cognome")
        val USER_CAMPUS = stringPreferencesKey("user_campus")
        val USER_MEZZO = stringPreferencesKey("user_mezzo")
    }

    suspend fun saveUser(utente: UtentePublic) {
        context.dataStore.edit { preferences ->
            preferences[USER_ID] = utente.id
            preferences[USER_NOME] = utente.nome
            preferences[USER_COGNOME] = utente.cognome

            if (utente.campus != null) {
                preferences[USER_CAMPUS] = utente.campus
            } else {
                preferences.remove(USER_CAMPUS)
            }

            if (utente.mezzoDiSpostamento != null) {
                preferences[USER_MEZZO] = utente.mezzoDiSpostamento.name
            } else {
                preferences[USER_MEZZO] = MezzoSpostamento.A_PIEDI.name
            }
        }
    }

    val loggedUser: Flow<UtentePublic?> = context.dataStore.data.map { preferences ->
        val id = preferences[USER_ID]
        if (id != null) {
            val mezzoName = preferences[USER_MEZZO]
            val mezzo = mezzoName?.let {
                try { MezzoSpostamento.valueOf(it) } catch (e: Exception) { MezzoSpostamento.A_PIEDI }
            }
            UtentePublic(
                id = id,
                nome = preferences[USER_NOME] ?: "",
                cognome = preferences[USER_COGNOME] ?: "",
                campus = preferences[USER_CAMPUS],
                mezzoDiSpostamento = mezzo
            )
        } else {
            null
        }
    }

    suspend fun clearSession() {
        context.dataStore.edit { preferences ->
            preferences.clear()
        }
    }
}