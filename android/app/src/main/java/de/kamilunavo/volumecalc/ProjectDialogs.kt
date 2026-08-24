package de.kamilunavo.volumecalc

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale
import java.util.UUID
@Composable
internal fun ProjectSettingsDialog(project: UiProject, onDismiss: () -> Unit, onSave: (UiProject) -> Unit) {
    var name by remember(project.id) { mutableStateOf(project.name) }
    var reserve by remember(project.id) { mutableStateOf(project.reservePercent.toString()) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Projekt") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Projektname") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
                NumberInput("Planungsreserve (%)", reserve) { reserve = it }
                Text("Die Reserve wird getrennt vom real berechneten Anlageninhalt ausgewiesen.", color = Muted, fontSize = 12.sp)
            }
        },
        confirmButton = {
            Button(onClick = {
                onSave(project.copy(name = name.ifBlank { "Neue Anlage" }, reservePercent = reserve.numberOrZero()))
            }) { Text("Speichern") }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Abbrechen") } }
    )
}

@Composable
internal fun ProjectDialog(
    projects: List<UiProject>,
    selectedProjectId: String,
    onDismiss: () -> Unit,
    onSelect: (String) -> Unit,
    onCreate: (String) -> Unit,
    onDelete: (String) -> Unit
) {
    var newName by remember { mutableStateOf("") }
    var creating by remember { mutableStateOf(false) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Projekte") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                projects.forEach { project ->
                    Card(
                        colors = CardDefaults.cardColors(
                            containerColor = if (project.id == selectedProjectId) Accent.copy(alpha = 0.16f) else Panel
                        )
                    ) {
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .padding(12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(Modifier.weight(1f)) {
                                Text(project.name, fontWeight = FontWeight.Bold)
                                Text("${format(project.calculatedVolumeLiters, 1)} l · ${project.items.size} Bauteile", color = Muted, fontSize = 12.sp)
                            }
                            TextButton(onClick = { onSelect(project.id) }) { Text("Öffnen") }
                            if (projects.size > 1) TextButton(onClick = { onDelete(project.id) }) { Text("×") }
                        }
                    }
                }

                if (creating) {
                    OutlinedTextField(
                        value = newName,
                        onValueChange = { newName = it },
                        label = { Text("Neuer Projektname") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Button(onClick = { onCreate(newName) }, modifier = Modifier.fillMaxWidth()) { Text("Projekt erstellen") }
                } else {
                    OutlinedButton(onClick = { creating = true }, modifier = Modifier.fillMaxWidth()) { Text("+ Neues Projekt") }
                }
            }
        },
        confirmButton = { TextButton(onClick = onDismiss) { Text("Fertig") } }
    )
}

@Composable
internal fun NumberInput(label: String, value: String, onValueChange: (String) -> Unit) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        singleLine = true,
        modifier = Modifier.fillMaxWidth()
    )
}

@Composable
internal fun SwitchRow(label: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(label, modifier = Modifier.weight(1f))
        Switch(checked = checked, onCheckedChange = onCheckedChange)
    }
}

internal fun String.numberOrZero(): Double = replace(',', '.').toDoubleOrNull()?.coerceAtLeast(0.0) ?: 0.0

internal fun format(value: Double, digits: Int): String =
    String.format(Locale.GERMANY, "%.${digits}f", value)

internal fun exportText(project: UiProject): String = buildString {
    append("VolumeCalc – ${project.name}")
    append("\nBerechnet: ${format(project.calculatedVolumeLiters, 1)} l")
    append("\nPlanungswert (+${format(project.reservePercent, 1)} %): ${format(project.planningVolumeLiters, 1)} l")
    project.items.forEach { append("\n• ${it.name}: ${format(it.liters, 2)} l") }
}
