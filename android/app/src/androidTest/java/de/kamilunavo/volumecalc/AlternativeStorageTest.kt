package de.kamilunavo.volumecalc
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
@RunWith(AndroidJUnit4::class)
class AlternativeStorageTest {
 private val context get()=InstrumentationRegistry.getInstrumentation().targetContext
 private val prefs get()=context.getSharedPreferences("volumecalc",0)
 @Before fun clearSyntheticDeviceStore(){prefs.edit().clear().commit()}
 @Test fun legacyInventoryAndFrozenProposalSurviveReopen(){
  prefs.edit().putString("projects","""[{"id":"plant","name":"Bestand","reservePercent":10,"items":[{"id":"tank","name":"Speicher","liters":120,"kind":"Speicher","source":"Typenschild"}],"fillChecks":[{"id":"audit","meterStartL":100,"meterEndL":220,"confirmedEmptySystem":true}]}]""").commit()
  val repository=ProjectRepository(context);val original=repository.load().single()
  assertTrue(original.alternatives.isEmpty())
  val proposal=DesignAlternative.capture(original,"Kleiner Speicher",1234).copy(proposedItems=listOf(original.items.single().copy(liters=100.0)),proposedReservePercent=5.0)
  assertTrue(repository.save(listOf(original.copy(alternatives=listOf(proposal)))))
  val reopened=ProjectRepository(context).load().single()
  assertEquals(120.0,reopened.items.single().liters,0.0);assertEquals("audit",reopened.fillChecks.single().id)
  assertEquals(120.0,reopened.alternatives.single().baselineItems.single().liters,0.0)
  assertEquals(100.0,reopened.alternatives.single().proposedItems.single().liters,0.0)
  assertEquals(1234L,reopened.alternatives.single().capturedAt)
  val changed=reopened.copy(items=listOf(reopened.items.single().copy(liters=140.0)))
  assertTrue(repository.save(listOf(changed)))
  assertTrue(ProjectRepository(context).load().single().alternatives.single().baselineIsStale(changed))
 }
 @Test fun invalidOrDuplicateSnapshotsNeverOverwriteLastGoodBytes(){
  val repository=ProjectRepository(context);repository.load()
  val plant=UiProject(id="plant",items=listOf(UiItem(id="tank",name="Tank",liters=120.0,kind="Tank")))
  assertTrue(repository.save(listOf(plant)));val bytes=prefs.getString("projects",null)
  val alternative=DesignAlternative.capture(plant,"Test")
  assertFalse(repository.save(listOf(plant.copy(alternatives=listOf(alternative,alternative)))))
  assertEquals(bytes,prefs.getString("projects",null))
  assertFalse(repository.save(listOf(plant.copy(alternatives=listOf(alternative.copy(baselineProjectId="other"))))))
  assertEquals(bytes,prefs.getString("projects",null))
  assertFalse(repository.save(listOf(plant.copy(alternatives=listOf(alternative.copy(proposedReservePercent=Double.NaN))))))
  assertEquals(bytes,prefs.getString("projects",null))
 }
 @Test fun damagedOriginalIsProtectedFromFallbackSave(){
  val damaged="[{broken-original";prefs.edit().putString("projects",damaged).commit()
  val repository=ProjectRepository(context);repository.load()
  assertNotNull(repository.loadError);assertFalse(repository.save(listOf(UiProject(name="Replacement"))))
  assertEquals(damaged,prefs.getString("projects",null))
 }
 @Test fun wrongTypeAlternativesCannotSilentlyOverwriteOriginal(){
  val original="""[{"id":"plant","name":"Bestand","alternatives":"damaged snapshot field"}]"""
  prefs.edit().putString("projects",original).commit()
  val repository=ProjectRepository(context);repository.load()
  assertNotNull(repository.loadError)
  assertFalse(repository.save(listOf(UiProject(id="plant",name="Replacement"))))
  assertEquals(original,prefs.getString("projects",null))
 }

}
