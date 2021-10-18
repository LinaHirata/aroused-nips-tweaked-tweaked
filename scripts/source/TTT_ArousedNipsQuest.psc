ScriptName TTT_ArousedNipsQuest extends Quest Conditional
{Hosts all state.}

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

	;ResetDefaults()
	ReloadMorphList()

	TTT_ArousedNipsPlayerAlias.OnPlayerLoadGame()
	Isinitialized = true

	Debug.Notification("ArousedNips: initialization complete. Settings imported from file")
	debug.Trace("TTT_ArousedNips: initialization complete")
endEvent

function ResetDefaults()
{Keeps defaults up-to-date}

;/ 	MaxDefault = new float[4]
	MaxDefault[0] = DefaultSize
	MaxDefault[1] = DefaultLength
	MaxDefault[2] = DefaultCone
	MaxDefault[3] = DefaultArea /;
endFunction

function ReloadMorphList()
	; Reload json file
	JsonUtil.Unload("Aroused Nips/MorphList.json")
	if !JsonUtil.IsGood("Aroused Nips/MorphList.json")
		Debug.MessageBox("Aroused Nips: Couldnt load MophList.json.\n\n" + JsonUtil.GetErrors("Aroused Nips/MorphList.json") + "\nPlease check its formatting and data structure and reload the file using a button in MCM menu.\nFormat and structure referece can be found in the example file (MorphListExample.json)")
		return
	endif

;/ ------------------------------------------------------------------------------------------------------------
 ----------------------------------------------- FEMALE SECTION -----------------------------------------------
 -------------------------------------------------------------------------------------------------------------- /;
	; cache new values
	string[] tempnames = JsonUtil.PathMembers("Aroused Nips/MorphList.json", ".female.")
	float[] tempvalues = Utility.CreatefloatArray(tempnames.Length)
	MaxDefault = Utility.CreatefloatArray(tempnames.Length)

	int i = 0
	float tempvalue = 0.0
	while i < tempnames.Length
		tempvalue = JsonUtil.GetPathfloatValue("Aroused Nips/MorphList.json", ".female." + tempnames[i], 0.0)
		tempvalues[i] = tempvalue
		MaxDefault[i] = tempvalue
		i += 1
	endWhile

	; clear old morphs and add new morphs keeping our existing data
	i = 0
	int j = -1
	int k = 0
	while i < MorphNames.Length
		j = tempnames.Find(MorphNames[i])
		if j < 0 ; morph wasnt found in the list
			; clear applied morphs
			while k < StorageUtil.FormListCount(none, "TTT_ArousedNips_FemaleActors")
				Actor _actor = StorageUtil.FormListGet(none, "TTT_ArousedNips_FemaleActors", k) as Actor
				if TTT_ArousedNipsPlayerAlias.IsSlifInstalled
					int SLif_event = Modevent.Create("SLif_unregisterMorph")
					if (SLif_event)
						Modevent.PushForm(SLif_event, _actor)
						Modevent.PushString(SLif_event, "Aroused Nips")
						Modevent.PushString(SLif_event, MorphNames[i])
						Modevent.Send(SLif_event)
					endif
				else
					NiOverride.ClearBodyMorph(_actor, MorphNames[i], TTT_ArousedNipsPlayerAlias.NIO_KEY)
					; update actor mophs to reflect changes (in case morphs were removed)
					;if _actor.Is3DLoaded() && NiOverride.GetMorphNames(_actor).length > 0
						NiOverride.UpdateModelWeight(_actor)
					;endif
				endif
				k += 1
			endWhile
		else
			; overwrite with existing values (if names match)
			tempvalues[j] = MaxValue[i]
		endif
		i += 1
	endWhile

	; set actual values to be used
	MorphNames = tempnames
	MaxValue = tempvalues

;/ ------------------------------------------------------------------------------------------------------------
 ------------------------------------------------ MALE SECTION ------------------------------------------------
 -------------------------------------------------------------------------------------------------------------- /;
	; cache new values
	tempnames = JsonUtil.PathMembers("Aroused Nips/MorphList.json", ".male.")
	tempvalues = Utility.CreatefloatArray(tempnames.Length)
	MaleMaxDefault = Utility.CreatefloatArray(tempnames.Length)

	i = 0
	while i < tempnames.Length
		tempvalue = JsonUtil.GetPathfloatValue("Aroused Nips/MorphList.json", ".male." + tempnames[i], 0.0)
		tempvalues[i] = tempvalue
		MaleMaxDefault[i] = tempvalue
		i += 1
	endWhile

	; clear old morphs and add new morphs keeping our existing data
	i = 0
	j = -1
	k = 0
	while i < MaleMorphNames.Length
		j = tempnames.Find(MaleMorphNames[i])
		if j < 0 ; morph wasnt found in the list
			; clear applied morphs
			while k < StorageUtil.FormListCount(none, "TTT_ArousedNips_MaleActors")
				Actor _actor = StorageUtil.FormListGet(none, "TTT_ArousedNips_MaleActors", k) as Actor
				if TTT_ArousedNipsPlayerAlias.IsSlifInstalled
					int SLif_event = Modevent.Create("SLif_unregisterMorph")
					if (SLif_event)
						Modevent.PushForm(SLif_event, _actor)
						Modevent.PushString(SLif_event, "Aroused Nips")
						Modevent.PushString(SLif_event, MaleMorphNames[i])
						Modevent.Send(SLif_event)
					endif
				else
					NiOverride.ClearBodyMorph(_actor, MaleMorphNames[i], TTT_ArousedNipsPlayerAlias.NIO_KEY)
					; update actor mophs to reflect changes (in case morphs were removed)
					;if _actor.Is3DLoaded() && NiOverride.GetMorphNames(_actor).length > 0
						NiOverride.UpdateModelWeight(_actor)
					;endif
				endif
				k += 1
			endWhile
		else
			; overwrite with existing values (if names match)
			tempvalues[j] = MaleMaxValue[i]
		endif
		i += 1
	endWhile

	; set actual values to be used
	MaleMorphNames = tempnames
	MaleMaxValue = tempvalues
endFunction
