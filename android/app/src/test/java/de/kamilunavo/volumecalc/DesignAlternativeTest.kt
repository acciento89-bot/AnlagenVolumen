package de.kamilunavo.volumecalc

import org.junit.Assert.*
import org.junit.Test
import java.util.Locale

class DesignAlternativeTest {
    private fun sample() = UiProject(id="project", name="Heizkreis", reservePercent=10.0, items=listOf(
        UiItem(id="buffer",name="Speicher",liters=100.0,kind="Speicher",source="Typenschild",note="Herstellerwert"),
        UiItem(id="pipe",name="Leitung",liters=20.0,kind="Rohr")
    ))
    @Test fun proposalKeepsFrozenBaselineAndSeparatesReserveFromWater() {
        val items=sample().items.toMutableList()
        val actual=sample().copy(items=items)
        val baseline=DesignAlternative.capture(actual,"Kompakter Speicher")
        val proposal=baseline.copy(proposedItems=baseline.proposedItems.map{if(it.id=="buffer")it.copy(liters=80.0) else it},proposedReservePercent=5.0)
        items.clear()
        val comparison=proposal.comparison()
        assertEquals(120.0,comparison.baselineWater,0.0001)
        assertEquals(100.0,comparison.proposedWater,0.0001)
        assertEquals(-20.0,comparison.waterDelta,0.0001)
        assertEquals(12.0,comparison.baselineReserve,0.0001)
        assertEquals(5.0,comparison.proposedReserve,0.0001)
        assertEquals(-27.0,comparison.planningDelta,0.0001)
        assertEquals(100.0,proposal.baselineItems.first().liters,0.0001)
    }
    @Test fun stableComponentIdsClassifyChangesAndIgnoreReordering() {
        val actual=sample();val proposal=DesignAlternative.capture(actual,"Variante")
        assertTrue(proposal.copy(proposedItems=proposal.proposedItems.reversed()).comparison().changes.isEmpty())
        assertFalse(proposal.baselineIsStale(actual.copy(items=actual.items.reversed())))
        val changed=proposal.copy(proposedItems=listOf(proposal.proposedItems[1].copy(name="Neue Leitung"),UiItem(id="radiator",name="Heizkörper",liters=6.0,kind="Heizkörper")))
        assertEquals(setOf(ComponentChangeKind.ADDED,ComponentChangeKind.REMOVED,ComponentChangeKind.CHANGED),changed.comparison().changes.map{it.kind}.toSet())
        assertEquals("buffer",changed.comparison().changes.first{it.kind==ComponentChangeKind.REMOVED}.id)
        assertTrue(proposal.baselineIsStale(actual.copy(reservePercent=20.0)))
    }
    @Test fun malformedValuesAndDuplicateIdsCannotProduceAComparison() {
        val proposal=DesignAlternative.capture(sample(),"Variante")
        listOf(proposal.copy(name=" "),proposal.copy(proposedReservePercent=Double.NaN),
            proposal.copy(proposedItems=proposal.proposedItems+proposal.proposedItems.first()),
            proposal.copy(proposedItems=listOf(proposal.proposedItems.first().copy(liters=-1.0))),
            proposal.copy(proposedItems=listOf(proposal.proposedItems.first().copy(liters=Double.MAX_VALUE)),proposedReservePercent=Double.MAX_VALUE)
        ).forEach{invalid->assertFalse(invalid.valid);assertThrows(IllegalArgumentException::class.java){invalid.comparison()}}
    }
    @Test fun comparisonReportRetainsSourceAndSeparatesPlanningAllowance() {
        val proposal=DesignAlternative.capture(sample(),"Ohne Speicher").let{it.copy(proposedItems=it.proposedItems.drop(1))}
        val de=proposal.report(Locale.GERMANY)
        assertTrue(de.contains("Heizkreis"));assertTrue(de.contains("Ohne Speicher"));assertTrue(de.contains("Typenschild"));assertTrue(de.contains("Herstellerwert"))
        assertTrue(de.contains("Planungsvolumen"));assertTrue(de.contains("keine Messung"));assertTrue(de.contains(" l"))
        val en=proposal.report(Locale.US)
        assertTrue(en.contains("Planning volume"));assertTrue(en.contains("not a measurement"))
    }
}
