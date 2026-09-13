package de.kamilunavo.volumecalc

import android.content.Context
import android.content.Intent
import android.graphics.Color as AndroidColor
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.ui.graphics.Color
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID
import kotlin.math.abs

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.light(AndroidColor.TRANSPARENT, AndroidColor.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.light(AndroidColor.TRANSPARENT, AndroidColor.TRANSPARENT),
        )
        val repository = ProjectRepository(this)
        val screenshotMode = BuildConfig.DEBUG &&
            intent.getBooleanExtra("de.kamilunavo.volumecalc.STORE_SCREENSHOTS", false)
        if (screenshotMode) repository.seedStoreScreenshotData()
        setContent {
            VolumeCalcApp(
                repository = repository,
                onShare = ::share,
            )
        }
    }

    private fun share(text: String) {
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        startActivity(Intent.createChooser(intent, null))
    }
}

// Mirrors the light ledger-style SwiftUI theme.
internal val Accent = Color(0xFF1F614F)
internal val Accent2 = Color(0xFF3D8F70)
internal val Bg1 = Color(0xFFF5F1E6)
internal val Bg2 = Color(0xFFFBF9F1)
internal val Panel = Color(0xFFFDFBF5)
internal val CardSurface = Color(0xFFFFFEFA)
internal val Ink = Color(0xFF1F2621)
internal val Muted = Color(0xFF616B63)
internal val Line = Color(0x222E4738)
internal val OnAccent = Color.White

internal data class UiItem(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val liters: Double,
    val kind: String,
    val source: String? = null,
    val note: String? = null,
)

internal data class FillCheck(
    val id: String = UUID.randomUUID().toString(),
    val timestamp: Long = System.currentTimeMillis(),
    val meterStartL: Double = 0.0,
    val meterEndL: Double = 0.0,
    val drainedL: Double = 0.0,
    val tolerancePercent: Double = 5.0,
    val confirmedEmptySystem: Boolean = false,
    val calculatedBaselineL: Double = 0.0,
    val componentCount: Int = 0,
    val note: String = "",
) {
    val netFillL: Double get() = meterEndL - meterStartL - drainedL
    val deviationL: Double get() = netFillL - calculatedBaselineL
    val deviationPercent: Double?
        get() = calculatedBaselineL.takeIf { it > 0.0 }?.let { deviationL / it * 100.0 }
    val isWithinTolerance: Boolean
        get() = deviationPercent?.let { abs(it) <= tolerancePercent } == true
    val isValid: Boolean
        get() = meterEndL > meterStartL && netFillL > 0.0 && tolerancePercent in 0.0..100.0 && confirmedEmptySystem
}

internal data class UiProject(
    val id: String = UUID.randomUUID().toString(),
    val name: String = "Neue Anlage",
    val reservePercent: Double = 5.0,
    val items: List<UiItem> = emptyList(),
    val fillChecks: List<FillCheck> = emptyList(),
) {
    val calculatedVolumeLiters: Double get() = items.sumOf { it.liters }
    val reserveLiters: Double get() = calculatedVolumeLiters * reservePercent / 100.0
    val planningVolumeLiters: Double get() = calculatedVolumeLiters + reserveLiters
    val undocumentedItems: List<UiItem> get() = items.filter { it.source.isNullOrBlank() }
}

internal class ProjectRepository(context: Context) {
    private val prefs = context.getSharedPreferences("volumecalc", Context.MODE_PRIVATE)

    fun load(): List<UiProject> {
        val raw = prefs.getString("projects", null) ?: return listOf(UiProject())
        return runCatching {
            val array = JSONArray(raw)
            buildList {
                for (i in 0 until array.length()) {
                    val obj = array.getJSONObject(i)
                    val itemsArray = obj.optJSONArray("items") ?: JSONArray()
                    val projectItems = buildList {
                        for (j in 0 until itemsArray.length()) {
                            val item = itemsArray.getJSONObject(j)
                            add(
                                UiItem(
                                    id = item.optString("id", UUID.randomUUID().toString()),
                                    name = item.optString("name", "Bauteil"),
                                    liters = item.optDouble("liters", 0.0).coerceAtLeast(0.0),
                                    kind = item.optString("kind", "Sonstiges"),
                                    source = item.optString("source").takeIf { it.isNotBlank() },
                                    note = item.optString("note").takeIf { it.isNotBlank() },
                                )
                            )
                        }
                    }
                    val checksArray = obj.optJSONArray("fillChecks") ?: JSONArray()
                    val checks = buildList {
                        for (j in 0 until checksArray.length()) {
                            val check = checksArray.getJSONObject(j)
                            add(
                                FillCheck(
                                    id = check.optString("id", UUID.randomUUID().toString()),
                                    timestamp = check.optLong("timestamp", System.currentTimeMillis()),
                                    meterStartL = check.optDouble("meterStartL", 0.0),
                                    meterEndL = check.optDouble("meterEndL", 0.0),
                                    drainedL = check.optDouble("drainedL", 0.0),
                                    tolerancePercent = check.optDouble("tolerancePercent", 5.0),
                                    confirmedEmptySystem = check.optBoolean("confirmedEmptySystem", false),
                                    calculatedBaselineL = check.optDouble("calculatedBaselineL", 0.0),
                                    componentCount = check.optInt("componentCount", 0),
                                    note = check.optString("note", ""),
                                )
                            )
                        }
                    }
                    add(
                        UiProject(
                            id = obj.optString("id", UUID.randomUUID().toString()),
                            name = obj.optString("name", "Neue Anlage"),
                            reservePercent = obj.optDouble("reservePercent", 5.0).coerceAtLeast(0.0),
                            items = projectItems,
                            fillChecks = checks,
                        )
                    )
                }
            }.ifEmpty { listOf(UiProject()) }
        }.getOrElse { listOf(UiProject()) }
    }

    fun save(projects: List<UiProject>) {
        val array = JSONArray()
        projects.forEach { project ->
            val items = JSONArray()
            project.items.forEach { item ->
                items.put(
                    JSONObject()
                        .put("id", item.id)
                        .put("name", item.name)
                        .put("liters", item.liters)
                        .put("kind", item.kind)
                        .put("source", item.source ?: "")
                        .put("note", item.note ?: "")
                )
            }
            val checks = JSONArray()
            project.fillChecks.forEach { check ->
                checks.put(
                    JSONObject()
                        .put("id", check.id)
                        .put("timestamp", check.timestamp)
                        .put("meterStartL", check.meterStartL)
                        .put("meterEndL", check.meterEndL)
                        .put("drainedL", check.drainedL)
                        .put("tolerancePercent", check.tolerancePercent)
                        .put("confirmedEmptySystem", check.confirmedEmptySystem)
                        .put("calculatedBaselineL", check.calculatedBaselineL)
                        .put("componentCount", check.componentCount)
                        .put("note", check.note)
                )
            }
            array.put(
                JSONObject()
                    .put("id", project.id)
                    .put("name", project.name)
                    .put("reservePercent", project.reservePercent)
                    .put("items", items)
                    .put("fillChecks", checks)
            )
        }
        prefs.edit().putString("projects", array.toString()).apply()
    }

    fun seedStoreScreenshotData() {
        val items = listOf(
            UiItem("demo-pipe", "Heizkreis EG · Rohr", 38.6, "Rohr", "Herstellerdaten / Rohrdimension"),
            UiItem("demo-radiators", "Heizkörper Wohnbereich", 46.0, "Heizkörper", "Typenübersicht Bestand"),
            UiItem("demo-buffer", "Pufferspeicher", 100.0, "Speicher", "Typenschild 100 l"),
            UiItem("demo-boiler", "Wärmeerzeuger", 8.5, "Wärmeerzeuger", "Technisches Datenblatt"),
        )
        val baseline = items.sumOf { it.liters }
        val check = FillCheck(
            id = "demo-fill",
            timestamp = 1_789_223_400_000L,
            meterStartL = 1240.0,
            meterEndL = 1435.2,
            drainedL = 1.1,
            tolerancePercent = 5.0,
            confirmedEmptySystem = true,
            calculatedBaselineL = baseline,
            componentCount = items.size,
            note = "Füllwasserzähler · Anlage vollständig entlüftet",
        )
        save(listOf(UiProject(id = "demo-project", name = "Mehrfamilienhaus Musterstraße", reservePercent = 5.0, items = items, fillChecks = listOf(check))))
    }
}
