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
internal fun VolumeCalcApp(
    repository: ProjectRepository,
    onShare: (String) -> Unit
) {
    var projects by remember { mutableStateOf(repository.load()) }
    var selectedProjectId by remember { mutableStateOf(projects.first().id) }
    var showAdd by remember { mutableStateOf(false) }
    var showProjects by remember { mutableStateOf(false) }
    var showSettings by remember { mutableStateOf(false) }

    val project = projects.firstOrNull { it.id == selectedProjectId } ?: projects.first()

    fun updateProject(updated: UiProject) {
        projects = projects.map { if (it.id == updated.id) updated else it }
        repository.save(projects)
    }

    fun addProject(name: String) {
        val newProject = UiProject(name = name.ifBlank { "Neue Anlage" })
        projects = listOf(newProject) + projects
        selectedProjectId = newProject.id
        repository.save(projects)
    }

    fun deleteProject(projectId: String) {
        val remaining = projects.filterNot { it.id == projectId }.ifEmpty { listOf(UiProject()) }
        projects = remaining
        if (remaining.none { it.id == selectedProjectId }) selectedProjectId = remaining.first().id
        repository.save(projects)
    }

    MaterialTheme(colorScheme = darkColorScheme(primary = Accent, surface = Bg1)) {
        Box(
            Modifier
                .fillMaxSize()
                .background(Brush.linearGradient(listOf(Bg1, Bg2)))
        ) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(18.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                item {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Column(Modifier.weight(1f)) {
                            Text("VolumeCalc", fontSize = 30.sp, fontWeight = FontWeight.Bold)
                            Text(project.name, fontSize = 18.sp, fontWeight = FontWeight.SemiBold, color = Accent)
                            Text("Anlageninhalt aus realen Bauteilen statt Bauchgefühl.", color = Muted)
                        }
                        TextButton(onClick = { showProjects = true }) { Text("Projekte") }
                    }
                }

                item { ResultCard(project = project, onSettings = { showSettings = true }) }

                if (project.items.isEmpty()) {
                    item {
                        Card(
                            colors = CardDefaults.cardColors(containerColor = Panel),
                            shape = RoundedCornerShape(20.dp)
                        ) {
                            Column(
                                Modifier.padding(18.dp),
                                verticalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Text("Noch keine Bauteile", fontWeight = FontWeight.Bold)
                                Text(
                                    "Rohrleitungen, FBH, Heizkörper sowie bekannte Geräte- und Speicherinhalte hinzufügen.",
                                    color = Muted
                                )
                            }
                        }
                    }
                }

                items(project.items, key = { it.id }) { item ->
                    ComponentCard(item = item) {
                        updateProject(project.copy(items = project.items.filterNot { it.id == item.id }))
                    }
                }

                item {
                    Button(onClick = { showAdd = true }, modifier = Modifier.fillMaxWidth()) {
                        Text("+ Bauteil hinzufügen")
                    }
                    Spacer(Modifier.height(8.dp))
                    OutlinedButton(
                        onClick = { onShare(exportText(project)) },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Ergebnis teilen")
                    }
                    Spacer(Modifier.height(8.dp))
                    Text(
                        "Rohrvolumen wird geometrisch aus dem Innendurchmesser berechnet. Heizkörper-Referenzwerte sind baureihenspezifisch; Herstellerangaben haben Vorrang.",
                        fontSize = 12.sp,
                        color = Muted
                    )
                }
            }
        }

        if (showAdd) {
            AddItemDialog(
                onDismiss = { showAdd = false },
                onAdd = { item ->
                    updateProject(project.copy(items = project.items + item))
                    showAdd = false
                }
            )
        }

        if (showProjects) {
            ProjectDialog(
                projects = projects,
                selectedProjectId = selectedProjectId,
                onDismiss = { showProjects = false },
                onSelect = {
                    selectedProjectId = it
                    showProjects = false
                },
                onCreate = {
                    addProject(it)
                    showProjects = false
                },
                onDelete = ::deleteProject
            )
        }

        if (showSettings) {
            ProjectSettingsDialog(
                project = project,
                onDismiss = { showSettings = false },
                onSave = {
                    updateProject(it)
                    showSettings = false
                }
            )
        }
    }
}

@Composable
internal fun ResultCard(project: UiProject, onSettings: () -> Unit) {
    Card(
        colors = CardDefaults.cardColors(containerColor = Panel),
        shape = RoundedCornerShape(22.dp)
    ) {
        Column(
            Modifier.padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text("BERECHNET", color = Muted, fontSize = 12.sp)
            Row(verticalAlignment = Alignment.Bottom) {
                Text(
                    format(project.calculatedVolumeLiters, 1),
                    fontSize = 40.sp,
                    fontWeight = FontWeight.Bold,
                    color = Accent
                )
                Text(" l", fontSize = 18.sp)
                Spacer(Modifier.weight(1f))
                Text("Plan: ${format(project.planningVolumeLiters, 1)} l", fontWeight = FontWeight.Bold)
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("inkl. ${format(project.reservePercent, 1)} % Planungsreserve", color = Muted, fontSize = 12.sp)
                Spacer(Modifier.weight(1f))
                TextButton(onClick = onSettings) { Text("Ändern") }
            }
        }
    }
}

@Composable
internal fun ComponentCard(item: UiItem, onDelete: () -> Unit) {
    Card(
        colors = CardDefaults.cardColors(containerColor = Panel),
        shape = RoundedCornerShape(18.dp)
    ) {
        Row(
            Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(Modifier.weight(1f)) {
                Text(item.name, fontWeight = FontWeight.Bold)
                Text(item.kind, fontSize = 12.sp, color = Muted)
                item.source?.let { Text(it, fontSize = 11.sp, color = Muted) }
            }
            Column(horizontalAlignment = Alignment.End) {
                Text("${format(item.liters, 2)} l", fontWeight = FontWeight.Bold)
                TextButton(onClick = onDelete, contentPadding = PaddingValues(0.dp)) { Text("Löschen") }
            }
        }
    }
}
