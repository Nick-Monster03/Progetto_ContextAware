package com.example.myapplication.ui.map

import android.content.Context
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

class MapViewModel(
    private val poiRepository: PoiRepository,
    private val categoriaRepository: CategoriaPOIRepository
) : ViewModel() {

    private val _poiList = MutableStateFlow<List<POIPublic>>(emptyList())
    val poiList: StateFlow<List<POIPublic>> = _poiList.asStateFlow()

    private val _categories = MutableStateFlow<List<CategoriaPOIPublic>>(emptyList())
    val categories: StateFlow<List<CategoriaPOIPublic>> = _categories.asStateFlow()

    private val _selectedCategoryId = MutableStateFlow<Int?>(null)
    val selectedCategoryId: StateFlow<Int?> = _selectedCategoryId.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    init {
        fetchCategories()
        fetchPois()
    }

    private fun fetchCategories() {
        viewModelScope.launch {
            val result = categoriaRepository.getAllCategorie()
            result.onSuccess { list ->
                _categories.value = list
            }
        }
    }


    fun selectCategory(categoryId: Int?) {
        _selectedCategoryId.value = categoryId
        fetchPois()
    }

    fun fetchPois() {
        _isLoading.value = true
        viewModelScope.launch {
            val currentCategory = _selectedCategoryId.value

            val result = if (currentCategory != null) {
                poiRepository.getPoisByCategoria(currentCategory)
            } else {
                poiRepository.getAllPois()
            }

            result.fold(
                onSuccess = { pois ->
                    _poiList.value = pois
                    _isLoading.value = false
                },
                onFailure = {
                    _isLoading.value = false
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