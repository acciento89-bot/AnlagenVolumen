package de.kamilunavo.volumecalc

import kotlin.math.PI
import kotlin.math.pow

data class PipePreset(val group: String, val name: String, val innerDiameterMm: Double, val note: String = "")
data class RadiatorReference(val type: String, val heightMm: Int, val litersPerMeter: Double)
data class VolumeItem(val name: String, val kind: String, val totalLiters: Double, val source: String? = null)

object VolumeCalculator {
    fun pipeVolumeLiters(innerDiameterMm: Double, lengthMeters: Double): Double {
        if (innerDiameterMm <= 0 || lengthMeters <= 0) return 0.0
        val areaMm2 = PI * innerDiameterMm.pow(2) / 4.0
        return areaMm2 * lengthMeters / 1000.0
    }
    fun radiatorVolumeLiters(litersPerMeter: Double, lengthMm: Double, quantity: Double = 1.0): Double {
        if (litersPerMeter <= 0 || lengthMm <= 0 || quantity <= 0) return 0.0
        return litersPerMeter * (lengthMm / 1000.0) * quantity
    }
}

object ReferenceData {
    val pipes = listOf(
        PipePreset("Kupfer", "12 × 1 mm", 10.0), PipePreset("Kupfer", "15 × 1 mm", 13.0),
        PipePreset("Kupfer", "18 × 1 mm", 16.0), PipePreset("Kupfer", "22 × 1 mm", 20.0),
        PipePreset("Kupfer", "28 × 1,5 mm", 25.0), PipePreset("Kupfer", "35 × 1,5 mm", 32.0),
        PipePreset("Kupfer", "42 × 1,5 mm", 39.0), PipePreset("Kupfer", "54 × 2 mm", 50.0),
        PipePreset("Mehrschichtverbund", "16 × 2 mm", 12.0, "Hersteller prüfen"),
        PipePreset("Mehrschichtverbund", "20 × 2 mm", 16.0, "Hersteller prüfen"),
        PipePreset("Mehrschichtverbund", "26 × 3 mm", 20.0, "Hersteller prüfen"),
        PipePreset("Mehrschichtverbund", "32 × 3 mm", 26.0, "Hersteller prüfen"),
        PipePreset("Mehrschichtverbund", "40 × 3,5 mm", 33.0, "Hersteller prüfen"),
        PipePreset("Mehrschichtverbund", "50 × 4 mm", 42.0, "Hersteller prüfen"),
        PipePreset("Mehrschichtverbund", "63 × 4,5 mm", 54.0, "Hersteller prüfen"),
        PipePreset("PE-X / FBH", "12 × 2 mm", 8.0, "Hersteller prüfen"),
        PipePreset("PE-X / FBH", "14 × 2 mm", 10.0, "Hersteller prüfen"),
        PipePreset("PE-X / FBH", "16 × 2 mm", 12.0, "Hersteller prüfen"),
        PipePreset("PE-X / FBH", "17 × 2 mm", 13.0, "Hersteller prüfen"),
        PipePreset("PE-X / FBH", "20 × 2 mm", 16.0, "Hersteller prüfen")
    )

    val radiators = mapOf(
        "10" to mapOf(500 to 2.7, 550 to 3.0, 600 to 3.2, 900 to 4.5),
        "11" to mapOf(300 to 1.6, 400 to 2.2, 500 to 2.7, 550 to 2.9, 600 to 3.2, 900 to 4.5),
        "21S" to mapOf(500 to 5.4, 550 to 6.1, 600 to 6.5, 900 to 9.0, 950 to 9.1),
        "22" to mapOf(300 to 3.4, 400 to 4.5, 500 to 5.5, 550 to 6.1, 600 to 6.6, 900 to 9.0, 950 to 9.3),
        "33" to mapOf(300 to 5.1, 400 to 6.7, 500 to 8.2, 550 to 9.0, 600 to 9.8, 900 to 13.3, 950 to 14.0)
    )
}
