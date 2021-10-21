ScriptName TTT_ArousedNipsQuest extends Quest Conditional
{Hosts all state.}

import StorageUtil

TTT_ArousedNipsAlias Property TTT_ArousedNipsPlayerAlias Auto

bool Property SillyComments = False Auto Hidden Conditional

bool Property isNioOk = false Auto Hidden
bool Property isSLArousedOk = false Auto Hidden

bool Property DebugMode = false Auto Hidden
bool Property Isinitialized = false Auto Hidden

bool Property IgnoreMales = true Auto Hidden
bool Property IgnoreFemales = false Auto Hidden
bool Property IgnoreNPCs = false Auto Hidden
bool Property OnlyUniqueNPCs = true Auto Hidden

string[] Property MorphNames Auto Hidden
float[] Property MaxValue Auto Hidden
float[] Property MaxDefault Auto Hidden

string[] Property MaleMorphNames Auto Hidden
float[] Property MaleMaxValue Auto Hidden
float[] Property MaleMaxDefault Auto Hidden

event OnInit()
{First-time setup. Setting all defaults.}

	;Note: this initialization is performed only once.
	Debug.Notification("ArousedNips: first time initialization")
	Debug.Trace("TTT_ArousedNips: first time initialization")

	ReloadMorphList("female")
	ReloadMorphList("male")

	TTT_ArousedNipsPlayerAlias.OnPlayerLoadGame()
	Isinitialized = true

	Debug.Notification("ArousedNips: initialization complete. Settings imported from file")
	debug.Trace("TTT_ArousedNips: initialization complete")
endEvent

function ReloadMorphList(string storageKey)
	; Reload json file
	JsonUtil.Unload("Aroused Nips/MorphList.json")
	if !JsonUtil.IsGood("Aroused Nips/MorphList.json")
		Debug.MessageBox("Aroused Nips: Couldnt load MophList.json.\n\n" + JsonUtil.GetErrors("Aroused Nips/MorphList.json") + "\nPlease check its formatting and data structure and reload the file using a button in MCM menu.\nFormat and structure referece can be found in the example file (MorphListExample.json)")
		return
	endif

	; cache new values
	string[] tempnames = JsonUtil.PathMembers("Aroused Nips/MorphList.json", "." + storageKey + ".")
	float[] tempvalues = Utility.CreateFloatArray(tempnames.Length)

	int i = 0
	float tempvalue
	while i < tempnames.Length
		tempvalue = JsonUtil.GetPathfloatValue("Aroused Nips/MorphList.json", "." + storageKey + "." + tempnames[i], 0.0)
		tempvalues[i] = tempvalue
		i += 1
	endWhile

	; clear old morphs and add new morphs keeping our existing data
	i = 0
	int j = -1
	string morphKey
	while i < StringListCount(none, "TTT_ArousedNips_Morphs_" + storageKey)
		morphKey = StringListGet(none, "TTT_ArousedNips_Morphs_" + storageKey, i)
		j = tempnames.Find(morphKey)
		if j < 0 ; morph was NOT found in the list
			; add it to the list to clear it later
			StringListAdd(none, "TTT_ArousedNips_MorphsToClear", morphKey, false)
		else
			; overwrite with existing values (if names match)
			tempvalues[j] = FloatListGet(none, "TTT_ArousedNips_Values_" + storageKey, i)
		endif
		i += 1
	endWhile

	; set actual values to be used
	StringListCopy(none, "TTT_ArousedNips_Morphs_" + storageKey, tempnames)
	FloatListCopy(none, "TTT_ArousedNips_Values_" + storageKey, tempvalues)

	; clear removed morphs
	if StringListCount(none, "TTT_ArousedNips_MorphsToClear") > 0
		i = FormListCount(none, "TTT_ArousedNips_Actors_" + storageKey) - 1
		Actor _actor
		while i >= 0
			_actor = FormListGet(none, "TTT_ArousedNips_Actors_" + storageKey, i) as Actor
			ClearMorphs(_actor, StringListToArray(none, "TTT_ArousedNips_MorphsToClear"))
			if StringListCount(_actor, "TTT_ArousedNips_MorphsApplied") == 0
				FormListRemoveAt(_actor, "TTT_ArousedNips_Actors_" + storageKey, i)
			endif
			i -= 1
		endWhile
		StringListClear(none, "TTT_ArousedNips_MorphsToClear")
	endif
endFunction

function ClearMorphs(actor who, string[] morphList)
	if who
		int i = 0
		while i < morphList.Length
			ClearMorph(who, morphList[i], TTT_ArousedNipsPlayerAlias.IsSlifInstalled)
			i += 1
		endWhile
	endif
endFunction

function ClearMorph(actor who, string morphKey, bool slif)
	if slif
		int SLif_event = Modevent.Create("SLif_unregisterMorph")
		if (SLif_event)
			Modevent.PushForm(SLif_event, who)
			Modevent.PushString(SLif_event, TTT_ArousedNipsPlayerAlias.SLIF_KEY)
			Modevent.PushString(SLif_event, morphKey)
			Modevent.Send(SLif_event)
		endif
	else
		NiOverride.ClearBodyMorph(who, morphKey, TTT_ArousedNipsPlayerAlias.NIO_KEY)
		; update actor mophs to reflect changes (in case morphs were removed)
		;if who.Is3DLoaded() && NiOverride.GetMorphNames(who).length > 0
			NiOverride.UpdateModelWeight(who)
		;endif
	endif
	StringListRemoveAt(who, "TTT_ArousedNips_MorphsApplied", StringListFind(who, "TTT_ArousedNips_MorphsApplied", morphKey))
endfunction
