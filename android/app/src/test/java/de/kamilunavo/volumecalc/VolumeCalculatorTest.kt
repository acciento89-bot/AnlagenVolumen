package de.kamilunavo.volumecalc

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test

class VolumeCalculatorTest {
    @Test fun pipe16x2_100m() {
        assertEquals(11.3097, VolumeCalculator.pipeVolumeLiters(12.0, 100.0), 0.001)
    }

    @Test fun galvanizedDn25Preset() {
        val preset = ReferenceData.pipes.firstOrNull {
            it.group == "Stahl Gewinderohr verzinkt" && it.name.contains("DN 25")
        }
        assertNotNull(preset)
        assertEquals(27.3, preset!!.innerDiameterMm, 0.0001)
        assertEquals(0.5854, VolumeCalculator.pipeVolumeLiters(preset.innerDiameterMm, 1.0), 0.001)
    }

    @Test fun boilerTube604x29Preset() {
        val preset = ReferenceData.pipes.firstOrNull {
            it.group == "Siederohr normalwandig" && it.name == "60,3 × 2,9 mm"
        }
        assertNotNull(preset)
        assertEquals(54.5, preset!!.innerDiameterMm, 0.0001)
        assertEquals(2.3329, VolumeCalculator.pipeVolumeLiters(preset.innerDiameterMm, 1.0), 0.001)
    }

    @Test fun panel22_600_1000() {
        assertEquals(6.6, VolumeCalculator.radiatorVolumeLiters(6.6, 1000.0), 0.0001)
    }

    @Test fun steelSection600x110TenSections() {
        val ref = ReferenceData.sectionRadiators.first {
            it.material == "Stahl" && it.heightMm == 600 && it.depthMm == 110
        }
        assertEquals(0.833, ref.litersPerSection, 0.0001)
        assertEquals(8.33, VolumeCalculator.sectionRadiatorVolumeLiters(ref.litersPerSection, 10.0), 0.001)
    }

    @Test fun castIron580x220TwelveSections() {
        val ref = ReferenceData.sectionRadiators.first {
            it.material == "Guss" && it.heightMm == 580 && it.depthMm == 220
        }
        assertEquals(1.3, ref.litersPerSection, 0.0001)
        assertEquals(15.6, VolumeCalculator.sectionRadiatorVolumeLiters(ref.litersPerSection, 12.0), 0.001)
    }

    @Test fun invalidIsZero() {
        assertEquals(0.0, VolumeCalculator.pipeVolumeLiters(0.0, 10.0), 0.0)
        assertEquals(0.0, VolumeCalculator.sectionRadiatorVolumeLiters(1.0, -1.0), 0.0)
    }
}
