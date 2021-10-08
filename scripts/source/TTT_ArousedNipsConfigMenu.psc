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
	return 10203
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
	Pages = new string[2]
	pages[0] = "Preferences"
	pages[1] = "Morphs"

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
	if page == "Preferences"
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		; Left side
		SetCursorPosition(0)
		AddHeaderOption("")
		AddToggleOptionST("SillyCommentsToggleST", "Nipple Comments", NpcComments)
		AddSliderOptionST("CommentNipSizeSliderST", "Nipple Size For Comments: ", CommentNipSize, "{0}%")
		AddEmptyOption()

		AddToggleOptionST("IgnoreMalesToggleST", "Ignore Males", TTT_ArousedNipsMainQuest.IgnoreMales)
		AddToggleOptionST("IgnoreNPCsToggleST", "Ignore NPCs", TTT_ArousedNipsMainQuest.IgnoreNPCs)
		AddEmptyOption()

		AddSliderOptionST("PlayerUpdateFreqSliderST", "Player Update Frequency: ", PlayerUpdateFreq, "{0} seconds")
		AddSliderOptionST("RollAvgCountSliderST", "# Rolling Average Points: ", RollAvgCount, "{0} Updates")
		AddEmptyOption()

		AddTextOptionST("ExportSettingsTextST", "Export Settings ", "")
		AddTextOptionST("ImportSettingsTextST", "Import Settings", "")

		; Right side
		SetCursorPosition(1)
		AddHeaderOption("Dependencies")
		AddToggleOption("NiOverride (Required)", TTT_ArousedNipsMainQuest.isNiOok)
		AddToggleOption("SLAroused Redux (Required)", TTT_ArousedNipsMainQuest.isSLArousedok)
		AddToggleOption("SL Inflation Framework", NipsAlias.IsSlifInstalled)
		AddToggleOption("Milk Mod Economy", NipsAlias.isMMEInstalledProp)
		AddEmptyOption()

		AddHeaderOption("Interfaces")
		AddToggleOption("Frostfall interface", Frostfallint.GetIsinterfaceActive())
		AddEmptyOption()
		
		AddHeaderOption("")
		AddToggleOptionST("DebugModeToggleST", "Debug mode", TTT_ArousedNipsMainQuest.DebugMode)
	elseif page == "Morphs"
		AddInputOptionST("AddMoprphKeyInputST", "Add Morh Key", "")
		AddTextOptionST("UpdateMorphsTextST", "Reload Morph List", "")
		AddHeaderOption("Morph value at 100 arousal")
		AddHeaderOption("")

		int i = 0
		while i < TTT_ArousedNipsMainQuest.MorphNames.Length
			AddSliderOptionST("MorphMaxValueSliderST_" + i, TTT_ArousedNipsMainQuest.MorphNames[i], TTT_ArousedNipsMainQuest.MaxValue[i], "{2}", hasReqFlag)
			AddTextOptionST("DeleteMorphKeyTextST_" + i, "Delete key: " + TTT_ArousedNipsMainQuest.MorphNames[i], "")
			i += 1
		endWhile

		;AddHeaderOption("")
		;AddHeaderOption("")
	endif
endEvent



; ------------------------------------------------------------------------------------
; -------------------------------------- STATES --------------------------------------
; ------------------------------------------------------------------------------------
state UpdateMorphsTextST
	event OnSelectST()
		SetTextOptionValueST("Working...")

		TTT_ArousedNipsMainQuest.ReloadMorphList()
		ForcePageReset()

		SetTextOptionValueST("DONE")
	endEvent

	event OnHighlightST()
		SetInfoText("Reload Morph list from the json file")
	endEvent
endState

state AddMoprphKeyInputST
	event OnInputAcceptST(string value)
		JsonUtil.StringListAdd("Aroused Nips/MorphList.json", "MorphNames", value, false)
		;JsonUtil.FloatListAdd("Aroused Nips/MorphList.json", "DefaultValues", 0.0, false)
		JsonUtil.Save("Aroused Nips/MorphList.json")

		TTT_ArousedNipsMainQuest.ReloadMorphList()
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("ArousedNips " + version + " by TTT.")
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
		SetInfoText("Do not process NPCs.")
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
		SetInfoText("ArousedNips " + version + " by TTT.")
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
		SetInfoText("Will print debug info to screen and log.")
	endEvent
endState

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
		SetSliderDialogDefaultValue(0.0)
		;SetSliderDialogDefaultValue(TTT_ArousedNipsMainQuest.MaxDefault[_key])
	endif
endEvent

event OnSliderAcceptST(float value)
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _key = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		TTT_ArousedNipsMainQuest.MaxValue[_key] = value
		SetSliderOptionValueST(TTT_ArousedNipsMainQuest.MaxValue[_key], "{2}", false, _state)
	endif
endEvent

event OnSelectST()
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _key = _stateName[1] as int

	if _stateName[0] == "DeleteMorphKeyTextST"
		SetTextOptionValueST("Working...")
		if ShowMessage("Are you use you want to delete " + TTT_ArousedNipsMainQuest.MorphNames[_key] + " key?")
			JsonUtil.StringListRemoveAt("Aroused Nips/MorphList.json", "MorphNames", _key)
			;JsonUtil.FloatListRemoveAt("Aroused Nips/MorphList.json", "DefaultValues", _key)
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
		TTT_ArousedNipsMainQuest.MaxValue[_key] = 0.0
		;TTT_ArousedNipsMainQuest.MaxValue[_key] = TTT_ArousedNipsMainQuest.MaxDefault[_key]
		SetSliderOptionValueST(TTT_ArousedNipsMainQuest.MaxValue[_key], "{2}", false, _state)
	endif
endEvent

event OnHighlightST()
	string _state = GetState()
    string[] _stateName = StringUtil.Split(_state, "_")
    int _key = _stateName[1] as int

	if _stateName[0] == "MorphMaxValueSliderST"
		SetInfoText("Value of Morph " + TTT_ArousedNipsMainQuest.MorphNames[_key] + " at arousal 100")
	;elseif _stateName[0] == "DeleteMorphKeyTextST"
	;	SetInfoText("Delete " + TTT_ArousedNipsMainQuest.MorphNames[_key] + " key")
	else
		SetInfoText("ArousedNips " + version + " by TTT.")
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
	TTT_ArousedNipsMainQuest.DebugMode = JsonUtil.GetintValue("Aroused Nips/Settings.json", "DebugMode", Missing = 0)
	NpcComments = JsonUtil.GetintValue("Aroused Nips/Settings.json", "NpcComments", Missing = 1)

	; ints
	RollAvgCount = JsonUtil.GetintValue("Aroused Nips/Settings.json", "RollAvgCount", Missing = 4)

	ForcePageReset()
endFunction
