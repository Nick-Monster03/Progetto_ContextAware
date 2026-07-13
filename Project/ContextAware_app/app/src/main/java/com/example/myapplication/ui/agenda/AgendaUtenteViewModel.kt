package com.example.myapplication.ui.agenda

import android.content.Context
import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.myapplication.data.local.ContextAwareDatabase
import com.example.myapplication.data.model.AgendaUtenteCreate
import com.example.myapplication.data.model.AgendaUtentePublic
import com.example.myapplication.data.model.POIPublic
import com.example.myapplication.data.remote.api.AgendaUtenteApi
import com.example.myapplication.data.remote.api.PoiApi
import com.example.myapplication.data.repository.AgendaUtenteRepository
import com.example.myapplication.data.repository.PoiRepository
import com.example.myapplication.utils.ApiClient
import com.example.myapplication.utils.SessionManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class AgendaUtenteViewModel(
    private val agendaRepo: AgendaUtenteRepository,
    private val poiRepo: PoiRepository,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _impegni = MutableStateFlow<List<AgendaUtentePublic>>(emptyList())
    val impegni: StateFlow<List<AgendaUtentePublic>> = _impegni.asStateFlow()

    private val _isLoading = MutableStateFlow(true)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _poiSearchResults = MutableStateFlow<List<POIPublic>>(emptyList())
    val poiSearchResults: StateFlow<List<POIPublic>> = _poiSearchResults.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    init {
        loadAgenda()
    }

    // Carica l'agenda dell'utente loggato, filtrando solo gli impegni futuri.
    fun loadAgenda() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val user = sessionManager.loggedUser.first()
                if (user != null) {
                    val result = agendaRepo.getAgendaUtente(user.id, soloFuturi = true)
                    //Log.d("AgendaUtente", "I risultati${result}")
                    result.onSuccess { list ->
                        _impegni.value = list
                    }.onFailure { error ->
                        _errorMessage.value = error.message ?: "Errore durante il caricamento dell'agenda"
                    }
                }
            } finally {
                _isLoading.value = false
            }
        }
    }

    // Esegue la ricerca dei POI in base alla query dell'utente, limitando i risultati a quelli del campus dell'utente loggato.
    fun searchPoi(query: String) {
        if (query.length < 2) {
            _poiSearchResults.value = emptyList()
            return
        }
        viewModelScope.launch {
            val user = sessionManager.loggedUser.first()
            val result = poiRepo.searchPois(query, user?.campus)
            result.onSuccess { pois ->
                _poiSearchResults.value = pois
            }
        }
    }

// Crea un nuovo impegno per l'utente loggato e aggiorna l'agenda.
    fun createImpegno(titolo: String, idPoi: Int, orarioInizio: String, orarioFine: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            val user = sessionManager.loggedUser.first() ?: return@launch

            val nuovoImpegno = AgendaUtenteCreate(
                id_utente = user.id,
                id_poi = idPoi,
                titolo = titolo,
                orario_inizio = orarioInizio,
                orario_fine = orarioFine
            )

            val result = agendaRepo.createImpegno(nuovoImpegno)

            result.fold(
                onSuccess = {
                    loadAgenda()
                    onSuccess()
                },
                onFailure = { error ->
                    _errorMessage.value = error.message ?: "Impossibile creare l'appuntamento."
                }
            )
        }
    }

    fun clearErrorMessage() {
        _errorMessage.value = null
    }

    class AgendaViewModelFactory(
        private val context: Context
    ) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(AgendaUtenteViewModel::class.java)) {
                val database = ContextAwareDatabase.getDatabase(context)

                val agendaApi = ApiClient.retrofit.create(AgendaUtenteApi::class.java)
                val poiApi = ApiClient.retrofit.create(PoiApi::class.java)

                val agendaRepo = AgendaUtenteRepository(agendaApi, database.agendaUtenteDao())
                val poiRepo = PoiRepository(poiApi, database.poiDao())
                val sessionManager = SessionManager(context)

                @Suppress("UNCHECKED_CAST")
                return AgendaUtenteViewModel(agendaRepo, poiRepo, sessionManager) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class")
        }
    }
}