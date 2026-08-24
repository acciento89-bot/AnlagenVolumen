package de.kamilunavo.volumecalc

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
internal fun AddItemDialog(onDismiss: () -> Unit, onAdd: (UiItem) -> Unit) {
    var mode by remember { mutableIntStateOf(0) }
    var quantity by remember { mutableStateOf("1") }

    val pipeUsages = listOf("Rohrleitung", "Fußbodenheizung", "Wandheizung", "Deckenheizung")
    var pipeUsageIndex by remember { mutableIntStateOf(0) }
    var pipeUsageMenu by remember { mutableStateOf(false) }
    var selectedPipeIndex by remember { mutableIntStateOf(8) }
    var customPipe by remember { mutableStateOf(false) }
    var pipeMenu by remember { mutableStateOf(false) }
    var length by remember { mutableStateOf("100") }
    var diameter by remember { mutableStateOf("12") }

    val radiatorTypes = remember { ReferenceData.radiators.keys.sorted() }
    var radiatorMode by remember { mutableIntStateOf(0) }
    var radiatorType by remember { mutableStateOf("22") }
    var radiatorHeight by remember { mutableIntStateOf(600) }
    var typeMenu by remember { mutableStateOf(false) }
    var heightMenu by remember { mutableStateOf(false) }
    var radiatorLength by remember { mutableStateOf("1000") }
    var sections by remember { mutableStateOf("10") }
    var sectionIndex by remember { mutableIntStateOf(0) }
    var sectionMenu by remember { mutableStateOf(false) }
    var radiatorManualName by remember { mutableStateOf("Heizkörper (Herstellerwert)") }
    var radiatorManualLiters by remember { mutableStateOf("6.6") }

    var manualName by remember { mutableStateOf("Pufferspeicher") }
    var manualLiters by remember { mutableStateOf("100") }

    val q = quantity.numberOrZero()
    val selectedPipe = ReferenceData.pipes.getOrElse(selectedPipeIndex) { ReferenceData.pipes.first() }
    val pipeDiameter = if (customPipe) diameter.numberOrZero() else selectedPipe.innerDiameterMm
    val pipeTotal = VolumeCalculator.pipeVolumeLiters(pipeDiameter, length.numberOrZero()) * q

    val radiatorReference = ReferenceData.radiators[radiatorType]?.get(radiatorHeight) ?: 0.0
    val panelTotal = VolumeCalculator.radiatorVolumeLiters(radiatorReference, radiatorLength.numberOrZero(), q)
    val sectionMaterial = if (radiatorMode == 1) "Stahl" else "Guss"
    val sectionReferences = ReferenceData.sectionRadiators.filter { it.material == sectionMaterial }
    val sectionReference = sectionReferences.getOrNull(sectionIndex) ?: sectionReferences.firstOrNull()
    val sectionTotal = sectionReference?.let {
        VolumeCalculator.sectionRadiatorVolumeLiters(it.litersPerSection, sections.numberOrZero(), q)
    } ?: 0.0
    val radiatorManualTotal = radiatorManualLiters.numberOrZero() * q
    val radiatorTotal = when (radiatorMode) {
        0 -> panelTotal
        1, 2 -> sectionTotal
        else -> radiatorManualTotal
    }

    val manualTotal = manualLiters.numberOrZero() * q
    val result = when (mode) {
        0 -> pipeTotal
        1 -> radiatorTotal
        else -> manualTotal
    }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Bauteil hinzufügen") },
        text = {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                item {
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        FilterChip(selected = mode == 0, onClick = { mode = 0 }, label = { Text("Rohr / Fläche") })
                        FilterChip(selected = mode == 1, onClick = { mode = 1 }, label = { Text("Heizkörper") })
                        FilterChip(selected = mode == 2, onClick = { mode = 2 }, label = { Text("Komponente") })
                    }
                }

                when (mode) {
                    0 -> {
                        item {
                            Box {
                                OutlinedButton(onClick = { pipeUsageMenu = true }, modifier = Modifier.fillMaxWidth()) {
                                    Text(pipeUsages[pipeUsageIndex])
                                }
                                DropdownMenu(expanded = pipeUsageMenu, onDismissRequest = { pipeUsageMenu = false }) {
                                    pipeUsages.forEachIndexed { index, label ->
                                        DropdownMenuItem(
                                            text = { Text(label) },
                                            onClick = { pipeUsageIndex = index; pipeUsageMenu = false }
                                        )
                                    }
                                }
                            }
                        }
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
                            if (selectedPipe.note.isNotBlank()) {
                                item { Text(selectedPipe.note, color = Muted, fontSize = 12.sp) }
                            }
                        }
                        item { NumberInput("Länge je Strang/Kreis (m)", length) { length = it } }
                        item { NumberInput("Anzahl / Heizkreise", quantity) { quantity = it } }
                        item { Text("Ø innen ${format(pipeDiameter, 1)} mm", color = Muted, fontSize = 12.sp) }
                    }

                    1 -> {
                        item {
                            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                    FilterChip(selected = radiatorMode == 0, onClick = { radiatorMode = 0 }, label = { Text("Platte") })
                                    FilterChip(selected = radiatorMode == 1, onClick = { radiatorMode = 1; sectionIndex = 0 }, label = { Text("Stahl-Glied") })
                                }
                                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                    FilterChip(selected = radiatorMode == 2, onClick = { radiatorMode = 2; sectionIndex = 0 }, label = { Text("Guss-Glied") })
                                    FilterChip(selected = radiatorMode == 3, onClick = { radiatorMode = 3 }, label = { Text("Manuell") })
                                }
                            }
                        }

                        when (radiatorMode) {
                            0 -> {
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
                                item {
                                    Text(
                                        "Purmo Referenz: ${format(radiatorReference, 1)} l je lfd. m. Herstellerdaten haben Vorrang.",
                                        color = Muted,
                                        fontSize = 12.sp
                                    )
                                }
                            }

                            1, 2 -> {
                                item {
                                    Box {
                                        OutlinedButton(onClick = { sectionMenu = true }, modifier = Modifier.fillMaxWidth()) {
                                            Text(sectionReference?.let { "${it.displayName} · ${format(it.litersPerSection, 3)} l/Glied" } ?: "Referenz wählen")
                                        }
                                        DropdownMenu(expanded = sectionMenu, onDismissRequest = { sectionMenu = false }) {
                                            sectionReferences.forEachIndexed { index, ref ->
                                                DropdownMenuItem(
                                                    text = { Text("${ref.displayName} · ${format(ref.litersPerSection, 3)} l/Glied") },
                                                    onClick = { sectionIndex = index; sectionMenu = false }
                                                )
                                            }
                                        }
                                    }
                                }
                                item { NumberInput("Glieder je Heizkörper", sections) { sections = it } }
                                item {
                                    Text(
                                        sectionReference?.source ?: "Bestands-/Normreferenz; Herstellerwert prüfen.",
                                        color = Muted,
                                        fontSize = 12.sp
                                    )
                                }
                            }

                            else -> {
                                item {
                                    OutlinedTextField(
                                        value = radiatorManualName,
                                        onValueChange = { radiatorManualName = it },
                                        label = { Text("Bezeichnung") },
                                        singleLine = true,
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }
                                item { NumberInput("Liter je Heizkörper", radiatorManualLiters) { radiatorManualLiters = it } }
                            }
                        }
                        item { NumberInput("Anzahl Heizkörper", quantity) { quantity = it } }
                    }

                    else -> {
                        item {
                            OutlinedTextField(
                                value = manualName,
                                onValueChange = { manualName = it },
                                label = { Text("Puffer / Wärmeerzeuger / Weiche / Verteiler / Wärmetauscher") },
                                singleLine = true,
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                        item { NumberInput("Liter je Stück", manualLiters) { manualLiters = it } }
                        item { NumberInput("Anzahl", quantity) { quantity = it } }
                        item { Text("Hersteller-, Typenschild- oder Messwert verwenden.", color = Muted, fontSize = 12.sp) }
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
                            name = if (customPipe) {
                                "${pipeUsages[pipeUsageIndex]} · Ø innen ${format(pipeDiameter, 1)} mm"
                            } else {
                                "${pipeUsages[pipeUsageIndex]} · ${selectedPipe.group} · ${selectedPipe.name}"
                            },
                            liters = result,
                            kind = pipeUsages[pipeUsageIndex],
                            source = if (customPipe) "Manueller Innendurchmesser" else selectedPipe.note.takeIf { it.isNotBlank() }
                        )

                        1 -> when (radiatorMode) {
                            0 -> UiItem(
                                name = "Plattenheizkörper Typ $radiatorType · H$radiatorHeight · L${format(radiatorLength.numberOrZero(), 0)}",
                                liters = result,
                                kind = "Heizkörper",
                                source = "Purmo Plan Compact Referenztabelle"
                            )
                            1, 2 -> UiItem(
                                name = sectionReference?.let {
                                    "${it.material}-Gliederheizkörper · ${it.displayName} · ${format(sections.numberOrZero(), 0)} Glieder"
                                } ?: "Gliederheizkörper",
                                liters = result,
                                kind = "Heizkörper",
                                source = sectionReference?.source
                            )
                            else -> UiItem(
                                name = radiatorManualName.ifBlank { "Heizkörper (Herstellerwert)" },
                                liters = result,
                                kind = "Heizkörper",
                                source = "Hersteller-/Nutzereingabe"
                            )
                        }

                        else -> UiItem(
                            name = manualName.ifBlank { "Wasserführende Anlagenkomponente" },
                            liters = result,
                            kind = "Anlagenkomponente",
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
