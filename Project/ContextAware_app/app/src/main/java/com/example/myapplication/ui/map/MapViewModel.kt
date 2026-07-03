package com.example.myapplication.ui.map

import android.content.Context
import android.util.Log
import androidx.compose.ui.text.toLowerCase
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.myapplication.data.model.CategoriaPOIPublic
import com.example.myapplication.data.model.POIPublic
import com.example.myapplication.data.remote.api.CategoriaPOIApi
import com.example.myapplication.data.remote.api.PoiApi
import com.example.myapplication.data.repository.CategoriaPOIRepository
import com.example.myapplication.data.repository.PoiRepository
import com.example.myapplication.utils.ApiClient
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.Locale
import java.util.Locale.getDefault

class MapViewModel(
    private val poiRepository: PoiRepository,
    private val categoriaRepository: CategoriaPOIRepository
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

    init {
        fetchCategories()
        applyFilters()
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

    class MapViewModelFactory(private val context: Context) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(MapViewModel::class.java)) {
                val poiApi = ApiClient.retrofit.create(PoiApi::class.java)
                val categoriaApi = ApiClient.retrofit.create(CategoriaPOIApi::class.java)

                val poiRepository = PoiRepository(poiApi)
                val categoriaRepository = CategoriaPOIRepository(categoriaApi)

                @Suppress("UNCHECKED_CAST")
                return MapViewModel(poiRepository, categoriaRepository) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}