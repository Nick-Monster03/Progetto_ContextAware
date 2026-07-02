package com.example.myapplication.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.myapplication.MyApplicationApp
import com.example.myapplication.ui.login.AuthState
import com.example.myapplication.ui.login.AuthViewModel
import com.example.myapplication.ui.login.RegisterScreen
import com.example.myapplication.ui.login.LoginScreen

@Composable
fun RootNavigation() {
    val navController = rememberNavController()
    val context = LocalContext.current

    val authViewModel: AuthViewModel = viewModel(
        factory = AuthViewModel.AuthViewModelFactory(context)
    )

    NavHost(navController = navController, startDestination = "login") {

        composable("login") {
            LoginScreen(
                viewModel = authViewModel,
                onLoginSuccess = {
                    navController.navigate("main_app") {
                        popUpTo("login") { inclusive = true }
                    }
                },
                onRegisterClick = {
                    navController.navigate("register")
                }
            )
        }

        composable("register") {
            val authState by authViewModel.authState.collectAsState()

            LaunchedEffect(authState) {
                if (authState is AuthState.Success) {
                    navController.navigate("main_app") {
                        popUpTo("login") { inclusive = true }
                    }
                }
            }

            RegisterScreen(
                onRegisterClick = { nome, cognome, password, campus, mezzo ->
                    authViewModel.register(nome, cognome, password, campus, mezzo)
                }
            )
        }

        composable("main_app") {
            MyApplicationApp()
        }
    }
}