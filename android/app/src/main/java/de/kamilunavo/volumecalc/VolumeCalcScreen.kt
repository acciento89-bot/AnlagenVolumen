package de.kamilunavo.volumecalc

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.text.DateFormat
import java.util.Date

@Composable
internal fun VolumeCalcApp(
    repository: ProjectRepository,
    onShare: (String) -> Unit,
) {
    var projects by remember { mutableStateOf(repository.load()) }
    var selectedProjectId by remember { mutableStateOf(projects.first().id) }
    var selectedTab by remember { mutableIntStateOf(0) }
    var showAdd by remember { mutableStateOf(false) }
    var showProjects by remember { mutableStateOf(false) }
    var showSettings by remember { mutableStateOf(false) }
    var showFillAudit by remember { mutableStateOf(false) }

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

    MaterialTheme(
        colorScheme = lightColorScheme(
            primary = Accent,
            secondary = Accent2,
            background = Bg1,
            surface = CardSurface,
            onPrimary = Color.White,
            onBackground = Ink,
            onSurface = Ink,
        )
    ) {
        Scaffold(
            containerColor = Color.Transparent,
            contentWindowInsets = WindowInsets.safeDrawing,
            bottomBar = {
                NavigationBar(containerColor = CardSurface) {
                    NavigationBarItem(
                        selected = selectedTab == 0,
                        onClick = { selectedTab = 0 },
                        icon = { Text("▣", fontSize = 20.sp) },
                        label = { Text("Inventar") },
                    )
                    NavigationBarItem(
                        selected = selectedTab == 1,
                        onClick = { selectedTab = 1 },
                        icon = { Text("◒", fontSize = 20.sp) },
                        label = { Text("Füllabgleich") },
                    )
                }
            },
        ) { scaffoldPadding ->
            Box(
                Modifier
                    .fillMaxSize()
                    .background(Brush.verticalGradient(listOf(Bg1, Bg2)))
                    .padding(scaffoldPadding)
            ) {
                LedgerLines()
                if (selectedTab == 0) {
                    InventoryScreen(
                        project = project,
                        onProjects = { showProjects = true },
                        onAdd = { showAdd = true },
                        onSettings = { showSettings = true },
                        onDelete = { id -> updateProject(project.copy(items = project.items.filterNot { it.id == id })) },
                        onShare = { onShare(exportText(project)) },
                    )
                } else {
                    FillAuditScreen(
                        project = project,
                        onAddAudit = { showFillAudit = true },
                        onDeleteAudit = { id -> updateProject(project.copy(fillChecks = project.fillChecks.filterNot { it.id == id })) },
                        onShare = { onShare(fillEvidenceText(project)) },
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
                },
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
                onDelete = ::deleteProject,
            )
        }

        if (showSettings) {
            ProjectSettingsDialog(
                project = project,
                onDismiss = { showSettings = false },
                onSave = {
                    updateProject(it)
                    showSettings = false
                },
            )
        }

        if (showFillAudit) {
            FillAuditDialog(
                project = project,
                onDismiss = { showFillAudit = false },
                onSave = { check ->
                    updateProject(project.copy(fillChecks = project.fillChecks + check))
                    showFillAudit = false
                },
            )
        }
    }
}

@Composable
private fun InventoryScreen(
    project: UiProject,
    onProjects: () -> Unit,
    onAdd: () -> Unit,
    onSettings: () -> Unit,
    onDelete: (String) -> Unit,
    onShare: () -> Unit,
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(horizontal = 17.dp, vertical = 14.dp),
        verticalArrangement = Arrangement.spacedBy(17.dp),
    ) {
        item { AppBar(onProjects = onProjects, onAdd = onAdd) }
        item { InventoryHero(project) }
        item { PlanningTotal(project, onSettings) }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(11.dp)) {
                ActionCard(
                    modifier = Modifier.weight(1f),
                    title = "Bauteil erfassen",
                    subtitle = "Rohr · Heizkörper · Speicher",
                    primary = true,
                    onClick = onAdd,
                )
                ActionCard(
                    modifier = Modifier.weight(1f),
                    title = "Summen teilen",
                    subtitle = "Für Bericht oder MAG",
                    onClick = onShare,
                )
            }
        }
        item {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Text("BAUTEILLISTE", color = Muted, fontSize = 12.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                    Text("Anlageninhalt nach Komponenten", color = Ink, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                }
                Badge(project.items.size.toString())
            }
        }
        if (project.items.isEmpty()) {
            item {
                LedgerCard {
                    Text("Inventar ist noch leer", fontSize = 18.sp, fontWeight = FontWeight.Bold)
                    Text("Füge zuerst eine reale wasserführende Komponente hinzu.", color = Muted)
                    Button(onClick = onAdd) { Text("Erstes Bauteil hinzufügen") }
                }
            }
        } else {
            itemsIndexed(project.items, key = { _, item -> item.id }) { index, item ->
                ComponentLedgerRow(index + 1, item) { onDelete(item.id) }
            }
        }
        item {
            LedgerCard {
                Text("Berechnungsgrundlage", color = Accent, fontWeight = FontWeight.Bold)
                Text(
                    "Rohrvolumen wird geometrisch aus dem Innendurchmesser berechnet. Rohr- und Heizkörper-Referenzen sind Arbeitshilfen. Für die exakte Auslegung haben Herstellerdaten, Typenschild und eindeutig ermittelte Wasserinhalte Vorrang.",
                    color = Muted,
                    fontSize = 12.sp,
                )
            }
        }
        item { Spacer(Modifier.height(8.dp)) }
    }
}

@Composable
private fun AppBar(onProjects: () -> Unit, onAdd: () -> Unit) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        TextButton(onClick = onProjects) { Text("▰", color = Accent, fontSize = 22.sp) }
        Text("VolumeCalc", modifier = Modifier.weight(1f), textAlign = TextAlign.Center, color = Ink, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        Surface(
            modifier = Modifier.size(38.dp).clickable(onClick = onAdd),
            color = Accent,
            shape = RoundedCornerShape(9.dp),
        ) { Box(contentAlignment = Alignment.Center) { Text("+", color = Color.White, fontSize = 24.sp, fontWeight = FontWeight.Bold) } }
    }
}

@Composable
private fun InventoryHero(project: UiProject) {
    LedgerCard {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(60.dp).background(Accent.copy(alpha = .10f), RoundedCornerShape(14.dp)),
                contentAlignment = Alignment.Center,
            ) { Text("▣\n●", color = Accent, textAlign = TextAlign.Center, fontWeight = FontWeight.Bold) }
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Text("ANLAGENINVENTAR", color = Accent, fontSize = 12.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.5.sp)
                Text(project.name, color = Ink, fontSize = 28.sp, fontWeight = FontWeight.Bold)
                Text("Wasserinhalt Bauteil für Bauteil erfassen", color = Muted, fontSize = 13.sp)
            }
        }
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Tag("${project.items.size} Bauteile")
            Tag("+${format(project.reservePercent, 1)} % Reserve")
        }
    }
}

@Composable
private fun PlanningTotal(project: UiProject, onSettings: () -> Unit) {
    LedgerCard(accentRail = true) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("SUMMENBLATT", color = Muted, fontSize = 12.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.sp, modifier = Modifier.weight(1f))
            TextButton(onClick = onSettings) { Text("Reserve", color = Accent, fontWeight = FontWeight.Bold) }
        }
        Text("PLANUNGSWERT", color = Accent, fontSize = 12.sp, fontWeight = FontWeight.Bold)
        Row(verticalAlignment = Alignment.Bottom) {
            Text(format(project.planningVolumeLiters, 1), color = Ink, fontSize = 42.sp, fontWeight = FontWeight.Bold)
            Spacer(Modifier.width(6.dp))
            Text("Liter", color = Muted, fontWeight = FontWeight.Bold, modifier = Modifier.padding(bottom = 7.dp))
            Spacer(Modifier.weight(1f))
            Text("●", color = Accent.copy(alpha = .7f), fontSize = 42.sp)
        }
        HorizontalDivider(color = Line)
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Metric("Berechnet", project.calculatedVolumeLiters, true, Modifier.weight(1f))
            Metric("Reserve", project.reserveLiters, false, Modifier.weight(1f))
        }
    }
}

@Composable
private fun ComponentLedgerRow(index: Int, item: UiItem, onDelete: () -> Unit) {
    Surface(color = Color.White.copy(alpha = .82f), shape = RoundedCornerShape(13.dp), modifier = Modifier.fillMaxWidth()) {
        Row(Modifier.padding(13.dp), verticalAlignment = Alignment.CenterVertically) {
            Text(index.toString().padStart(2, '0'), color = Muted, fontWeight = FontWeight.Black, fontSize = 12.sp, modifier = Modifier.width(28.dp))
            Box(Modifier.size(32.dp).background(Accent.copy(alpha = .08f), RoundedCornerShape(8.dp)), contentAlignment = Alignment.Center) {
                Text("●", color = Accent)
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(item.name, color = Ink, fontWeight = FontWeight.Bold)
                Text(item.kind, color = Muted, fontSize = 12.sp)
                item.source?.let { Text(it, color = Muted.copy(alpha = .85f), fontSize = 11.sp) }
            }
            Column(horizontalAlignment = Alignment.End) {
                Text(format(item.liters, 2), color = Ink, fontWeight = FontWeight.Bold)
                Text("Liter", color = Muted, fontSize = 11.sp)
                TextButton(onClick = onDelete, contentPadding = PaddingValues(0.dp)) { Text("Löschen", fontSize = 11.sp) }
            }
        }
    }
}

@Composable
private fun FillAuditScreen(
    project: UiProject,
    onAddAudit: () -> Unit,
    onDeleteAudit: (String) -> Unit,
    onShare: () -> Unit,
) {
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(horizontal = 17.dp, vertical = 14.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text("Füllabgleich", color = Ink, fontSize = 20.sp, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
            Badge(project.fillChecks.size.toString())
        }
        LedgerCard {
            Text("VOLUMEN NACHWEISEN", color = Accent, fontSize = 12.sp, fontWeight = FontWeight.Bold, letterSpacing = 1.2.sp)
            Text("Berechnet trifft eingefüllt.", color = Ink, fontSize = 30.sp, fontWeight = FontWeight.Bold)
            Text("Vergleiche das Bauteilinventar mit einer vollständigen Befüllung. Halte Datengrundlage und offene Quellen für die Übergabe fest.", color = Muted)
            Text(project.name, color = Ink, fontWeight = FontWeight.Bold)
        }
        LedgerCard {
            Text("INVENTAR NACH BAUTEILART", color = Muted, fontSize = 12.sp, fontWeight = FontWeight.Bold)
            if (project.items.isEmpty()) Text("Noch keine Bauteile erfasst.", color = Muted)
            project.items.groupBy { it.kind }.forEach { (kind, items) ->
                Row(Modifier.fillMaxWidth()) {
                    Text(kind, modifier = Modifier.weight(1f), fontWeight = FontWeight.Bold)
                    Text("${format(items.sumOf { it.liters }, 2)} l", color = Accent, fontWeight = FontWeight.Bold)
                }
            }
            HorizontalDivider(color = Line)
            Row(Modifier.fillMaxWidth()) {
                Text("Berechneter Wasserinhalt", modifier = Modifier.weight(1f), fontWeight = FontWeight.Bold)
                Text("${format(project.calculatedVolumeLiters, 2)} l", fontWeight = FontWeight.Bold)
            }
            Text("Die Planungsreserve wird beim Füllabgleich nicht als realer Wasserinhalt mitgerechnet.", color = Muted, fontSize = 12.sp)
        }
        LedgerCard {
            Text("DATENGRUNDLAGE PRÜFEN", color = Muted, fontSize = 12.sp, fontWeight = FontWeight.Bold)
            Text("${project.undocumentedItems.size} von ${project.items.size} Bauteilen ohne Quellenangabe", color = if (project.undocumentedItems.isEmpty()) Accent else Ink, fontWeight = FontWeight.Bold)
            project.items.forEach { item ->
                Column {
                    Text(item.name, fontWeight = FontWeight.Bold)
                    Text(item.source ?: "Quelle ergänzen: Hersteller, Messung oder Schätzung", color = Muted, fontSize = 12.sp)
                }
            }
        }
        LedgerCard {
            Text("VOLLSTÄNDIGE BEFÜLLUNGEN", color = Muted, fontSize = 12.sp, fontWeight = FontWeight.Bold)
            Button(onClick = onAddAudit, enabled = project.calculatedVolumeLiters > 0, modifier = Modifier.fillMaxWidth()) { Text("Füllabgleich erfassen") }
            if (project.fillChecks.isEmpty()) {
                Text("Noch kein Abgleich. Erfasse zuerst das Inventar und anschließend eine vollständige Befüllung der anfangs leeren Anlage.", color = Muted)
            }
            project.fillChecks.sortedByDescending { it.timestamp }.forEach { check ->
                Surface(color = Panel, shape = RoundedCornerShape(12.dp), modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.padding(13.dp), verticalArrangement = Arrangement.spacedBy(5.dp)) {
                        Text(DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT).format(Date(check.timestamp)), fontWeight = FontWeight.Bold)
                        Text("${format(check.netFillL, 2)} l eingefüllt", color = Ink, fontSize = 22.sp, fontWeight = FontWeight.Bold)
                        Text("Inventar zum Messzeitpunkt: ${format(check.calculatedBaselineL, 2)} l · ${check.componentCount} Bauteile", color = Muted, fontSize = 12.sp)
                        Text("Abweichung: ${format(check.deviationL, 2)} l / ${format(check.deviationPercent ?: 0.0, 1)} %", fontWeight = FontWeight.Bold)
                        Text(if (check.isWithinTolerance) "Innerhalb Projekttoleranz" else "Abweichung untersuchen", color = if (check.isWithinTolerance) Accent else Color(0xFF9C5B18), fontWeight = FontWeight.Bold)
                        if (check.note.isNotBlank()) Text(check.note, color = Muted)
                        TextButton(onClick = { onDeleteAudit(check.id) }) { Text("Abgleich löschen") }
                    }
                }
            }
        }
        LedgerCard {
            Text("ÜBERGABE", color = Muted, fontSize = 12.sp, fontWeight = FontWeight.Bold)
            OutlinedButton(onClick = onShare, modifier = Modifier.fillMaxWidth()) { Text("Inventar- und Füllnachweis teilen") }
            Text("Ein Abgleich gilt für eine anfangs leere Anlage innerhalb derselben Systemgrenzen. Abweichungen können auf Restwasser, Entlüftung, Messunsicherheit oder fehlende Bauteile hinweisen; sie sind keine automatische Leckdiagnose.", color = Muted, fontSize = 12.sp)
        }
        Spacer(Modifier.height(8.dp))
    }
}

@Composable
private fun LedgerCard(accentRail: Boolean = false, content: @Composable Column.() -> Unit) {
    Card(
        colors = CardDefaults.cardColors(containerColor = CardSurface),
        shape = RoundedCornerShape(18.dp),
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Row {
            if (accentRail) Box(Modifier.width(4.dp).height(170.dp).background(Accent))
            Column(Modifier.weight(1f).padding(17.dp), verticalArrangement = Arrangement.spacedBy(12.dp), content = content)
        }
    }
}

@Composable
private fun Metric(title: String, value: Double, emphasized: Boolean, modifier: Modifier) {
    Surface(color = Panel, shape = RoundedCornerShape(12.dp), modifier = modifier) {
        Column(Modifier.padding(13.dp)) {
            Text(title.uppercase(), color = Muted, fontSize = 11.sp, fontWeight = FontWeight.Bold)
            Text("${format(value, 1)} l", color = if (emphasized) Accent else Ink, fontSize = 20.sp, fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
private fun ActionCard(modifier: Modifier, title: String, subtitle: String, primary: Boolean = false, onClick: () -> Unit) {
    Surface(
        modifier = modifier.clickable(onClick = onClick),
        color = if (primary) Accent else CardSurface,
        shape = RoundedCornerShape(15.dp),
    ) {
        Column(Modifier.padding(15.dp).height(72.dp), verticalArrangement = Arrangement.SpaceBetween) {
            Text(title, color = if (primary) Color.White else Ink, fontWeight = FontWeight.Bold)
            Text(subtitle, color = if (primary) Color.White.copy(alpha = .78f) else Muted, fontSize = 11.sp)
        }
    }
}

@Composable
private fun Tag(text: String) {
    Surface(color = Panel, shape = CircleShape) { Text(text, color = Muted, fontSize = 11.sp, fontWeight = FontWeight.SemiBold, modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)) }
}

@Composable
private fun Badge(text: String) {
    Surface(color = Accent.copy(alpha = .09f), shape = CircleShape) { Text(text, color = Accent, fontWeight = FontWeight.Bold, modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp)) }
}

@Composable
private fun LedgerLines() {
    Canvas(Modifier.fillMaxSize()) {
        var y = 26.dp.toPx()
        val step = 34.dp.toPx()
        while (y < size.height) {
            drawLine(Line.copy(alpha = .22f), Offset(0f, y), Offset(size.width, y), strokeWidth = .5f)
            y += step
        }
    }
}

private fun fillEvidenceText(project: UiProject): String = buildString {
    append("VolumeCalc – Inventar- und Füllnachweis\n")
    append("${project.name}\n")
    append("Berechnet ${format(project.calculatedVolumeLiters, 2)} l; Reserve separat ${format(project.reserveLiters, 2)} l\n")
    project.items.forEach { item ->
        append("${item.name} [${item.kind}]: ${format(item.liters, 2)} l; Quelle: ${item.source ?: "nicht dokumentiert"}\n")
    }
    project.fillChecks.forEach { check ->
        append("\nBefüllung: Zähler ${format(check.meterStartL, 2)} → ${format(check.meterEndL, 2)} l; abgelassen ${format(check.drainedL, 2)} l; netto ${format(check.netFillL, 2)} l. ")
        append("Inventar-Basis ${format(check.calculatedBaselineL, 2)} l / ${check.componentCount} Bauteile. Differenz ${format(check.deviationL, 2)} l / ${format(check.deviationPercent ?: 0.0, 1)} %. ")
        append("Toleranz ±${format(check.tolerancePercent, 1)} %. ${check.note}\n")
    }
    append("Die Inventar-Basis früherer Befüllungen bleibt unverändert. Projekttoleranz ist keine Normbestätigung; keine Leckdiagnose.")
}
