package de.kamilunavo.volumecalc

import org.json.JSONArray
import org.json.JSONObject

/** Strict snapshot decoding: damaged proposals must never silently become empty data. */
internal object AlternativeJson {
 private fun items(values:List<UiItem>,draft:Boolean=false)=JSONArray().apply { values.forEach { item ->
  put(JSONObject().put("id",item.id).put("name",item.name).put("liters",if(draft)item.liters.toString() else item.liters)
   .put("kind",item.kind).put("source",item.source?:JSONObject.NULL).put("note",item.note?:JSONObject.NULL))
 } }
 private fun readItems(values:JSONArray)=List(values.length()){ i ->
  val item=values.getJSONObject(i)
  UiItem(id=item.getString("id"),name=item.getString("name"),liters=item.getDouble("liters"),kind=item.getString("kind"),
   source=if(item.isNull("source"))null else item.getString("source"),note=if(item.isNull("note"))null else item.getString("note"))
 }
 fun encode(value:DesignAlternative):JSONObject {
  require(value.valid)
  return encodeValue(value,false)
 }
 // Lifecycle state must preserve incomplete/invalid input without treating it as persisted data.
 fun encodeDraft(value:DesignAlternative)=encodeValue(value,true)
 private fun encodeValue(value:DesignAlternative,draft:Boolean):JSONObject {
  return JSONObject().put("id",value.id).put("name",value.name).put("capturedAt",value.capturedAt)
   .put("baselineProjectId",value.baselineProjectId).put("baselineProjectName",value.baselineProjectName)
   .put("baselineReservePercent",if(draft)value.baselineReservePercent.toString() else value.baselineReservePercent).put("baselineItems",items(value.baselineItems,draft))
   .put("proposedReservePercent",if(draft)value.proposedReservePercent.toString() else value.proposedReservePercent).put("proposedItems",items(value.proposedItems,draft))
 }
 fun decode(value:JSONObject)=decodeDraft(value).also { require(it.valid) }
 fun decodeDraft(value:JSONObject)=DesignAlternative(
  id=value.getString("id"),name=value.getString("name"),capturedAt=value.getLong("capturedAt"),
  baselineProjectId=value.getString("baselineProjectId"),baselineProjectName=value.getString("baselineProjectName"),
  baselineReservePercent=value.getDouble("baselineReservePercent"),baselineItems=readItems(value.getJSONArray("baselineItems")),
  proposedReservePercent=value.getDouble("proposedReservePercent"),proposedItems=readItems(value.getJSONArray("proposedItems"))
 )
}
