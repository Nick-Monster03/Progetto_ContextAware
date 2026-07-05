package com.example.myapplication.ui.map

import android.content.Context
import android.health.connect.datatypes.ExerciseRoute
import android.util.Log
import androidx.compose.ui.text.toLowerCase
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.myapplication.data.model.CategoriaPOIPublic
import com.example.myapplication.data.model.EventoPublic
import com.example.myapplication.data.model.POIPublic
import com.example.myapplication.data.remote.api.CategoriaPOIApi
import com.example.myapplication.data.remote.api.PoiApi
import com.example.myapplication.data.remote.api.RaccomandationApi
import com.example.myapplication.data.repository.CategoriaPOIRepository
import com.example.myapplication.data.repository.LocationRepository
import com.example.myapplication.data.repository.PoiRepository
import com.example.myapplication.data.repository.RaccomandationRepository
import com.example.myapplication.utils.ApiClient
import com.example.myapplication.utils.SessionManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import java.util.Locale
import android.location.Location
import com.example.myapplication.data.model.RankingResult
import kotlinx.coroutines.flow.firstOrNull
import java.util.Locale.getDefault

class MapViewModel(
    private val poiRepository: PoiRepository,
    private val categoriaRepository: CategoriaPOIRepository,
    private val raccomandationRepository: RaccomandationRepository,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _poiList = MutableStateFlow<List<POIPublic>>(emptyList())
    val poiList: StateFlow<List<POIPublic>> = _poiList.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _categories = MutableStateFlow<List<CategoriaPOIPublic>>(emptyList())
    val categories: StateFlow<List<CategoriaPOIPublic>> = _categories.asStateFlow()

    private val _selectedCategories = MutableStateFlow<Set<Int>>(emptySet())
    val selectedCategories: StateFlow<Set<Int>> = _selectedCategories.asStateFlow()

    private val _maxDistance = MutableStateFlow<Double?>(null)
    val maxDistance: StateFlow<Double?> = _maxDistance.asStateFlow()

    private val _orarioApertura = MutableStateFlow<String?>(null)
    val orarioApertura: StateFlow<String?> = _orarioApertura.asStateFlow()

    private val _orarioChiusura = MutableStateFlow<String?>(null)
    val orarioChiusura: StateFlow<String?> = _orarioChiusura.asStateFlow()
    private val _selectedPoi = MutableStateFlow<POIPublic?>(null)
    val selectedPoi: StateFlow<POIPublic?> = _selectedPoi.asStateFlow()

    private val _campus = MutableStateFlow<String?>(null)
    val campus: StateFlow<String?> = _campus.asStateFlow()

    private val _filterError = MutableStateFlow<String?>(null)
    val filterError: StateFlow<String?> = _filterError.asStateFlow()
    val userLocation = LocationRepository.currentLocation
    private val _suggestionEvent = MutableStateFlow<EventoPublic?>(null)
    val suggestionEvent: StateFlow<EventoPublic?> = _suggestionEvent.asStateFlow()

    private val _rankingList = MutableStateFlow<List<RankingResult>>(emptyList())
    val rankingList: StateFlow<List<RankingResult>> = _rankingList.asStateFlow()

    private val _showRankingSheet = MutableStateFlow(false)
    val showRankingSheet: StateFlow<Boolean> = _showRankingSheet.asStateFlow()

    private var lastSuggestionLocation: Location? = null
    private val _uiMessage = MutableStateFlow<String?>(null)
    val uiMessage: StateFlow<String?> = _uiMessage.asStateFlow()



    init {
        fetchCategories()
        applyFilters()

        viewModelScope.launch {
            Log.d("MapViewModel", "Inizio routine Context-Aware: attesa utente dal SessionManager...")

            val user = sessionManager.loggedUser.first()
            Log.d("MapViewModel", "Utente recuperato: ${user?.id} (se è null, il suggerimento non partirà)")

            userLocation.collect { currentLoc ->
                if (currentLoc == null) {
                    Log.d("MapViewModel", "GPS: Posizione attuale è null, attendo...")
                } else {
                    Log.d("MapViewModel", "GPS: Nuova posizione ricevuta [Lat: ${currentLoc.latitude}, Lon: ${currentLoc.longitude}]")

                    if (user != null) {
                        val distance = lastSuggestionLocation?.distanceTo(currentLoc) ?: Float.MAX_VALUE
                        Log.d("MapViewModel", "Distanza dall'ultimo suggerimento: $distance metri")

                        if (distance > 100f) {
                            Log.d("MapViewModel", "Spostamento significativo! Lancio getContextualSuggestion per utente ${user.id}...")
                            lastSuggestionLocation = currentLoc
                            getContextualSuggestion(idUtente = user.id)
                        } else {
                            Log.d("MapViewModel", "Spostamento troppo piccolo (<100m). Nessun nuovo suggerimento.")
                        }
                    } else {
                        Log.w("MapViewModel", "ATTENZIONE: user è null, non posso richiedere il suggerimento!")
                    }
                }
            }
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

    fun setMaxDistance(distance: Double?) {
        _maxDistance.value = distance
    }

    fun setOrarioApertura(time: String?) {
        _orarioApertura.value = time
    }

    fun setOrarioChiusura(time: String?) {
        _orarioChiusura.value = time
    }

    fun setCampus(nomeCampus: String?) {
            val formattedCampus = nomeCampus?.trim()?.lowercase()?.replaceFirstChar {
            if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
        }?.ifBlank { null }

        _campus.value = formattedCampus
    }

    fun clearFilterError() {
        _filterError.value = null
    }

    fun selectPoi(poi: POIPublic) {
        _selectedPoi.value = poi
    }

    fun clearSelectedPoi() {
        _selectedPoi.value = null
    }

    fun getCategoryNameForPoi(poi: POIPublic): String {
        val category = _categories.value.find { it.id == poi.id_categoria }
        return category?.nome?.toString() ?: "-"
    }

    fun applyFilters(userLat: Double? = 44.4949, userLon: Double? = 11.3426) {

        val apertura = _orarioApertura.value
        val chiusura = _orarioChiusura.value
        if (apertura != null && chiusura != null) {
            if (apertura > chiusura) {
                _filterError.value = "L'orario di apertura non può essere successivo alla chiusura."
                return
            }
        }
        _filterError.value = null

        _isLoading.value = true
        val categoriesList = _selectedCategories.value.toList().ifEmpty { null }

        val finalLat = if (_maxDistance.value != null) userLat else null
        val finalLon = if (_maxDistance.value != null) userLon else null

        viewModelScope.launch {
            val result = poiRepository.getFilteredPois(
                lat = finalLat,
                lon = finalLon,
                idCategoria = categoriesList,
                maxDistanceMeters = _maxDistance.value,
                orarioApertura = apertura,
                orarioChiusura = chiusura,
                campus = _campus.value
            )

            result.fold(
                onSuccess = { pois ->
                    _poiList.value = pois
                    _isLoading.value = false
                    //DEBUG:
                    val nomiPoi = pois.joinToString { it.nome }
                    Log.d("MapViewModel", "Filtri applicati! Trovati ${pois.size} POI: $nomiPoi")
                },
                onFailure = {
                    _isLoading.value = false
                    _filterError.value = "Errore durante il recupero dei dati"
                }
            )
        }
    }

    fun getContextualSuggestion(idUtente: Int) {
        val currentLoc = userLocation.value

        if (currentLoc != null) {
            viewModelScope.launch {
                val result = raccomandationRepository.generateStartupSuggestion(
                    idUtente = idUtente,
                    lat = currentLoc.latitude,
                    lon = currentLoc.longitude
                )

                result.fold(
                    onSuccess = { evento ->
                        _suggestionEvent.value = evento
                        Log.d("MapViewModel", "Suggerimento ricevuto: ${evento.messaggio}")
                    },
                    onFailure = { error ->
                        Log.e("MapViewModel", "Errore suggerimento: ${error.message}")
                    }
                )
            }
        } else {
            Log.w("MapViewModel", "Impossibile suggerire: Posizione GPS non ancora disponibile")
        }
    }

    fun dismissSuggestion() {
        _suggestionEvent.value = null
    }

    fun fetchRankingList() {
        Log.d("MapViewModel", "Pulsante 'Servizi Vicini' premuto!")
        val currentLoc = userLocation.value

        viewModelScope.launch {
            val user = sessionManager.loggedUser.firstOrNull()

            Log.d("MapViewModel", "Stato per Ranking - Utente ID: ${user?.id}, Posizione GPS: ${currentLoc?.latitude}, ${currentLoc?.longitude}")

            if (user != null && currentLoc != null) {
                Log.d("MapViewModel", "Avvio chiamata API getRankingList...")
                _isLoading.value = true

                val result = raccomandationRepository.getRankingList(
                    idUtente = user.id,
                    lat = currentLoc.latitude,
                    lon = currentLoc.longitude
                )

                result.fold(
                    onSuccess = { list ->
                        Log.d("MapViewModel", "Chiamata API completata! Trovati ${list.size} servizi.")
                        _rankingList.value = list
                        _showRankingSheet.value = true
                    },
                    onFailure = { error ->
                        Log.e("MapViewModel", "Errore API fetch ranking: ${error.message}")
                    }
                )
                _isLoading.value = false
            } else {
                if (currentLoc == null) {
                    _uiMessage.value = "Attendi il segnale GPS prima di cercare i servizi."
                    Log.w("MapViewModel", "Impossibile caricare il ranking: La posizione GPS non è ancora disponibile!")
                }
                if (user == null) {
                    Log.w(
                        "MapViewModel",
                        "Impossibile caricare il ranking: L'utente non è loggato o il SessionManager è vuoto!"
                    )
                }
            }
        }
    }

    fun dismissRankingSheet() {
        _showRankingSheet.value = false
    }

    fun clearUiMessage() { _uiMessage.value = null }

    class MapViewModelFactory(private val context: Context) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(MapViewModel::class.java)) {
                val poiApi = ApiClient.retrofit.create(PoiApi::class.java)
                val categoriaApi = ApiClient.retrofit.create(CategoriaPOIApi::class.java)
                val sessionManager = SessionManager(context)

                val raccomandationApi = ApiClient.retrofit.create(RaccomandationApi::class.java)
                val raccomandationRepository = RaccomandationRepository(raccomandationApi)

                val poiRepository = PoiRepository(poiApi)
                val categoriaRepository = CategoriaPOIRepository(categoriaApi)

                @Suppress("UNCHECKED_CAST")
                return MapViewModel(poiRepository, categoriaRepository, raccomandationRepository, sessionManager) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}