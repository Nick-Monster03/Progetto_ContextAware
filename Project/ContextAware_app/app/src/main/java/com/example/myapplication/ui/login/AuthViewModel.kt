package com.example.myapplication.ui.login

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.myapplication.utils.SessionManager
import com.example.myapplication.data.model.LoginRequest
import com.example.myapplication.data.model.MezzoSpostamento
import com.example.myapplication.data.model.UtenteCreate
import com.example.myapplication.data.model.UtentePublic
import com.example.myapplication.data.remote.api.AuthApi
import com.example.myapplication.data.repository.AuthRepository
import com.example.myapplication.utils.ApiClient
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed class AuthState {
    object Idle : AuthState()
    object Loading : AuthState()
    data class Success(val utente: UtentePublic) : AuthState()
    data class Error(val message: String) : AuthState()
}

class AuthViewModel(
    private val repository: AuthRepository,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _authState = MutableStateFlow<AuthState>(AuthState.Idle)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    fun login(nome: String, cognome: String, password: String) {
        _authState.value = AuthState.Loading

        viewModelScope.launch {
            val request = LoginRequest(nome, cognome, password)
            val result = repository.login(request)

            result.fold(
                onSuccess = { utente ->
                    sessionManager.saveUser(utente)
                    _authState.value = AuthState.Success(utente)
                },
                onFailure = { e ->
                    _authState.value = AuthState.Error(e.message ?: "Credenziali non valide o errore di rete")
                }
            )
        }
    }

    fun register(nome: String, cognome: String, password: String, campus: String?, mezzo: String?) {
        _authState.value = AuthState.Loading

        viewModelScope.launch {

            var mezzoEnum: MezzoSpostamento? = null
            if(mezzo != null){
                val mezzoFormattato = mezzo.trim().replace(" ", "_").uppercase()
                mezzoEnum = MezzoSpostamento.valueOf(mezzoFormattato)
            }

            val request = UtenteCreate(nome, cognome, campus, mezzoEnum, password)
            val result = repository.register(request)

            result.fold(
                onSuccess = { utente ->
                    sessionManager.saveUser(utente)

                    _authState.value = AuthState.Success(utente)
                },
                onFailure = { e ->
                    _authState.value = AuthState.Error(e.message ?: "Errore durante la registrazione")
                }
            )
        }
    }

    fun resetState() {
        _authState.value = AuthState.Idle
    }

    class AuthViewModelFactory(private val context: Context) : ViewModelProvider.Factory {

        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(AuthViewModel::class.java)) {
                val api = ApiClient.retrofit.create(AuthApi::class.java)
                val repository = AuthRepository(api)
                val sessionManager = SessionManager(context)

                @Suppress("UNCHECKED_CAST")
                return AuthViewModel(repository, sessionManager) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}