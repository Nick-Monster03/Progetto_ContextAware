package com.example.myapplication.data.repository

import android.location.Location
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

object LocationRepository {
    private val _currentLocation = MutableStateFlow<Location?>(null)
    val currentLocation: StateFlow<Location?> = _currentLocation.asStateFlow()

    fun updateLocation(location: Location) {
        _currentLocation.value = location
    }

    fun clearLocation() {
        _currentLocation.value = null
    }
}