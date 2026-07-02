package com.example.myapplication.ui.login

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.myapplication.data.model.MezzoSpostamento

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterScreen(
    onRegisterClick: (nome: String, cognome: String, password: String, campus: String?, mezzo: String?) -> Unit
) {
    var nome by remember { mutableStateOf("") }
    var cognome by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var campus by remember { mutableStateOf("") }

    // 1. Rendiamo lo stato nullable. Inizialmente è null (nessuna selezione)
    var mezzoSpostamento by remember { mutableStateOf<MezzoSpostamento?>(null) }
    var dropdownExpanded by remember { mutableStateOf(false) }

    Scaffold { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(24.dp)
        ) {
            OutlinedTextField(
                value = nome,
                onValueChange = { nome = it },
                label = { Text("Nome") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(8.dp))

            OutlinedTextField(
                value = cognome,
                onValueChange = { cognome = it },
                label = { Text("Cognome") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(8.dp))

            OutlinedTextField(
                value = password,
                onValueChange = { password = it },
                label = { Text("Password") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(8.dp))

            OutlinedTextField(
                value = campus,
                onValueChange = { campus = it },
                label = { Text("Campus (opzionale)") },
                modifier = Modifier.fillMaxWidth()
            )
            Spacer(modifier = Modifier.height(8.dp))

            ExposedDropdownMenuBox(
                expanded = dropdownExpanded,
                onExpandedChange = { dropdownExpanded = it }
            ) {
                OutlinedTextField(
                    value = mezzoSpostamento?.dbValue ?: "Non specificato (A piedi)",
                    onValueChange = {},
                    readOnly = true,
                    label = { Text("Mezzo di spostamento") },
                    trailingIcon = {
                        ExposedDropdownMenuDefaults.TrailingIcon(expanded = dropdownExpanded)
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .menuAnchor(MenuAnchorType.PrimaryNotEditable)
                )
                ExposedDropdownMenu(
                    expanded = dropdownExpanded,
                    onDismissRequest = { dropdownExpanded = false }
                ) {
                    MezzoSpostamento.entries.forEach { mezzo ->
                        DropdownMenuItem(
                            text = { Text(mezzo.dbValue) },
                            onClick = {
                                mezzoSpostamento = mezzo
                                dropdownExpanded = false
                            }
                        )
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                modifier = Modifier.fillMaxWidth(),
                onClick = {
                    val campusValue = campus.trim().lowercase().replaceFirstChar {
                        if (it.isLowerCase()) it.titlecase() else it.toString()
                    }.ifBlank { null }

                    onRegisterClick(
                        nome.trim(),
                        cognome.trim(),
                        password.trim(),
                        campusValue,
                        mezzoSpostamento?.name
                    )
                }
            ) {
                Text("Registrati")
            }
        }
    }
}