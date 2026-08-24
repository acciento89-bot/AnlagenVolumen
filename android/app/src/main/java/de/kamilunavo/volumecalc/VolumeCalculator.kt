package de.kamilunavo.volumecalc

import kotlin.math.PI
import kotlin.math.pow

data class PipePreset(val group: String, val name: String, val innerDiameterMm: Double, val note: String = "")
data class RadiatorReference(val type: String, val heightMm: Int, val litersPerMeter: Double)
data class SectionRadiatorReference(
    val material: String,
    val heightMm: Int,
    val centerDistanceMm: Int,
    val depthMm: Int,
    val litersPerSection: Double,
    val source: String
) {
    val displayName: String get() = "H $heightMm · NA $centerDistanceMm · T $depthMm mm"
}
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

    fun sectionRadiatorVolumeLiters(litersPerSection: Double, sections: Double, quantity: Double = 1.0): Double {
        if (litersPerSection <= 0 || sections <= 0 || quantity <= 0) return 0.0
        return litersPerSection * sections * quantity
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
        PipePreset("PE-X / FBH", "20 × 2 mm", 16.0, "Hersteller prüfen"),

        PipePreset("Stahl Gewinderohr schwarz", "DN 10 · 3/8\"", 12.6, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 15 · 1/2\"", 16.1, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 20 · 3/4\"", 21.7, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 25 · 1\"", 27.3, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 32 · 1 1/4\"", 35.8, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 40 · 1 1/2\"", 41.9, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 50 · 2\"", 53.1, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 65 · 2 1/2\"", 68.9, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 80 · 3\"", 80.9, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 100 · 4\"", 105.3, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 125 · 5\"", 130.1, "EN 10255 / DIN 2440 Referenz"),
        PipePreset("Stahl Gewinderohr schwarz", "DN 150 · 6\"", 155.5, "EN 10255 / DIN 2440 Referenz"),

        PipePreset("Stahl Gewinderohr verzinkt", "DN 10 · 3/8\"", 12.6, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),
        PipePreset("Stahl Gewinderohr verzinkt", "DN 15 · 1/2\"", 16.1, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),
        PipePreset("Stahl Gewinderohr verzinkt", "DN 20 · 3/4\"", 21.7, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),
        PipePreset("Stahl Gewinderohr verzinkt", "DN 25 · 1\"", 27.3, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),
        PipePreset("Stahl Gewinderohr verzinkt", "DN 32 · 1 1/4\"", 35.8, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),
        PipePreset("Stahl Gewinderohr verzinkt", "DN 40 · 1 1/2\"", 41.9, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),
        PipePreset("Stahl Gewinderohr verzinkt", "DN 50 · 2\"", 53.1, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),
        PipePreset("Stahl Gewinderohr verzinkt", "DN 65 · 2 1/2\"", 68.9, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),
        PipePreset("Stahl Gewinderohr verzinkt", "DN 80 · 3\"", 80.9, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),
        PipePreset("Stahl Gewinderohr verzinkt", "DN 100 · 4\"", 105.3, "EN 10255 / DIN 2440 Geometrie; Zinkschicht nicht separat abgezogen"),

        PipePreset("Siederohr normalwandig", "17,2 × 1,8 mm", 13.6, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "21,3 × 2,0 mm", 17.3, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "26,9 × 2,3 mm", 22.3, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "33,7 × 2,6 mm", 28.5, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "42,4 × 2,6 mm", 37.2, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "48,3 × 2,6 mm", 43.1, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "60,3 × 2,9 mm", 54.5, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "76,1 × 2,9 mm", 70.3, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "88,9 × 3,2 mm", 82.5, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "114,3 × 3,6 mm", 107.1, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "139,7 × 4,0 mm", 131.7, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "168,3 × 4,5 mm", 159.3, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),
        PipePreset("Siederohr normalwandig", "219,1 × 6,3 mm", 206.5, "DIN 2448/1629 bzw. EN 10220/10216 Referenz"),

        PipePreset("Edelstahl Press", "12 × 1,0 mm", 10.0, "Mapress/Sanpress Referenz – Hersteller prüfen"),
        PipePreset("Edelstahl Press", "15 × 1,0 mm", 13.0, "Mapress/Sanpress Referenz – Hersteller prüfen"),
        PipePreset("Edelstahl Press", "18 × 1,0 mm", 16.0, "Mapress/Sanpress Referenz – Hersteller prüfen"),
        PipePreset("Edelstahl Press", "22 × 1,2 mm", 19.6, "Mapress/Sanpress Referenz – Hersteller prüfen"),
        PipePreset("Edelstahl Press", "28 × 1,2 mm", 25.6, "Mapress/Sanpress Referenz – Hersteller prüfen"),
        PipePreset("Edelstahl Press", "35 × 1,5 mm", 32.0, "Mapress/Sanpress Referenz – Hersteller prüfen"),
        PipePreset("Edelstahl Press", "42 × 1,5 mm", 39.0, "Mapress/Sanpress Referenz – Hersteller prüfen"),
        PipePreset("Edelstahl Press", "54 × 1,5 mm", 51.0, "Mapress/Sanpress Referenz – Hersteller prüfen"),
        PipePreset("Edelstahl Press", "76,1 × 2,0 mm", 72.1, "Mapress Referenz – Hersteller prüfen"),

        PipePreset("PP-R SDR 6", "20 × 3,4 mm", 13.2, "DIN 8077/8078 / EN ISO 15874 Referenz – Hersteller prüfen"),
        PipePreset("PP-R SDR 6", "25 × 4,2 mm", 16.6, "DIN 8077/8078 / EN ISO 15874 Referenz – Hersteller prüfen"),
        PipePreset("PP-R SDR 6", "32 × 5,4 mm", 21.2, "DIN 8077/8078 / EN ISO 15874 Referenz – Hersteller prüfen"),
        PipePreset("PP-R SDR 6", "40 × 6,7 mm", 26.6, "DIN 8077/8078 / EN ISO 15874 Referenz – Hersteller prüfen"),
        PipePreset("PP-R SDR 6", "50 × 8,3 mm", 33.4, "DIN 8077/8078 / EN ISO 15874 Referenz – Hersteller prüfen"),
        PipePreset("PP-R SDR 6", "63 × 10,5 mm", 42.0, "DIN 8077/8078 / EN ISO 15874 Referenz – Hersteller prüfen")
    )

    val radiators = mapOf(
        "10" to mapOf(500 to 2.7, 550 to 3.0, 600 to 3.2, 900 to 4.5),
        "11" to mapOf(300 to 1.6, 400 to 2.2, 500 to 2.7, 550 to 2.9, 600 to 3.2, 900 to 4.5),
        "21S" to mapOf(500 to 5.4, 550 to 6.1, 600 to 6.5, 900 to 9.0, 950 to 9.1),
        "22" to mapOf(300 to 3.4, 400 to 4.5, 500 to 5.5, 550 to 6.1, 600 to 6.6, 900 to 9.0, 950 to 9.3),
        "33" to mapOf(300 to 5.1, 400 to 6.7, 500 to 8.2, 550 to 9.0, 600 to 9.8, 900 to 13.3, 950 to 14.0)
    )

    val sectionRadiators = listOf(
        SectionRadiatorReference("Stahl", 300, 200, 250, 1.075, "DIN-Stahlradiator Referenzwerte (DIN 4703 / EN 442)"),
        SectionRadiatorReference("Stahl", 450, 350, 160, 0.923, "DIN-Stahlradiator Referenzwerte (DIN 4703 / EN 442)"),
        SectionRadiatorReference("Stahl", 450, 350, 220, 1.250, "DIN-Stahlradiator Referenzwerte (DIN 4703 / EN 442)"),
        SectionRadiatorReference("Stahl", 600, 500, 110, 0.833, "DIN-Stahlradiator Referenzwerte (DIN 4703 / EN 442)"),
        SectionRadiatorReference("Stahl", 600, 500, 160, 1.158, "DIN-Stahlradiator Referenzwerte (DIN 4703 / EN 442)"),
        SectionRadiatorReference("Stahl", 600, 500, 220, 1.508, "DIN-Stahlradiator Referenzwerte (DIN 4703 / EN 442)"),
        SectionRadiatorReference("Stahl", 1000, 900, 110, 1.208, "DIN-Stahlradiator Referenzwerte (DIN 4703 / EN 442)"),
        SectionRadiatorReference("Stahl", 1000, 900, 160, 1.742, "DIN-Stahlradiator Referenzwerte (DIN 4703 / EN 442)"),
        SectionRadiatorReference("Stahl", 1000, 900, 220, 2.300, "DIN-Stahlradiator Referenzwerte (DIN 4703 / EN 442)"),

        SectionRadiatorReference("Guss", 280, 200, 250, 0.9, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 430, 350, 70, 0.4, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 430, 350, 110, 0.6, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 430, 350, 160, 0.8, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 430, 350, 220, 1.1, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 580, 500, 70, 0.5, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 580, 500, 110, 0.8, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 580, 500, 160, 1.1, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 580, 500, 220, 1.3, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 680, 600, 160, 1.2, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 980, 900, 70, 0.8, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 980, 900, 160, 1.5, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)"),
        SectionRadiatorReference("Guss", 980, 900, 220, 1.9, "DIN-Gussradiator Bestandsreferenz (DIN 4703 / DIN 4720)")
    )
}
