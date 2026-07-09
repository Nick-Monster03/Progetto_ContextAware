package com.example.myapplication.ui.storico

import android.content.Context
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.myapplication.data.model.EventoPublic
import com.example.myapplication.data.model.EventoUpdate
import com.example.myapplication.data.model.FeedbackEvento
import com.example.myapplication.data.remote.api.EventoApi
import com.example.myapplication.data.repository.EventoRepository
import com.example.myapplication.utils.ApiClient
import com.example.myapplication.utils.SessionManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class StoricoViewModel(
    private val repository: EventoRepository,
    private val sessionManager: SessionManager
) : ViewModel() {

    private val _eventi = MutableStateFlow<List<EventoPublic>>(emptyList())
    val eventi: StateFlow<List<EventoPublic>> = _eventi

    private val _isLoading = MutableStateFlow(true)
    val isLoading: StateFlow<Boolean> = _isLoading

    init {
        loadEventi()
    }

    fun loadEventi() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val user = sessionManager.loggedUser.first()
                if (user != null) {
                    val result = repository.getEventiByUtente(user.id)
                    result.onSuccess { list ->
                        _eventi.value = list
                    }
                }
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun submitFeedback(eventoId: Int, feedback: FeedbackEvento) {
        viewModelScope.launch {
            val updateRequest = EventoUpdate(feedback = feedback)
            val result = repository.updateEvento(eventoId, updateRequest)

            result.onSuccess { eventoAggiornato ->
                _eventi.value = _eventi.value.map {
                    if (it.id == eventoId) eventoAggiornato else it
                }
            }
        }
    }

    class StoricoViewModelFactory(private val context: Context) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(StoricoViewModel::class.java)) {
                val eventoApi = ApiClient.retrofit.create(EventoApi::class.java)
                val sessionManager = SessionManager(context)
                val eventoRepository = EventoRepository(eventoApi)

                @Suppress("UNCHECKED_CAST")
                return StoricoViewModel(eventoRepository, sessionManager) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}

