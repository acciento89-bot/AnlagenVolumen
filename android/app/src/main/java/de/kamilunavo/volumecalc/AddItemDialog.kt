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
internal fun AddItemDialog(onDismiss: () -> Unit, onAdd: (UiItem) -> Unit) {
    var mode by remember { mutableIntStateOf(0) }
    var quantity by remember { mutableStateOf("1") }

    var selectedPipeIndex by remember { mutableIntStateOf(8) }
    var customPipe by remember { mutableStateOf(false) }
    var pipeMenu by remember { mutableStateOf(false) }
    var length by remember { mutableStateOf("100") }
    var diameter by remember { mutableStateOf("12") }

    val radiatorTypes = remember { ReferenceData.radiators.keys.sorted() }
    var radiatorType by remember { mutableStateOf("22") }
    var radiatorHeight by remember { mutableIntStateOf(600) }
    var typeMenu by remember { mutableStateOf(false) }
    var heightMenu by remember { mutableStateOf(false) }
    var radiatorLength by remember { mutableStateOf("1000") }

    var manualName by remember { mutableStateOf("Puffer / Wärmeerzeuger") }
    var manualLiters by remember { mutableStateOf("50") }

    val q = quantity.numberOrZero()
    val selectedPipe = ReferenceData.pipes.getOrElse(selectedPipeIndex) { ReferenceData.pipes.first() }
    val pipeDiameter = if (customPipe) diameter.numberOrZero() else selectedPipe.innerDiameterMm
    val pipeTotal = VolumeCalculator.pipeVolumeLiters(pipeDiameter, length.numberOrZero()) * q
    val radiatorReference = ReferenceData.radiators[radiatorType]?.get(radiatorHeight) ?: 0.0
    val radiatorTotal = VolumeCalculator.radiatorVolumeLiters(radiatorReference, radiatorLength.numberOrZero(), q)
    val manualTotal = manualLiters.numberOrZero() * q
    val result = when (mode) { 0 -> pipeTotal; 1 -> radiatorTotal; else -> manualTotal }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Bauteil hinzufügen") },
        text = {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                item {
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        FilterChip(selected = mode == 0, onClick = { mode = 0 }, label = { Text("Rohr / FBH") })
                        FilterChip(selected = mode == 1, onClick = { mode = 1 }, label = { Text("Heizkörper") })
                        FilterChip(selected = mode == 2, onClick = { mode = 2 }, label = { Text("Gerät") })
                    }
                }

                when (mode) {
                    0 -> {
                        item { SwitchRow("Eigenen Innendurchmesser", customPipe) { customPipe = it } }
                        if (customPipe) {
                            item { NumberInput("Innendurchmesser mm", diameter) { diameter = it } }
                        } else {
                            item {
                                Box {
                                    OutlinedButton(onClick = { pipeMenu = true }, modifier = Modifier.fillMaxWidth()) {
                                        Text("${selectedPipe.group} · ${selectedPipe.name}")
                                    }
                                    DropdownMenu(expanded = pipeMenu, onDismissRequest = { pipeMenu = false }) {
                                        ReferenceData.pipes.forEachIndexed { index, preset ->
                                            DropdownMenuItem(
                                                text = { Text("${preset.group} · ${preset.name}") },
                                                onClick = { selectedPipeIndex = index; pipeMenu = false }
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        item { NumberInput("Länge je Strang/Kreis (m)", length) { length = it } }
                        item { NumberInput("Anzahl / Heizkreise", quantity) { quantity = it } }
                        item { Text("Ø innen ${format(pipeDiameter, 1)} mm", color = Muted, fontSize = 12.sp) }
                    }
                    1 -> {
                        item {
                            Box {
                                OutlinedButton(onClick = { typeMenu = true }, modifier = Modifier.fillMaxWidth()) {
                                    Text("Typ $radiatorType")
                                }
                                DropdownMenu(expanded = typeMenu, onDismissRequest = { typeMenu = false }) {
                                    radiatorTypes.forEach { type ->
                                        DropdownMenuItem(
                                            text = { Text("Typ $type") },
                                            onClick = {
                                                radiatorType = type
                                                radiatorHeight = ReferenceData.radiators[type]?.keys?.sorted()?.firstOrNull() ?: 600
                                                typeMenu = false
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        item {
                            val heights = ReferenceData.radiators[radiatorType]?.keys?.sorted().orEmpty()
                            Box {
                                OutlinedButton(onClick = { heightMenu = true }, modifier = Modifier.fillMaxWidth()) {
                                    Text("Bauhöhe $radiatorHeight mm")
                                }
                                DropdownMenu(expanded = heightMenu, onDismissRequest = { heightMenu = false }) {
                                    heights.forEach { height ->
                                        DropdownMenuItem(
                                            text = { Text("$height mm") },
                                            onClick = { radiatorHeight = height; heightMenu = false }
                                        )
                                    }
                                }
                            }
                        }
                        item { NumberInput("Baulänge (mm)", radiatorLength) { radiatorLength = it } }
                        item { NumberInput("Anzahl", quantity) { quantity = it } }
                        item {
                            Text(
                                "Purmo Plan Compact Referenz: ${format(radiatorReference, 1)} l je lfd. m. Herstellerdaten haben Vorrang.",
                                color = Muted,
                                fontSize = 12.sp
                            )
                        }
                    }
                    else -> {
                        item {
                            OutlinedTextField(
                                value = manualName,
                                onValueChange = { manualName = it },
                                label = { Text("Bezeichnung") },
                                singleLine = true,
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                        item { NumberInput("Liter je Stück", manualLiters) { manualLiters = it } }
                        item { NumberInput("Anzahl", quantity) { quantity = it } }
                    }
                }

                item {
                    Text("${format(result, 2)} l", fontSize = 26.sp, fontWeight = FontWeight.Bold, color = Accent)
                }
            }
        },
        confirmButton = {
            Button(
                enabled = result > 0,
                onClick = {
                    val item = when (mode) {
                        0 -> UiItem(
                            name = if (customPipe) "Rohr Ø innen ${format(pipeDiameter, 1)} mm" else selectedPipe.name,
                            liters = result,
                            kind = "Rohrleitung / FBH",
                            source = if (customPipe) "Manueller Innendurchmesser" else selectedPipe.note.takeIf { it.isNotBlank() }
                        )
                        1 -> UiItem(
                            name = "Heizkörper Typ $radiatorType · H$radiatorHeight · L${format(radiatorLength.numberOrZero(), 0)}",
                            liters = result,
                            kind = "Heizkörper",
                            source = "Purmo Plan Compact Referenztabelle"
                        )
                        else -> UiItem(
                            name = manualName.ifBlank { "Manueller Wasserinhalt" },
                            liters = result,
                            kind = "Manueller Wert",
                            source = "Hersteller-/Nutzereingabe"
                        )
                    }
                    onAdd(item)
                }
            ) { Text("Hinzufügen") }
        },
        dismissButton = { TextButton(onClick = onDismiss) { Text("Abbrechen") } }
    )
}
