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
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val repository = ProjectRepository(this)
        setContent {
            VolumeCalcApp(
                repository = repository,
                onShare = ::share
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

internal val Accent = Color(0xFF2ED1B3)
internal val Bg1 = Color(0xFF03101A)
internal val Bg2 = Color(0xFF07353B)
internal val Panel = Color(0x12FFFFFF)
internal val Muted = Color.White.copy(alpha = 0.66f)

internal data class UiItem(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val liters: Double,
    val kind: String,
    val source: String? = null
)

internal data class UiProject(
    val id: String = UUID.randomUUID().toString(),
    val name: String = "Neue Anlage",
    val reservePercent: Double = 5.0,
    val items: List<UiItem> = emptyList()
) {
    val calculatedVolumeLiters: Double get() = items.sumOf { it.liters }
    val planningVolumeLiters: Double get() = calculatedVolumeLiters * (1.0 + reservePercent / 100.0)
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
                                    source = item.optString("source").takeIf { it.isNotBlank() }
                                )
                            )
                        }
                    }
                    add(
                        UiProject(
                            id = obj.optString("id", UUID.randomUUID().toString()),
                            name = obj.optString("name", "Neue Anlage"),
                            reservePercent = obj.optDouble("reservePercent", 5.0).coerceAtLeast(0.0),
                            items = projectItems
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
                )
            }
            array.put(
                JSONObject()
                    .put("id", project.id)
                    .put("name", project.name)
                    .put("reservePercent", project.reservePercent)
                    .put("items", items)
            )
        }
        prefs.edit().putString("projects", array.toString()).apply()
    }
}
