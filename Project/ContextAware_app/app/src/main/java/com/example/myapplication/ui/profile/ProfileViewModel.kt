package com.example.myapplication.ui.profile

import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.myapplication.data.model.CategoriaPOIPublic
import com.example.myapplication.data.model.MezzoSpostamento
import com.example.myapplication.data.model.PreferenzaUtenteCreate
import com.example.myapplication.data.model.UtenteUpdate
import com.example.myapplication.data.remote.api.CategoriaPOIApi
import com.example.myapplication.data.remote.api.PreferenzaUtenteApi
import com.example.myapplication.data.remote.api.UtenteApi
import com.example.myapplication.data.repository.CategoriaPOIRepository
import com.example.myapplication.data.repository.PreferenzaUtenteRepository
import com.example.myapplication.data.repository.UtenteRepository
import com.example.myapplication.utils.ApiClient
import com.example.myapplication.utils.SessionManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class ProfileViewModel(
    private val sessionManager: SessionManager,
    private val utenteRepository: UtenteRepository,
    private val preferenzaRepository: PreferenzaUtenteRepository,
    private val categoriaRepository: CategoriaPOIRepository
) : ViewModel() {

    private val _userId = MutableStateFlow<Int?>(null)
    val userId: StateFlow<Int?> = _userId.asStateFlow()

    private val _nome = MutableStateFlow("")
    val nome: StateFlow<String> = _nome.asStateFlow()

    private val _cognome = MutableStateFlow("")
    val cognome: StateFlow<String> = _cognome.asStateFlow()

    private val _campus = MutableStateFlow("")
    val campus: StateFlow<String> = _campus.asStateFlow()

    private val _mezzoSpostamento = MutableStateFlow("")
    val mezzoSpostamento: StateFlow<String> = _mezzoSpostamento.asStateFlow()

    private val _categories = MutableStateFlow<List<CategoriaPOIPublic>>(emptyList())
    val categories: StateFlow<List<CategoriaPOIPublic>> = _categories.asStateFlow()

    private var initialPreferences = setOf<Int>()

    private val _selectedCategories = MutableStateFlow<Set<Int>>(emptySet())
    val selectedCategories: StateFlow<Set<Int>> = _selectedCategories.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _message = MutableStateFlow<String?>(null)
    val message: StateFlow<String?> = _message.asStateFlow()

    init {
        loadUserData()
        fetchCategories()
    }

    private fun loadUserData() {
        viewModelScope.launch {
            _isLoading.value = true

            val user = sessionManager.loggedUser.first()

            if (user != null) {
                _userId.value = user.id
                _nome.value = user.nome
                _cognome.value = user.cognome
                _campus.value = user.campus ?: ""
                _mezzoSpostamento.value = user.mezzoDiSpostamento?.name ?: "A_PIEDI"

                val prefResult = preferenzaRepository.getCategorieByUtente(user.id)
                prefResult.onSuccess { preferenze ->
                    val ids = preferenze.map { it.id_categoria }.toSet()
                    initialPreferences = ids
                    _selectedCategories.value = ids
                }
            }

            _isLoading.value = false
        }
    }

    private fun fetchCategories() {
        viewModelScope.launch {
            val result = categoriaRepository.getAllCategorie()
            result.onSuccess { list ->
                _categories.value = list
            }
        }
    }

    fun toggleCategory(categoryId: Int) {
        val currentSet = _selectedCategories.value.toMutableSet()
        if (currentSet.contains(categoryId)) {
            currentSet.remove(categoryId)
        } else {
            currentSet.add(categoryId)
        }
        _selectedCategories.value = currentSet
    }

    fun setCampus(newCampus: String) {
        _campus.value = newCampus
    }

    fun setMezzoSpostamento(newMezzo: String) {
        _mezzoSpostamento.value = newMezzo
    }

    fun clearMessage() {
        _message.value = null
    }

    fun updateProfileInfo() {
        val uid = _userId.value ?: return

        viewModelScope.launch {
            _isLoading.value = true

            val mezzoString = _mezzoSpostamento.value
            val mezzoEnum = if (mezzoString.isNotBlank()) {
                try {
                    MezzoSpostamento.valueOf(mezzoString)
                } catch (e: Exception) {
                    null
                }
            } else {
                null
            }

            val updatePayload = UtenteUpdate(
                campus = _campus.value.ifBlank { null },
                mezzoDiSpostamento = mezzoEnum
            )
            //DEBUG
            Log.d("Profile-User", updatePayload.campus?: "-")
            Log.d("Profile-User", updatePayload.mezzoDiSpostamento?.name ?: "-")
            val result = utenteRepository.updateUtente(uid, updatePayload)

            result.fold(
                onSuccess = { updatedUtente ->
                    sessionManager.saveUser(updatedUtente)
                    _message.value = "Profilo aggiornato con successo!"
                },
                onFailure = {
                    _message.value = "Errore durante l'aggiornamento del profilo."
                }
            )
            _isLoading.value = false
        }
    }

    fun updatePreferences() {
        val uid = _userId.value ?: return

        viewModelScope.launch {
            _isLoading.value = true

            val currentSelected = _selectedCategories.value

            val toAdd = currentSelected.subtract(initialPreferences)
            val toRemove = initialPreferences.subtract(currentSelected)

            var success = true

            for (catId in toRemove) {
                val res = preferenzaRepository.deletePreferenza(uid, catId)
                Log.d("Profile-Preferences", "Rimossa con successo catId: $catId per utente: $uid")
                if (res.isFailure) success = false
            }

            for (catId in toAdd) {
                val payload = PreferenzaUtenteCreate(id_utente = uid, id_categoria = catId)
                val res = preferenzaRepository.createPreferenza(payload)
                Log.d("Profile-Preferences", "Aggiunta con successo catId: $catId per utente: $uid")
                if (res.isFailure) success = false
            }

            if (success) {
                initialPreferences = currentSelected
                _message.value = "Preferenze aggiornate con successo!"
            } else {
                _message.value = "Si è verificato un errore parziale nell'aggiornamento."
            }

            _isLoading.value = false
        }
    }

    class ProfileViewModelFactory(private val context: Context) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(ProfileViewModel::class.java)) {
                val sessionManager = SessionManager(context)

                val utenteApi = ApiClient.retrofit.create(UtenteApi::class.java)
                val preferenzaApi = ApiClient.retrofit.create(PreferenzaUtenteApi::class.java)
                val categoriaApi = ApiClient.retrofit.create(CategoriaPOIApi::class.java)

                val utenteRepository = UtenteRepository(utenteApi)
                val preferenzaRepository = PreferenzaUtenteRepository(preferenzaApi)
                val categoriaRepository = CategoriaPOIRepository(categoriaApi)

                @Suppress("UNCHECKED_CAST")
                return ProfileViewModel(
                    sessionManager,
                    utenteRepository,
                    preferenzaRepository,
                    categoriaRepository
                ) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}