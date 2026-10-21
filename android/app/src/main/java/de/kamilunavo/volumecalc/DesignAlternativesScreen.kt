package de.kamilunavo.volumecalc

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.saveable.Saver
import org.json.JSONObject
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import java.util.Locale

@Composable internal fun planningText(de:String,en:String):String =
    if(LocalConfiguration.current.locales[0].language=="de")de else en

/** Edits only an independent proposal. Saving resolves the latest parent project. */
@Composable internal fun DesignAlternativesScreen(project:UiProject,onSave:(DesignAlternative)->Boolean,onDelete:(String)->Boolean,onShare:(String)->Unit) {
    val alternativeSaver=Saver<DesignAlternative?,String>(save={it?.let{value->AlternativeJson.encodeDraft(value).toString()}},restore={AlternativeJson.decodeDraft(JSONObject(it))})
    var editing by rememberSaveable(project.id,stateSaver=alternativeSaver){mutableStateOf<DesignAlternative?>(null)}
    val newName=planningText("Neue Variante","New alternative")
    var deleting by remember(project.id){mutableStateOf<DesignAlternative?>(null)}
    var error by remember{mutableStateOf(false)}
    val current=editing
    if(current!=null) {
        AlternativeEditor(current,project,onCancel={editing=null},onSave={ value ->
            if(onSave(value)){editing=null;true}else{error=true;false}
        },onShare=onShare)
    } else {
        LazyColumn(Modifier.fillMaxSize(),contentPadding=PaddingValues(18.dp),verticalArrangement=Arrangement.spacedBy(14.dp)) {
            item {Text(planningText("Variantenvergleich","Design alternatives"),style=MaterialTheme.typography.headlineMedium,fontWeight=FontWeight.Bold)}
            item {Text(project.name,color=Muted)}
            item {Text(planningText("Planungsvarianten vergleichen unabhängige Entwürfe mit einem eingefrorenen Bestand. Inventar und Füllprüfungen bleiben erhalten.","Compare independent proposals against a frozen baseline. Your inventory and fill audits are preserved."))}
            item {Button(onClick={editing=DesignAlternative.capture(project,newName)},modifier=Modifier.fillMaxWidth()){Text(planningText("Neue Variante","New alternative"))}}
            if(project.alternatives.isEmpty())item {Text(planningText("Noch keine Varianten gespeichert.","No saved alternatives yet."),color=Muted)}
            items(project.alternatives,key={it.id}) { value ->
                Card(Modifier.fillMaxWidth(),colors=CardDefaults.cardColors(containerColor=CardSurface)) {Column(Modifier.padding(16.dp),verticalArrangement=Arrangement.spacedBy(8.dp)) {
                    Text(value.name,style=MaterialTheme.typography.titleLarge)
                    Text("${format(value.comparison().proposedWater,1)} l · Δ ${format(value.comparison().waterDelta,1)} l")
                    if(value.baselineIsStale(project)) Text(planningText("Bestand seit Erfassung verändert","Inventory changed since capture"),color=MaterialTheme.colorScheme.error)
                    Row {TextButton(onClick={editing=value}){Text(planningText("Öffnen","Open"))};TextButton(onClick={onShare(value.report(Locale.getDefault()))}){Text(planningText("Teilen","Share"))};TextButton(onClick={deleting=value}){Text(planningText("Löschen","Delete"))}}
                }}
            }
        }
    }
    deleting?.let { value -> AlertDialog(onDismissRequest={deleting=null},title={Text(planningText("Variante löschen?","Delete alternative?"))},text={Text(value.name)},confirmButton={TextButton(onClick={if(onDelete(value.id))deleting=null else error=true}){Text(planningText("Löschen","Delete"))}},dismissButton={TextButton(onClick={deleting=null}){Text(planningText("Abbrechen","Cancel"))}}) }
    if(error)AlertDialog(onDismissRequest={error=false},title={Text(planningText("Nicht gespeichert","Not saved"))},text={Text(planningText("Die vorhandenen Daten bleiben erhalten. Bitte Speicherplatz und Projekt prüfen.","Existing data has been preserved. Check available storage and the project."))},confirmButton={TextButton(onClick={error=false}){Text("OK")}})
}

@Composable private fun AlternativeEditor(initial:DesignAlternative,actual:UiProject,onCancel:()->Unit,onSave:(DesignAlternative)->Boolean,onShare:(String)->Unit) {
    var name by rememberSaveable(initial.id){mutableStateOf(initial.name)}
    var reserve by rememberSaveable(initial.id){mutableStateOf(initial.proposedReservePercent.toString())}
    val proposalSaver=Saver<List<UiItem>,String>(save={AlternativeJson.encodeDraft(initial.copy(proposedItems=it)).toString()},restore={AlternativeJson.decodeDraft(JSONObject(it)).proposedItems})
    var proposal by rememberSaveable(initial.id,stateSaver=proposalSaver){mutableStateOf(initial.proposedItems)}
    var add by rememberSaveable{mutableStateOf(false)}
    var editId by rememberSaveable{mutableStateOf<String?>(null)}
    val parsedReserve=reserve.replace(',','.').toDoubleOrNull()
    val value=initial.copy(name=name,proposedReservePercent=parsedReserve?:Double.NaN,proposedItems=proposal)
    LazyColumn(Modifier.fillMaxSize().imePadding(),contentPadding=PaddingValues(18.dp),verticalArrangement=Arrangement.spacedBy(14.dp)) {
        item {Text(planningText("Unabhängiger Entwurf","Independent proposal"),style=MaterialTheme.typography.headlineSmall)}
        item {OutlinedTextField(name,{name=it.take(120)},label={Text(planningText("Variantenname","Alternative name"))},modifier=Modifier.fillMaxWidth(),singleLine=true)}
        item {Text(initial.baselineProjectName+" · "+java.text.DateFormat.getDateTimeInstance().format(java.util.Date(initial.capturedAt)),color=Muted)}
        if(initial.baselineIsStale(actual)) item {Text(planningText("Der aktuelle Bestand hat sich geändert. Dieser Vergleich verwendet weiterhin den ursprünglichen Stand.","The current inventory has changed. This comparison still uses its original snapshot."),color=MaterialTheme.colorScheme.error)}
        item {OutlinedTextField(reserve,{reserve=it},label={Text(planningText("Planungsreserve (%)","Planning reserve (%)"))},singleLine=true,modifier=Modifier.fillMaxWidth())}
        if(value.valid) item {val comparison=value.comparison();Card(Modifier.fillMaxWidth(),colors=CardDefaults.cardColors(containerColor=CardSurface)){Column(Modifier.padding(16.dp),verticalArrangement=Arrangement.spacedBy(8.dp)) {
            Text(planningText("Bestand → Variante","Baseline → Proposal"),fontWeight=FontWeight.Bold)
            Text(planningText("Wasserinhalt","Water volume")+": ${format(comparison.baselineWater,1)} → ${format(comparison.proposedWater,1)} l · Δ ${if(comparison.waterDelta>0)"+" else ""}${format(comparison.waterDelta,1)} l")
            Text(planningText("Reserve","Reserve")+": ${format(comparison.baselineReserve,1)} → ${format(comparison.proposedReserve,1)} l · Δ ${if(comparison.proposedReserve-comparison.baselineReserve>0)"+" else ""}${format(comparison.proposedReserve-comparison.baselineReserve,1)} l")
            Text(planningText("Planungsvolumen","Planning volume")+": ${format(comparison.baselinePlanning,1)} → ${format(comparison.proposedPlanning,1)} l · Δ ${if(comparison.planningDelta>0)"+" else ""}${format(comparison.planningDelta,1)} l")
        }}}
        items(proposal,key={it.id}){ item ->Card(Modifier.fillMaxWidth(),colors=CardDefaults.cardColors(containerColor=CardSurface)){Column(Modifier.padding(12.dp)) {
            Text(item.name,fontWeight=FontWeight.Bold);Text("${format(item.liters,2)} l")
            item.source?.let{Text(it,color=Muted)}
            Row {TextButton(onClick={editId=item.id}){Text(planningText("Bauteil bearbeiten","Edit component"))};TextButton(onClick={proposal=proposal.filterNot{it.id==item.id}}){Text(planningText("Entfernen","Remove"))}}
        }}}
        item {OutlinedButton(onClick={add=true},modifier=Modifier.fillMaxWidth()){Text(planningText("Bauteil hinzufügen","Add component"))}}
        item {Text(planningText("Planungsvariante, keine Messung und kein Nachweis eines Umbaus. Herstellerangaben und Quellen prüfen.","Planning scenario, not a measurement or proof of an installed change. Verify manufacturer specifications and sources."),color=Muted)}
        if(!value.valid)item {Text(planningText("Werte prüfen: Name und endliche, nicht negative Volumen und Reserve sind erforderlich.","Check values: a name and finite, nonnegative volumes and reserve are required."),color=MaterialTheme.colorScheme.error)}
        item {Button(onClick={onSave(value)},enabled=value.valid,modifier=Modifier.fillMaxWidth()){Text(planningText("Variante speichern","Save alternative"))}}
        item {OutlinedButton(onClick={onShare(value.report(Locale.getDefault()))},enabled=value.valid,modifier=Modifier.fillMaxWidth()){Text(planningText("Vergleich teilen","Share comparison"))}}
        item {TextButton(onClick=onCancel){Text(planningText("Abbrechen","Cancel"))}}
    }
    if(add)AddItemDialog(onDismiss={add=false},onAdd={proposal=proposal+it;add=false})
    proposal.firstOrNull{it.id==editId}?.let { item ->AlternativeItemEditor(item,onDismiss={editId=null},onSave={updated->proposal=proposal.map{if(it.id==updated.id)updated else it};editId=null}) }
}

@Composable private fun AlternativeItemEditor(item:UiItem,onDismiss:()->Unit,onSave:(UiItem)->Unit) {
    var name by rememberSaveable(item.id){mutableStateOf(item.name)}
    var liters by rememberSaveable(item.id){mutableStateOf(item.liters.toString())}
    var source by rememberSaveable(item.id){mutableStateOf(item.source?:"")}
    var note by rememberSaveable(item.id){mutableStateOf(item.note?:"")}
    val amount=liters.replace(',','.').toDoubleOrNull()
    AlertDialog(onDismissRequest=onDismiss,title={Text(planningText("Bauteil der Variante","Proposal component"))},text={Column(Modifier.imePadding(),verticalArrangement=Arrangement.spacedBy(8.dp)) {
        OutlinedTextField(name,{name=it},label={Text(planningText("Bezeichnung","Name"))})
        OutlinedTextField(liters,{liters=it},label={Text(planningText("Wasserinhalt (l)","Water volume (l)"))})
        OutlinedTextField(source,{source=it},label={Text(planningText("Quelle","Source"))})
        OutlinedTextField(note,{note=it},label={Text(planningText("Notiz","Note"))})
    }},confirmButton={TextButton(onClick={onSave(item.copy(name=name,liters=requireNotNull(amount),source=source.takeIf{it.isNotBlank()},note=note.takeIf{it.isNotBlank()}))},enabled=name.isNotBlank()&&amount!=null&&amount.isFinite()&&amount>=0){Text(planningText("Übernehmen","Apply"))}},dismissButton={TextButton(onClick=onDismiss){Text(planningText("Abbrechen","Cancel"))}})
}
