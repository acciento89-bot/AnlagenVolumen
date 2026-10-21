package de.kamilunavo.volumecalc

import java.text.DateFormat
import java.text.NumberFormat
import java.util.Date
import java.util.Locale
import java.util.UUID

/** Frozen aggregate component values; original quantity/geometry is never invented. */
internal data class DesignAlternative(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val capturedAt: Long,
    val baselineProjectId: String,
    val baselineProjectName: String,
    val baselineReservePercent: Double,
    val baselineItems: List<UiItem>,
    val proposedReservePercent: Double,
    val proposedItems: List<UiItem>,
) {
    companion object {
        fun capture(project: UiProject, name: String, capturedAt: Long = System.currentTimeMillis()) = DesignAlternative(
            name=name,capturedAt=capturedAt,baselineProjectId=project.id,baselineProjectName=project.name,
            baselineReservePercent=project.reservePercent,baselineItems=project.items.toList(),
            proposedReservePercent=project.reservePercent,proposedItems=project.items.toList(),
        )
        private fun validItems(items: List<UiItem>, reserve: Double): Boolean {
            if (items.size > 2000 || items.map { it.id }.toSet().size != items.size ||
                !reserve.isFinite() || reserve < 0 || items.any { !it.liters.isFinite() || it.liters < 0 }) return false
            val water=items.sumOf { it.liters };val allowance=water*reserve/100.0
            return water.isFinite() && allowance.isFinite() && (water+allowance).isFinite()
        }
    }
    val valid: Boolean get() = name.isNotBlank() && name.length<=120 &&
        validItems(baselineItems,baselineReservePercent) && validItems(proposedItems,proposedReservePercent)

    fun baselineIsStale(actual: UiProject): Boolean {
        if (actual.id!=baselineProjectId || actual.reservePercent!=baselineReservePercent ||
            actual.items.size!=baselineItems.size || actual.items.map{it.id}.toSet().size!=actual.items.size) return true
        val current=actual.items.associateBy{it.id}
        return baselineItems.any{current[it.id]!=it}
    }
    fun comparison(): DesignComparison {
        require(valid) { "Invalid design alternative" }
        val old=baselineItems.associateBy{it.id};val new=proposedItems.associateBy{it.id}
        val changes=baselineItems.mapNotNull { item ->
            val proposed=new[item.id]
            when {
                proposed==null -> ComponentChange(ComponentChangeKind.REMOVED,item.id,item,null)
                proposed!=item -> ComponentChange(ComponentChangeKind.CHANGED,item.id,item,proposed)
                else -> null
            }
        } + proposedItems.filter{it.id !in old}.map{ComponentChange(ComponentChangeKind.ADDED,it.id,null,it)}
        return DesignComparison(baselineItems.sumOf{it.liters},proposedItems.sumOf{it.liters},baselineReservePercent,proposedReservePercent,changes)
    }
    fun report(locale: Locale): String {
        val result=comparison();val de=locale.language=="de"
        val number=NumberFormat.getNumberInstance(locale).apply{minimumFractionDigits=1;maximumFractionDigits=2}
        fun liters(value:Double,signed:Boolean=false)=(if(signed&&value>0)"+" else "")+number.format(value)+" l"
        fun item(value:UiItem):String=buildString {
            append(value.name+": "+liters(value.liters))
            value.source?.takeIf{it.isNotBlank()}?.let{append(" · "+(if(de)"Quelle" else "Source")+": "+it)}
            value.note?.takeIf{it.isNotBlank()}?.let{append(" · "+it)}
        }
        val date=DateFormat.getDateTimeInstance(DateFormat.MEDIUM,DateFormat.SHORT,locale).format(Date(capturedAt))
        return buildList {
            add(if(de)"VolumeCalc · Variantenvergleich" else "VolumeCalc · Design comparison")
            add(baselineProjectName);add(name);add((if(de)"Bestand erfasst: " else "Baseline captured: ")+date);add("")
            add(if(de)"Bestand → Variante (Differenz)" else "Baseline → Proposal (difference)")
            listOf(
                Triple(if(de)"Berechneter Wasserinhalt" else "Calculated water volume",result.baselineWater,result.proposedWater),
                Triple(if(de)"Reserve" else "Reserve",result.baselineReserve,result.proposedReserve),
                Triple(if(de)"Planungsvolumen" else "Planning volume",result.baselinePlanning,result.proposedPlanning)
            ).forEach{(label,before,after)->add("$label: ${liters(before)} → ${liters(after)} (${liters(after-before,true)})")}
            add("");add(if(de)"Bauteiländerungen" else "Component changes")
            if(result.changes.isEmpty())add(if(de)"Keine Bauteiländerungen" else "No component changes")
            result.changes.forEach { change ->
                when(change.kind) {
                    ComponentChangeKind.ADDED -> add("+ "+item(requireNotNull(change.after)))
                    ComponentChangeKind.REMOVED -> add("− "+item(requireNotNull(change.before)))
                    ComponentChangeKind.CHANGED -> {add("~ "+item(requireNotNull(change.before)));add("  → "+item(requireNotNull(change.after)))}
                }
            }
            add("")
            add(if(de)"Planungsvariante, keine Messung und kein Nachweis eines Umbaus. Herstellerangaben und Quellen prüfen. Der tatsächliche Bestand und bestehende Füllprüfungen bleiben unverändert." else "Planning scenario, not a measurement or proof of an installed change. Verify manufacturer specifications and sources. The actual inventory and existing fill audits remain unchanged.")
        }.joinToString("\n")
    }
}
internal enum class ComponentChangeKind { ADDED, REMOVED, CHANGED }
internal data class ComponentChange(val kind:ComponentChangeKind,val id:String,val before:UiItem?,val after:UiItem?)
internal data class DesignComparison(val baselineWater:Double,val proposedWater:Double,val baselineReservePercent:Double,val proposedReservePercent:Double,val changes:List<ComponentChange>) {
    val baselineReserve get()=baselineWater*baselineReservePercent/100.0
    val proposedReserve get()=proposedWater*proposedReservePercent/100.0
    val baselinePlanning get()=baselineWater+baselineReserve
    val proposedPlanning get()=proposedWater+proposedReserve
    val waterDelta get()=proposedWater-baselineWater
    val planningDelta get()=proposedPlanning-baselinePlanning
}
