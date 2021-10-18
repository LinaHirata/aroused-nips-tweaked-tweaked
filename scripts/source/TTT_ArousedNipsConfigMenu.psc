scriptname TTT_ArousedNipsConfigMenu extends SKI_ConfigBase

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

int hasReqFlag
string version
bool toggleDebugSpell = false

int function GetVersion()
	;format = (M)MmmPP
	;12345 => 1.23.45
	return 10301
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
	Pages = new string[4]
	pages[0] = "Preferences"
	pages[1] = "Female Morphs"
	pages[2] = "Male Morphs"
	pages[3] = "Affected Actors"

	bool isOk = TTT_ArousedNipsMainQuest.isNioOk && TTT_ArousedNipsMainQuest.isSLArousedOk

	hasReqFlag = OPTION_FLAG_DISABLED * (!isOk) as int
endEvent

event OnConfigClose()
	if toggleDebugSpell
		if TTT_ArousedNipsMainQuest.DebugMode
			Game.GetPlayer().AddSpell(TTT_ArousedNipsDebugSpell)
		else
			Game.GetPlayer().RemoveSpell(TTT_ArousedNipsDebugSpell)
		endif
		toggleDebugSpell = false
	endif
endEvent

event OnPageReset(string page)
	SetTitleText("ArousedNips " + version)
	if !TTT_ArousedNipsMainQuest.isNiOok || !TTT_ArousedNipsMainQuest.isSLArousedok
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
		AddInputOptionST("AddMorphKeyInputST", "Add Morph", "")
		AddTextOptionST("UpdateMorphsTextST", "Reload Morph List", "")
		AddHeaderOption("Morph at 100 arousal")
		AddHeaderOption("")

		int i = 0
		while i < TTT_ArousedNipsMainQuest.MorphNames.Length
			AddSliderOptionST("MorphMaxValueSliderST_" + i, TTT_ArousedNipsMainQuest.MorphNames[i], TTT_ArousedNipsMainQuest.MaxValue[i], "{2}", hasReqFlag)
			AddTextOptionST("DeleteMorphKeyTextST_" + i, "Delete " + TTT_ArousedNipsMainQuest.MorphNames[i], "")
			i += 1
		endWhile
	elseif page == "Male Morphs"
		AddInputOptionST("AddMaleMorphKeyInputST", "Add Morph", "")
		AddTextOptionST("UpdateMorphsTextST", "Reload Morph List", "")
		AddHeaderOption("Morph at 100 arousal")
		AddHeaderOption("")

		int i = 0
		while i < TTT_ArousedNipsMainQuest.MaleMorphNames.Length
			AddSliderOptionST("MaleMorphMaxValueSliderST_" + i, TTT_ArousedNipsMainQuest.MaleMorphNames[i], TTT_ArousedNipsMainQuest.MaleMaxValue[i], "{2}", hasReqFlag)
			AddTextOptionST("MaleDeleteMorphKeyTextST_" + i, "Delete " + TTT_ArousedNipsMainQuest.MaleMorphNames[i], "")
			i += 1
		endWhile
	elseif page == "Affected Actors"
		int k = 0
		ActorBase _actor
		while k < StorageUtil.FormListCount(none, "TTT_ArousedNips_FemaleActors")
			_actor = (StorageUtil.FormListGet(none, "TTT_ArousedNips_FemaleActors", k) as Actor).GetLeveledActorBase()
			if _actor
				AddTextOption(_actor.GetName(), "")
			endif
			k += 1
		endWhile

		SetCursorPosition(1)
		k = 0
		while k < StorageUtil.FormListCount(none, "TTT_ArousedNips_MaleActors")
			_actor = (StorageUtil.FormListGet(none, "TTT_ArousedNips_MaleActors", k) as Actor).GetLeveledActorBase()
			if _actor
				AddTextOption(_actor.GetName(), "")
			endif
			k += 1
		endWhile
	endif
endEvent



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
		toggleDebugSpell = true
	endEvent

	event OnDefaultST()
		TTT_ArousedNipsMainQuest.DebugMode = false
		SetToggleOptionValueST(false)
		toggleDebugSpell = true
	endEvent

	event OnHighlightST()
		SetInfoText("Print debug info to screen and log.")
	endEvent
endState

state AddMorphKeyInputST
	event OnInputAcceptST(string value)
		float default = 0.0
		if value == "NippleSize"
			default = -0.75
		elseif value == "NippleLength"
			default = 1.0
		elseif value == "NipplePerkiness"
			default = 1.5
		elseif value == "ClitorisErection"
			default = 1.0
		endif

		JsonUtil.SetPathFloatValue("Aroused Nips/MorphList.json", ".female." + value, default)
		JsonUtil.Save("Aroused Nips/MorphList.json")

		TTT_ArousedNipsMainQuest.ReloadMorphList()
		ForcePageReset()
	endEvent
endState

state AddMaleMorphKeyInputST
	event OnInputAcceptST(string value)
		float default = 0.0
		if value == "NippleSize"
			default = -0.75
		elseif value == "NippleLength"
			default = 1.0
		elseif value == "NipplePerkiness"
			default = 1.5
		elseif value == "ClitorisErection"
			default = 1.0
		endif

		JsonUtil.SetPathFloatValue("Aroused Nips/MorphList.json", ".male." + value, default)
		JsonUtil.Save("Aroused Nips/MorphList.json")

		TTT_ArousedNipsMainQuest.ReloadMorphList()
		ForcePageReset()
	endEvent
endState

state UpdateMorphsTextST
	event OnSelectST()
		SetTextOptionValueST("Working...")

		TTT_ArousedNipsMainQuest.ReloadMorphList()
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
    int _key = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		SetSliderDialogRange(-range, range)
		SetSliderDialoginterval(0.01)
		SetSliderDialogStartValue(TTT_ArousedNipsMainQuest.MaxValue[_key])
		SetSliderDialogDefaultValue(TTT_ArousedNipsMainQuest.MaxDefault[_key])
	elseif _stateName[0] == "MaleMorphMaxValueSliderST"
		SetSliderDialogRange(-range, range)
		SetSliderDialoginterval(0.01)
		SetSliderDialogStartValue(TTT_ArousedNipsMainQuest.MaleMaxValue[_key])
		SetSliderDialogDefaultValue(TTT_ArousedNipsMainQuest.MaleMaxDefault[_key])
	endif
endEvent

event OnSliderAcceptST(float value)
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _key = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		TTT_ArousedNipsMainQuest.MaxValue[_key] = value
		SetSliderOptionValueST(TTT_ArousedNipsMainQuest.MaxValue[_key], "{2}", false, _state)
	elseif _stateName[0] == "MaleMorphMaxValueSliderST"
		TTT_ArousedNipsMainQuest.MaleMaxValue[_key] = value
		SetSliderOptionValueST(TTT_ArousedNipsMainQuest.MaleMaxValue[_key], "{2}", false, _state)
	endif
endEvent

event OnSelectST()
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _key = _stateName[1] as int

	if _stateName[0] == "DeleteMorphKeyTextST"
		SetTextOptionValueST("Working...")
		if ShowMessage("Are you sure you want to delete '" + TTT_ArousedNipsMainQuest.MorphNames[_key] + "'' morph?")
			JsonUtil.ClearPath("Aroused Nips/MorphList.json", ".female." + TTT_ArousedNipsMainQuest.MorphNames[_key])
			JsonUtil.Save("Aroused Nips/MorphList.json")

			TTT_ArousedNipsMainQuest.ReloadMorphList()
			ForcePageReset()
		Else
			SetTextOptionValueST("", false, _state)
		endif
	elseif _stateName[0] == "MaleDeleteMorphKeyTextST"
		SetTextOptionValueST("Working...")
		if ShowMessage("Are you sure you want to delete '" + TTT_ArousedNipsMainQuest.MaleMorphNames[_key] + "'' morph?")
			JsonUtil.ClearPath("Aroused Nips/MorphList.json", ".male." + TTT_ArousedNipsMainQuest.MaleMorphNames[_key])
			JsonUtil.Save("Aroused Nips/MorphList.json")

			TTT_ArousedNipsMainQuest.ReloadMorphList()
			ForcePageReset()
		Else
			SetTextOptionValueST("", false, _state)
		endif
	endif
endEvent

event OnDefaultST()
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _key = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		TTT_ArousedNipsMainQuest.MaxValue[_key] = TTT_ArousedNipsMainQuest.MaxDefault[_key]
		SetSliderOptionValueST(TTT_ArousedNipsMainQuest.MaxValue[_key], "{2}", false, _state)
	elseif _stateName[0] == "MaleMorphMaxValueSliderST"
		TTT_ArousedNipsMainQuest.MaleMaxValue[_key] = TTT_ArousedNipsMainQuest.MaleMaxDefault[_key]
		SetSliderOptionValueST(TTT_ArousedNipsMainQuest.MaleMaxValue[_key], "{2}", false, _state)
	endif
endEvent

event OnHighlightST()
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _key = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		SetInfoText(TTT_ArousedNipsMainQuest.MorphNames[_key] + " at 100 arousal.\nDefault: " + TTT_ArousedNipsMainQuest.MaxDefault[_key])
	elseif _stateName[0] == "MaleMorphMaxValueSliderST"
		SetInfoText(TTT_ArousedNipsMainQuest.MaleMorphNames[_key] + " at 100 arousal.\nDefault: " + TTT_ArousedNipsMainQuest.MaleMaxDefault[_key])
	elseif _stateName[0] == "DeleteMorphKeyTextST"
		SetInfoText("NOTE: Deleting morphs will not clear them from NPCs its already been applied to.\nIf you are using SLIF you can delete them manually in its MCM if need be.")
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
