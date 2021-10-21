scriptname TTT_ArousedNipsConfigMenu extends SKI_ConfigBase

import StorageUtil

TTT_ArousedNipsinterfaceFrostfall Property Frostfallint Auto
TTT_ArousedNipsQuest Property TTT_ArousedNipsMainQuest Auto
Spell Property TTT_ArousedNipsDebugSpell Auto
Quest Property TTT_ArousedNipsComments Auto

float Property range = 3.0 AutoReadOnly hidden

TTT_ArousedNipsAlias Property NipsAlias Auto

float Property PlayerUpdateFreq = 10.0 Auto Hidden
int Property RollAvgCount = 4 Auto Hidden

float Property CommentNipSize = 70.0 Auto Hidden
bool NpcComments = true

string version
string storageKey

int function GetVersion()
	;format = (M)MmmPP
	;12345 => 1.23.45
	return 10302
endFunction

event OnVersionUpdate(int ver)
	int Major = ver / 10000
	int Minor = (ver % 10000) / 100
	int Patch = ver % 100
	version = Major + "." + Minor + "." + Patch

	Debug.Notification("ArousedNips: Updating to " + version)
	Debug.Trace("TTT_ArousedNips: Updating to " + version)

	TTT_ArousedNipsMainQuest.Stop()
	Utility.Wait(1.0)
	TTT_ArousedNipsMainQuest.Start()

	NipsAlias.StopUpdates()
	if PlayerUpdateFreq > 0
		Utility.Wait(1.0)
		NipsAlias.BeginUpdates()
	endif
endEvent

event OnConfigInit()
	Debug.Notification("ArousedNips: Registering MCM. This could take a while.")
	Debug.Trace("TTT_ArousedNips: Registering MCM. This could take a while.")

	while !TTT_ArousedNipsMainQuest.Isinitialized
		Utility.WaitMenuMode(2.0)
	endWhile
	LoadSettings()
	NipsAlias.BeginUpdates()
endEvent

event OnConfigRegister()
	Debug.Notification("ArousedNips: MCM registered!")
	Debug.Trace("TTT_ArousedNips: MCM registered!")

	TTT_ArousedNipsMainQuest.Start()
endEvent

event OnConfigOpen()
	Pages = new string[5]
	pages[0] = "Preferences"
	pages[1] = "Female Morphs"
	pages[2] = "Male Morphs"
	pages[3] = "Female Actors"
	pages[4] = "Male Actors"
endEvent

event OnConfigClose()
endEvent

event OnPageReset(string page)
	SetTitleText("ArousedNips " + version)
	if !(TTT_ArousedNipsMainQuest.isNiOok || TTT_ArousedNipsMainQuest.isSLArousedok)
		AddHeaderOption("Dependencies")
		AddToggleOption("NiOverride (Required)", TTT_ArousedNipsMainQuest.isNiOok)
		AddToggleOption("SexLab Aroused (Required)", TTT_ArousedNipsMainQuest.isSLArousedok)
		AddEmptyOption()
		AddTextOption("This mod requires NiO and SLAX to function!!!", "")
	elseif page == "Preferences"
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		; Left side
		AddHeaderOption("")
		AddToggleOptionST("SillyCommentsToggleST", "Nipple Comments", NpcComments)
		AddSliderOptionST("CommentNipSizeSliderST", "Nipple Size For Comments: ", CommentNipSize, "{0}%")
		AddEmptyOption()

		AddToggleOptionST("IgnoreNPCsToggleST", "Ignore NPCs", TTT_ArousedNipsMainQuest.IgnoreNPCs)
		AddToggleOptionST("IgnoreMalesToggleST", "Ignore Males", TTT_ArousedNipsMainQuest.IgnoreMales)
		AddToggleOptionST("IgnoreFemalesToggleST", "Ignore Females", TTT_ArousedNipsMainQuest.IgnoreFemales)
		AddToggleOptionST("OnlyUniqueNPCsST", "Only Unique NPCs", TTT_ArousedNipsMainQuest.OnlyUniqueNPCs)
		AddEmptyOption()

		AddSliderOptionST("PlayerUpdateFreqSliderST", "Player Update Frequency: ", PlayerUpdateFreq, "{0} seconds")
		AddSliderOptionST("RollAvgCountSliderST", "# Rolling Average Points: ", RollAvgCount, "{0} Updates")

		; Right side
		SetCursorPosition(1)
		AddHeaderOption("Interfaces")
		AddToggleOption("Inflation Framework", NipsAlias.IsSlifInstalled)
		AddToggleOption("Frostfall", Frostfallint.GetIsinterfaceActive())
		AddToggleOption("Milk Mod Economy", NipsAlias.isMMEInstalledProp)
		AddEmptyOption()
		
		AddHeaderOption("")
		AddToggleOptionST("DebugModeToggleST", "Debug mode", TTT_ArousedNipsMainQuest.DebugMode)
		AddEmptyOption()

		AddTextOptionST("ExportSettingsTextST", "Export Settings ", "")
		AddTextOptionST("ImportSettingsTextST", "Import Settings", "")
	elseif page == "Female Morphs"
		storageKey = "female"
		FillMorphList()
	elseif page == "Male Morphs"
		storageKey = "male"
		FillMorphList()
	elseif page == "Female Actors"
		storageKey = "female"
		FillActorList()
	elseif page == "Male Actors"
		storageKey = "male"
		FillActorList()
	endif
endEvent

function FillMorphList()
	AddInputOptionST("AddMorphKeyInputST", "Add Morph", "")
	AddTextOptionST("UpdateMorphsTextST", "Reload Morph List", "")
	AddHeaderOption("Morph at 100 arousal")
	AddHeaderOption("")

	int i = 0
	while i < StringListCount(none, "TTT_ArousedNips_Morphs_" + storageKey)
		string morph = StringListGet(none, "TTT_ArousedNips_Morphs_" + storageKey, i)
		float value = FloatListGet(none, "TTT_ArousedNips_Values_" + storageKey, i)

		AddSliderOptionST("MorphMaxValueSliderST_" + i, morph, value, "{2}")
		AddTextOptionST("DeleteMorphKeyTextST_" + i, "Delete " + morph, "")
		i += 1
	endWhile
endFunction

function FillActorList()
	SetCursorFillMode(LEFT_TO_RIGHT)
	int i = 0
	Actor _actor
	while i < FormListCount(none, "TTT_ArousedNips_Actors_" + storageKey)
		_actor = FormListGet(none, "TTT_ArousedNips_Actors_" + storageKey, i) as Actor
		if _actor
			AddTextOptionST("ClearActorTextST_" + i, _actor.GetLeveledActorBase().GetName() + " | " + _actor.GetFormID(), "")
		endif
		i += 1
	endWhile
endFunction



; ------------------------------------------------------------------------------------
; -------------------------------------- STATES --------------------------------------
; ------------------------------------------------------------------------------------
state SillyCommentsToggleST
	event OnSelectST()
		NpcComments = !NpcComments
		SetToggleOptionValueST(NpcComments)
		if NpcComments
			TTT_ArousedNipsComments.Start()
		Else
			TTT_ArousedNipsComments.Stop()
		endif
	endEvent

	event OnDefaultST()
		NpcComments = true
		SetToggleOptionValueST(NpcComments)
		if NpcComments
			TTT_ArousedNipsComments.Start()
		Else
			TTT_ArousedNipsComments.Stop()
		endif
	endEvent

	event OnHighlightST()
		SetInfoText("Enable/Disable NPC nipple size comments\nComments will only occur when you are naked/wearing clothes\nif you have suggestions for comments feel free to post them in the forum")
	endEvent
endState

state CommentNipSizeSliderST
	event OnSliderOpenST()
		SetSliderDialogStartValue(CommentNipSize)
		SetSliderDialogDefaultValue(70.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialoginterval(1.0)
	endEvent

	event OnSliderAcceptST(float value)
		CommentNipSize = value
		SetSliderOptionValueST(CommentNipSize)
	endEvent

	event OnDefaultST()
		CommentNipSize = 70.0
		SetSliderOptionValueST(CommentNipSize)
	endEvent

	event OnHighlightST()
		SetInfoText("What percentage of maximum size your nipples must be for NPCs to begin commenting on it")
	endEvent
endState

state IgnoreNPCsToggleST
	event OnSelectST()
		TTT_ArousedNipsMainQuest.IgnoreNPCs = !TTT_ArousedNipsMainQuest.IgnoreNPCs
		SetToggleOptionValueST(TTT_ArousedNipsMainQuest.IgnoreNPCs)
	endEvent

	event OnDefaultST()
		TTT_ArousedNipsMainQuest.IgnoreNPCs = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Process only the Player.\nEnabling this doesn't reset morphs already applied to NPCs.")
	endEvent
endState

state IgnoreMalesToggleST
	event OnSelectST()
		TTT_ArousedNipsMainQuest.IgnoreMales = !TTT_ArousedNipsMainQuest.IgnoreMales
		SetToggleOptionValueST(TTT_ArousedNipsMainQuest.IgnoreMales)
	endEvent

	event OnDefaultST()
		TTT_ArousedNipsMainQuest.IgnoreMales = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Do not process male NPCs.\nEnabling this doesn't reset morphs already applied to NPCs.")
	endEvent
endState

state IgnoreFemalesToggleST
	event OnSelectST()
		TTT_ArousedNipsMainQuest.IgnoreFemales = !TTT_ArousedNipsMainQuest.IgnoreFemales
		SetToggleOptionValueST(TTT_ArousedNipsMainQuest.IgnoreFemales)
	endEvent

	event OnDefaultST()
		TTT_ArousedNipsMainQuest.IgnoreFemales = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Do not process female NPCs.\nEnabling this doesn't reset morphs already applied to NPCs.")
	endEvent
endState

state OnlyUniqueNPCsST
	event OnSelectST()
		TTT_ArousedNipsMainQuest.OnlyUniqueNPCs = !TTT_ArousedNipsMainQuest.OnlyUniqueNPCs
		SetToggleOptionValueST(TTT_ArousedNipsMainQuest.OnlyUniqueNPCs)
	endEvent

	event OnDefaultST()
		TTT_ArousedNipsMainQuest.OnlyUniqueNPCs = true
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Process only unique NPCs.\nEnabling this doesn't reset morphs already applied to NPCs.")
	endEvent
endState

state PlayerUpdateFreqSliderST
	event OnSliderOpenST()
		SetSliderDialogStartValue(PlayerUpdateFreq)
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(0.0, 300.0)
		SetSliderDialoginterval(1.0)
	endEvent

	event OnSliderAcceptST(float value)
		PlayerUpdateFreq = value
		SetSliderOptionValueST(PlayerUpdateFreq)

		if PlayerUpdateFreq > 0
			NipsAlias.BeginUpdates()
		Else
			NipsAlias.StopUpdates()
		endif
	endEvent

	event OnDefaultST()
		PlayerUpdateFreq = 10.0
		SetSliderOptionValueST(PlayerUpdateFreq)
	endEvent

	event OnHighlightST()
		SetInfoText("How often to update the player character\nSetting to 0 will disable MME/Frostfall updates. Updates from arousal will still occur")
	endEvent
endState

state RollAvgCountSliderST
	event OnSliderOpenST()
		SetSliderDialogStartValue(RollAvgCount)
		SetSliderDialogDefaultValue(4.0)
		SetSliderDialogRange(1.0, 50.0)
		SetSliderDialoginterval(1.0)
	endEvent

	event OnSliderAcceptST(float value)
		RollAvgCount = value as int
		SetSliderOptionValueST(RollAvgCount)
	endEvent

	event OnDefaultST()
		RollAvgCount = 4
		SetSliderOptionValueST(RollAvgCount)
	endEvent

	event OnHighlightST()
		SetInfoText("How many rolling average updates to base nipple size on\nNipple size for the player is an average of the last X amount of updates\nYour update frequency and how smooth you want nipple size to change will determine what you set this to\nToo low and nipple size will 'pop' to size. Too high and nipple size will be slow to react\nChanging this setting may make nipple size take some time to 'level off' initially")
	endEvent
endState

state ExportSettingsTextST
	event OnSelectST()
		SetTextOptionValueST("Exporting Settings ")
		if ShowMessage("Overwrite settings file with your current settings?")
			SaveSettings()
			SetTextOptionValueST("Done! ")
		Else
			SetTextOptionValueST("")
		endif
	endEvent

	event OnHighlightST()
		SetInfoText("Export your settings to file")
	endEvent
endState

state ImportSettingsTextST
	event OnSelectST()
		SetTextOptionValueST("Importing Settings ")
		if ShowMessage("Overwrite your current settings with the settings saved to file?")
			LoadSettings()
			SetTextOptionValueST("Done! ")
		Else
			SetTextOptionValueST("")
		endif
	endEvent

	event OnHighlightST()
		SetInfoText("Import your settings from file")
	endEvent
endState

state DebugModeToggleST
	event OnSelectST()
		TTT_ArousedNipsMainQuest.DebugMode = !TTT_ArousedNipsMainQuest.DebugMode
		SetToggleOptionValueST(TTT_ArousedNipsMainQuest.DebugMode)
	endEvent

	event OnDefaultST()
		TTT_ArousedNipsMainQuest.DebugMode = false
		SetToggleOptionValueST(false)
	endEvent

	event OnHighlightST()
		SetInfoText("Print debug info to screen and log.")
	endEvent
endState

state AddMorphKeyInputST
	event OnInputAcceptST(string value)
		if JsonUtil.CanResolvePath("Aroused Nips/MorphList.json", "." + storageKey + "." + value)
			return
		endif

		JsonUtil.SetPathFloatValue("Aroused Nips/MorphList.json", "." + storageKey + "." + value, GetDefaultValue(value, storageKey))
		JsonUtil.Save("Aroused Nips/MorphList.json")

		TTT_ArousedNipsMainQuest.ReloadMorphList(storageKey)
		ForcePageReset()
	endEvent
endState

state UpdateMorphsTextST
	event OnSelectST()
		SetTextOptionValueST("Working...")

		TTT_ArousedNipsMainQuest.ReloadMorphList(storageKey)
		ForcePageReset()

		SetTextOptionValueST("DONE")
	endEvent

	event OnHighlightST()
		SetInfoText("Reload Morphs from the json file.\nUse if you have manually edited MorphList.json")
	endEvent
endState



; ------------------------------------------------------------------------------------
; -------------------------------------- MORPHS --------------------------------------
; ------------------------------------------------------------------------------------
event OnSliderOpenST()
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _index = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		SetSliderDialogRange(-range, range)
		SetSliderDialoginterval(0.01)
		SetSliderDialogStartValue(FloatListGet(none, "TTT_ArousedNips_Values_" + storageKey, _index))
		SetSliderDialogDefaultValue(GetDefaultValue(StringListGet(none, "TTT_ArousedNips_Morphs_" + storageKey, _index), storageKey))
	endif
endEvent

event OnSliderAcceptST(float value)
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _index = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		FloatListSet(none, "TTT_ArousedNips_Values_" + storageKey, _index, value)

		JsonUtil.SetPathFloatValue("Aroused Nips/MorphList.json", "." + storageKey + "." + StringListGet(none, "TTT_ArousedNips_Morphs_" + storageKey, _index), value)
		JsonUtil.Save("Aroused Nips/MorphList.json")

		SetSliderOptionValueST(value, "{2}", false, _state)
	endif
endEvent

event OnSelectST()
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _index = _stateName[1] as int

	if _stateName[0] == "DeleteMorphKeyTextST"
		SetTextOptionValueST("Working...")
		string morphKey = StringListGet(none, "TTT_ArousedNips_Morphs_" + storageKey, _index)
		if ShowMessage("Are you sure you want to delete '" + morphKey + "'' morph?")
			JsonUtil.ClearPath("Aroused Nips/MorphList.json", "." + storageKey + "." + morphKey)
			JsonUtil.Save("Aroused Nips/MorphList.json")

			TTT_ArousedNipsMainQuest.ReloadMorphList(storageKey)
			ForcePageReset()
		Else
			SetTextOptionValueST("", false, _state)
		endif
	elseif _stateName[0] == "ClearActorTextST"
		Actor _actor = FormListGet(none, "TTT_ArousedNips_Actors_" + storageKey, _index) as Actor
		TTT_ArousedNipsMainQuest.ClearMorphs(_actor, StringListToArray(none, "TTT_ArousedNips_Morphs_" + storageKey))
		FormListRemoveAt(none, "TTT_ArousedNips_Actors_" + storageKey, _index)
		ForcePageReset()
	endif
endEvent

event OnDefaultST()
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _index = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		string morphKey = StringListGet(none, "TTT_ArousedNips_Morphs_" + storageKey, _index)
		float defaultValue = GetDefaultValue(morphKey, storageKey)

		FloatListSet(none, "TTT_ArousedNips_Values_" + storageKey, _index, defaultValue)

		JsonUtil.SetPathFloatValue("Aroused Nips/MorphList.json", "." + storageKey + "." + morphKey, defaultValue)
		JsonUtil.Save("Aroused Nips/MorphList.json")

		SetSliderOptionValueST(defaultValue, "{2}", false, _state)
	endif
endEvent

event OnHighlightST()
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _index = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		string morphKey = StringListGet(none, "TTT_ArousedNips_Morphs_" + storageKey, _index)

		SetInfoText(morphKey + " at 100 arousal.\nDefault: " + GetDefaultValue(morphKey, storageKey))
	endif
endEvent



; ------------------------------------------------------------------------------------
; --------------------------------------- JSON ---------------------------------------
; ------------------------------------------------------------------------------------
function SaveSettings()
	; floats
	JsonUtil.SetfloatValue("Aroused Nips/Settings.json", "CommentNipSize", CommentNipSize)
	JsonUtil.SetfloatValue("Aroused Nips/Settings.json", "PlayerUpdateFreq", PlayerUpdateFreq)

	; bools
	JsonUtil.SetintValue("Aroused Nips/Settings.json", "IgnoreMales", TTT_ArousedNipsMainQuest.IgnoreMales as int)
	JsonUtil.SetintValue("Aroused Nips/Settings.json", "IgnoreNPCs", TTT_ArousedNipsMainQuest.IgnoreNPCs as int)
	JsonUtil.SetintValue("Aroused Nips/Settings.json", "IgnoreFemales", TTT_ArousedNipsMainQuest.IgnoreFemales as int)
	JsonUtil.SetintValue("Aroused Nips/Settings.json", "OnlyUniqueNPCs", TTT_ArousedNipsMainQuest.OnlyUniqueNPCs as int)
	JsonUtil.SetintValue("Aroused Nips/Settings.json", "DebugMode", TTT_ArousedNipsMainQuest.DebugMode as int)
	JsonUtil.SetintValue("Aroused Nips/Settings.json", "NpcComments", NpcComments as int)

	; ints
	JsonUtil.SetintValue("Aroused Nips/Settings.json", "RollAvgCount", RollAvgCount)

	JsonUtil.Save("Aroused Nips/Settings.json")
endFunction

function LoadSettings()
	; floats
	CommentNipSize = JsonUtil.GetfloatValue("Aroused Nips/Settings.json", "CommentNipSize", Missing = 70.0)
	PlayerUpdateFreq = JsonUtil.GetfloatValue("Aroused Nips/Settings.json", "PlayerUpdateFreq", Missing = 10.0)

	; bools
	TTT_ArousedNipsMainQuest.IgnoreMales = JsonUtil.GetintValue("Aroused Nips/Settings.json", "IgnoreMales", Missing = 1)
	TTT_ArousedNipsMainQuest.IgnoreNPCs = JsonUtil.GetintValue("Aroused Nips/Settings.json", "IgnoreNPCs", Missing = 0)
	TTT_ArousedNipsMainQuest.IgnoreFemales = JsonUtil.GetintValue("Aroused Nips/Settings.json", "IgnoreFemales", Missing = 0)
	TTT_ArousedNipsMainQuest.OnlyUniqueNPCs = JsonUtil.GetintValue("Aroused Nips/Settings.json", "OnlyUniqueNPCs", Missing = 1)
	TTT_ArousedNipsMainQuest.DebugMode = JsonUtil.GetintValue("Aroused Nips/Settings.json", "DebugMode", Missing = 0)
	NpcComments = JsonUtil.GetintValue("Aroused Nips/Settings.json", "NpcComments", Missing = 1)

	; ints
	RollAvgCount = JsonUtil.GetintValue("Aroused Nips/Settings.json", "RollAvgCount", Missing = 4)

	ForcePageReset()
endFunction

float function GetDefaultValue(string morphKey, string sex)
	if sex == "female"
		if morphKey == "NippleSize"
			return -0.75
		elseif morphKey == "NippleLength"
			return 1.0
		elseif morphKey == "NipplePerkiness"
			return 1.5
		elseif morphKey == "ClitorisErection"
			return 1.0
		endif
	else
		if morphKey == "NipsTips"
			return 1.0
		elseif morphKey == "NipsLength"
			return 1.0
		elseif morphKey == "NipsPuffy"
			return 0.1
		endif
	endif
	return 0.0
endFunction
