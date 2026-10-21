package de.kamilunavo.volumecalc
import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createEmptyComposeRule
import androidx.test.core.app.ActivityScenario
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.*
import org.junit.Rule
import org.junit.Test
class AlternativeEditorTest {
 @get:Rule val compose=createEmptyComposeRule()
 private fun waitText(text:String){compose.waitUntil(15000){compose.onAllNodesWithText(text).fetchSemanticsNodes().isNotEmpty()}}
 @Test fun independentProposalEditsSaveAndSurviveActivityRecreation(){
  val context=InstrumentationRegistry.getInstrumentation().targetContext
  context.getSharedPreferences("volumecalc",0).edit().clear().commit()
  val repo=ProjectRepository(context);repo.load()
  assertTrue(repo.save(listOf(UiProject(id="plant",name="QA Anlage",items=listOf(UiItem(id="tank",name="Speicher",liters=120.0,kind="Speicher"))))))
  context.getSystemService(android.app.LocaleManager::class.java).applicationLocales=android.os.LocaleList.forLanguageTags("de-DE")
  val scenario=ActivityScenario.launch(MainActivity::class.java)
  try {
   waitText("Varianten");compose.onNodeWithText("Varianten").performClick()
   compose.onNodeWithText("Neue Variante").performClick();waitText("Variantenname")
   compose.onNodeWithText("Variantenname").performTextReplacement("Kompakter Speicher")
   compose.onNodeWithText("Bauteil bearbeiten").performClick();waitText("Wasserinhalt (l)")
   compose.onNodeWithText("Wasserinhalt (l)").performTextReplacement("100")
   compose.onNodeWithText("Übernehmen").performClick()
   scenario.recreate();waitText("Variantenname")
   compose.onNodeWithText("Kompakter Speicher").assertExists()
   compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText("Variante speichern"))
   compose.onNodeWithText("Variante speichern").performClick()
   waitText("Kompakter Speicher");scenario.recreate();waitText("Varianten")
   compose.onNodeWithText("Varianten").performClick();waitText("Kompakter Speicher")
   val saved=ProjectRepository(context).load().single()
   assertEquals(120.0,saved.items.single().liters,0.0)
   assertEquals(100.0,saved.alternatives.single().proposedItems.single().liters,0.0)
   assertEquals(120.0,saved.alternatives.single().baselineItems.single().liters,0.0)
   compose.onNodeWithText("Öffnen").performClick();waitText("Kompakter Speicher")
   val bitmap=InstrumentationRegistry.getInstrumentation().uiAutomation.takeScreenshot()
   java.io.File(context.filesDir,"alternative-editor.png").outputStream().use{bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG,100,it)}
  } finally {scenario.close()}
 }
 @Test fun overflowingDraftSurvivesRecreationWithoutSavingInvalidTotals(){
  val context=InstrumentationRegistry.getInstrumentation().targetContext
  context.getSharedPreferences("volumecalc",0).edit().clear().commit()
  val repo=ProjectRepository(context);repo.load()
  assertTrue(repo.save(listOf(UiProject(id="plant",name="Overflow fixture",items=listOf(UiItem(id="tank",name="Speicher",liters=120.0,kind="Speicher"))))))
  context.getSystemService(android.app.LocaleManager::class.java).applicationLocales=android.os.LocaleList.forLanguageTags("de-DE")
  val scenario=ActivityScenario.launch(MainActivity::class.java)
  try {
   waitText("Varianten");compose.onNodeWithText("Varianten").performClick()
   compose.onNodeWithText("Neue Variante").performClick();waitText("Variantenname")
   compose.onNodeWithText("Bauteil bearbeiten").performClick();waitText("Wasserinhalt (l)")
   compose.onNodeWithText("Wasserinhalt (l)").performTextReplacement("1e308")
   compose.onNodeWithText("Übernehmen").performClick()
   scenario.recreate();waitText("Variantenname")
   compose.onNode(hasScrollToIndexAction()).performScrollToNode(hasText("Variante speichern"))
   compose.onNodeWithText("Variante speichern").assertIsNotEnabled()
   assertTrue(ProjectRepository(context).load().single().alternatives.isEmpty())
  } finally {scenario.close()}
 }

}
