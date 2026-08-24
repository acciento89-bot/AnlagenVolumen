package de.kamilunavo.volumecalc

import org.junit.Assert.assertEquals
import org.junit.Test

class VolumeCalculatorTest {
    @Test fun pipe16x2_100m() { assertEquals(11.3097, VolumeCalculator.pipeVolumeLiters(12.0, 100.0), 0.001) }
    @Test fun panel22_600_1000() { assertEquals(6.6, VolumeCalculator.radiatorVolumeLiters(6.6, 1000.0), 0.0001) }
    @Test fun invalidIsZero() { assertEquals(0.0, VolumeCalculator.pipeVolumeLiters(0.0, 10.0), 0.0) }
}
