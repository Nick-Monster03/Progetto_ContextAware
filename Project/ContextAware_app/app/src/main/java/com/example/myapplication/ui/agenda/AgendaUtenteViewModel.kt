package com.example.myapplication.ui.agenda

import android.content.Context
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
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class AgendaUtenteViewModel(
    private val agendaRepo: AgendaUtenteRepository,
    private val poiRepo: PoiRepository,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _impegni = MutableStateFlow<List<AgendaUtentePublic>>(emptyList())
    val impegni: StateFlow<List<AgendaUtentePublic>> = _impegni

    private val _isLoading = MutableStateFlow(true)
    val isLoading: StateFlow<Boolean> = _isLoading

    private val _poiSearchResults = MutableStateFlow<List<POIPublic>>(emptyList())
    val poiSearchResults: StateFlow<List<POIPublic>> = _poiSearchResults

    init {
        loadAgenda()
    }

    fun loadAgenda() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val user = sessionManager.loggedUser.first()
                if (user != null) {
                    val result = agendaRepo.getAgendaUtente(user.id, soloFuturi = true)
                    result.onSuccess { list ->
                        _impegni.value = list
                    }
                }
            } finally {
                _isLoading.value = false
            }
        }
    }

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
            result.onSuccess {
                loadAgenda()
                onSuccess()
            }
        }
    }

    class AgendaViewModelFactory(
        private val context: Context
    ) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(AgendaUtenteViewModel::class.java)) {
                val database = ContextAwareDatabase.getDatabase(context)
                val agendaApi = ApiClient.retrofit.create(AgendaUtenteApi::class.java)
                val poiApi = ApiClient.retrofit.create(PoiApi::class.java)

                val agendaRepo = AgendaUtenteRepository(agendaApi)
                val poiRepo = PoiRepository(poiApi, database.poiDao() )


                val sessionManager = SessionManager(context)

                @Suppress("UNCHECKED_CAST")
                return AgendaUtenteViewModel(agendaRepo, poiRepo, sessionManager) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class")
        }
    }
}

