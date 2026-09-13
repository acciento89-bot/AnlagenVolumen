package de.kamilunavo.volumecalc

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Checkbox
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
internal fun FillAuditDialog(
    project: UiProject,
    onDismiss: () -> Unit,
    onSave: (FillCheck) -> Unit,
) {
    var start by remember { mutableStateOf("") }
    var end by remember { mutableStateOf("") }
    var drained by remember { mutableStateOf("0") }
    var tolerance by remember { mutableStateOf("5") }
    var confirmed by remember { mutableStateOf(false) }
    var note by remember { mutableStateOf("") }

    val startValue = start.numberOrNull()
    val endValue = end.numberOrNull()
    val drainedValue = drained.numberOrNull() ?: 0.0
    val toleranceValue = tolerance.numberOrNull()
    val net = if (startValue != null && endValue != null) endValue - startValue - drainedValue else null
    val valid = startValue != null && endValue != null && endValue > startValue &&
        net != null && net > 0 && toleranceValue != null && toleranceValue in 0.0..100.0 && confirmed

    AlertDialog(
        onDismissRequest = {},
        title = { Text("Befüllung erfassen", fontWeight = FontWeight.Bold) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text("Inventar-Basis: ${format(project.calculatedVolumeLiters, 2)} l · ${project.items.size} Bauteile", color = Muted)
                AuditInput("Zählerstand vor Befüllung (l)", start) { start = it }
                AuditInput("Zählerstand nach Befüllung (l)", end) { end = it }
                AuditInput("Abgelassen / verworfen (l)", drained) { drained = it }
                AuditInput("Projekttoleranz ± (%)", tolerance) { tolerance = it }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = confirmed, onCheckedChange = { confirmed = it })
                    Text("Anlage war anfangs leer; Inventar und Messung umfassen dieselben Anlagenteile", modifier = Modifier.weight(1f))
                }
                OutlinedTextField(
                    value = note,
                    onValueChange = { note = it },
                    label = { Text("Messgerät, Systemgrenzen, Entlüftung …") },
                    modifier = Modifier.fillMaxWidth(),
                    minLines = 2,
                )
                if (net != null && net > 0) {
                    Text("Netto eingefüllt: ${format(net, 2)} l", color = Accent, fontWeight = FontWeight.Bold)
                }
                if (!valid) {
                    Text("Zählerende muss über dem Start liegen, Nettofüllung > 0 sein und die Systemgrenzen müssen bestätigt werden.", color = Color(0xFF9C2F2F))
                }
            }
        },
        confirmButton = {
            Button(
                enabled = valid,
                onClick = {
                    onSave(
                        FillCheck(
                            meterStartL = requireNotNull(startValue),
                            meterEndL = requireNotNull(endValue),
                            drainedL = drainedValue,
                            tolerancePercent = requireNotNull(toleranceValue),
                            confirmedEmptySystem = confirmed,
                            calculatedBaselineL = project.calculatedVolumeLiters,
                            componentCount = project.items.size,
                            note = note.trim(),
                        )
                    )
                },
            ) { Text("Speichern") }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Abbrechen") } },
    )
}

@Composable
private fun AuditInput(label: String, value: String, onValue: (String) -> Unit) {
    OutlinedTextField(
        value = value,
        onValueChange = onValue,
        label = { Text(label) },
        modifier = Modifier.fillMaxWidth(),
        singleLine = true,
    )
}

private fun String.numberOrNull(): Double? = replace(',', '.').toDoubleOrNull()?.takeIf { it.isFinite() && it >= 0.0 }
