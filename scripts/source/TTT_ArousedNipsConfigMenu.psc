ScriptName TTT_ArousedNipsConfigMenu extends SKI_ConfigBase
{the MCM, what else}

TTT_ArousedNipsInterfaceFrostfall Property FrostfallInt Auto
TTT_ArousedNipsQuest Property TTT_ArousedNipsMainQuest Auto
Spell Property TTT_ArousedNipsDebugSpell Auto
Quest Property TTT_ArousedNipsComments Auto

float property range = 3.0 AutoReadOnly hidden

TTT_ArousedNipsAlias Property NipsAlias Auto

Int SillyCommentsOIDT
Int CommentNipSizeOID_S
Int PlayerUpdateFreqOID_S
Int RollAvgCountOID_S
Int ExportSettingsOID_T
Int ImportSettingsOID_T
Int FrostfallIntOIDT

Float Property PlayerUpdateFreq = 10.0 Auto Hidden
Int Property RollAvgCount = 4 Auto Hidden
Float Property CommentNipSize = 70.0 Auto Hidden
Bool NpcComments = true

int hasReqFlag

int oidDebugMode
int oidIgnoreMales

int[] oidMaxValue

string version

bool toggleDebugSpell = false

int function GetVersion()
	;format = (M)MmmPP
	;12345 => 1.23.45
	return 10102
endFunction

Event OnVersionUpdate(Int ver)
	int Major = ver/10000
	int Minor = (ver%10000)/100
	int Patch = ver%100
	version = Major+"."+Minor+"."+Patch
	debug.Notification("ArousedNips: Updating to "+version)
	debug.Trace("TTT_ArousedNips: Updating to "+version)
	TTT_ArousedNipsMainQuest.stop()
	Utility.Wait(1)
	TTT_ArousedNipsMainQuest.start()
EndEvent


Event OnConfigInit()
	debug.Notification("ArousedNips: Registering MCM. This could take a while.")
	debug.Trace("TTT_ArousedNips: Registering MCM. This could take a while.")
	
	While !TTT_ArousedNipsMainQuest.Isinitialized
		Utility.WaitMenuMode(2.0)
	EndWhile
	LoadSettings()
	NipsAlias.BeginUpdates()
EndEvent

event OnConfigRegister()
	debug.Notification("ArousedNips: MCM registered!")
	debug.Trace("TTT_ArousedNips: MCM registered!")
	
	Pages = new string[1]
	pages[0] = "General"
	
	oidMaxValue = new int[4]
	
	TTT_ArousedNipsMainQuest.start()
endEvent


event OnConfigOpen()
	Pages = new string[1]
	pages[0] = "General"
	
	oidMaxValue = new int[4]
	
	bool isOk = TTT_ArousedNipsMainQuest.isNioOk && TTT_ArousedNipsMainQuest.isSLArousedOk
	
	hasReqFlag = OPTION_FLAG_DISABLED * (!isOk) as int
	
endEvent

Event OnConfigClose()
	if toggleDebugSpell
		if TTT_ArousedNipsMainQuest.DebugMode
			Game.GetPlayer().addSpell(TTT_ArousedNipsDebugSpell)
		else
			Game.GetPlayer().removeSpell(TTT_ArousedNipsDebugSpell)
		endIf
		toggleDebugSpell = false
	endIf
EndEvent

event OnPageReset(string page)
	
	;;NOTE TO SELF;;;;;;;;;;;;
	;oid = AddSliderOption("desc",val,"{0}",flag)
	;oid = AddToggleOption("desc",val,flag)
	;oid = AddTextOption("desc","val",flag)
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	If page == pages[0]
		;Config
		SetCursorFillMode(TOP_TO_BOTTOM)
		
		;Left side
		SetCursorPosition(0)
		
		AddHeaderOption("ArousedNips "+version)
		AddEmptyOption()
		AddTextOption("Note: NippleSize is an inverted slider;","",hasReqFlag)
		AddTextOption("smaller number means bigger result.","",hasReqFlag)
		AddHeaderOption("Morphs at 100")
		
		int i = 0
		while i < 4
			oidMaxValue[i] = AddSliderOption(TTT_ArousedNipsMainQuest.MorphNames[i],TTT_ArousedNipsMainQuest.MaxValue[i],"{2}",hasReqFlag)
			i += 1
		EndWhile
		AddEmptyOption()
		;TODO: Anything else?

		AddHeaderOption("Interfaces")
		FrostfallIntOIDT = AddToggleOption("Frostfall Interface", FrostfallInt.GetIsInterfaceActive())
		
		;Right side
		SetCursorPosition(1)
		AddHeaderOption("Version Checks")
		AddToggleOption("NiOverride (Required)", TTT_ArousedNipsMainQuest.isNiOok)
		AddToggleOption("SLAroused Redux (Required)", TTT_ArousedNipsMainQuest.isSLArousedok)
		AddEmptyOption()
		
		AddHeaderOption("")
		oidIgnoreMales = AddToggleOption("Ignore Males", TTT_ArousedNipsMainQuest.IgnoreMales)
		AddEmptyOption()
		oidDebugMode = AddToggleOption("Debug mode", TTT_ArousedNipsMainQuest.DebugMode)
		AddEmptyOption()
		SillyCommentsOIDT = AddToggleOption("Nipple Comments", NpcComments)
		CommentNipSizeOID_S = AddSliderOption("Nipple Size For Comments: ", CommentNipSize, "{0}%")
		PlayerUpdateFreqOID_S = AddSliderOption("Player Update Frequency: ", PlayerUpdateFreq, "{0} seconds")
		RollAvgCountOID_S = AddSliderOption("# Rolling Average Points: ", RollAvgCount, "{0} Updates")
		ExportSettingsOID_T = AddTextOption("Export Settings ", "")
		ImportSettingsOID_T = AddTextOption("Import Settings", "")
	Endif
endEvent

event OnOptionSelect(int option)
	if option == oidDebugMode
		TTT_ArousedNipsMainQuest.DebugMode = !TTT_ArousedNipsMainQuest.DebugMode
		SetToggleOptionValue(option,TTT_ArousedNipsMainQuest.DebugMode)
		toggleDebugSpell = true
		return
	elseif option == oidIgnoreMales
		TTT_ArousedNipsMainQuest.IgnoreMales = !TTT_ArousedNipsMainQuest.IgnoreMales
		SetToggleOptionValue(option,TTT_ArousedNipsMainQuest.IgnoreMales)
		return
	
	ElseIf Option == SillyCommentsOIDT
		NpcComments = !NpcComments
		SetToggleOptionValue(SillyCommentsOIDT, NpcComments)
		If NpcComments
			TTT_ArousedNipsComments.Start()
		Else
			TTT_ArousedNipsComments.Stop()
		EndIf
	ElseIf option == ExportSettingsOID_T
		SetTextOptionValue(ExportSettingsOID_T, "Exporting Settings ", false)
		If ShowMessage("Overwrite settings file with your current settings?")
			SaveSettings()
			SetTextOptionValue(ExportSettingsOID_T, "Done! ", false)
		Else
			SetTextOptionValue(ExportSettingsOID_T, "", false)
		Endif
	ElseIf option == ImportSettingsOID_T
		SetTextOptionValue(ImportSettingsOID_T, "Importing Settings ", false)
		If ShowMessage("Overwrite your current settings with the settings saved to file?")
			LoadSettings()
			SetTextOptionValue(ImportSettingsOID_T, "Done! ", false)
		Else
			SetTextOptionValue(ImportSettingsOID_T, "", false)
		Endif
	endIf
endEvent


event OnOptionDefault(int option)
	if option == oidDebugMode
		TTT_ArousedNipsMainQuest.DebugMode = false
		SetToggleOptionValue(option,false)
		toggleDebugSpell = true
		return
	Elseif option == oidIgnoreMales
		TTT_ArousedNipsMainQuest.IgnoreMales = true
		SetToggleOptionValue(option,true)
		return
	Elseif option == SillyCommentsOIDT
		NpcComments = true
		SetToggleOptionValue(SillyCommentsOIDT, NpcComments)
		If NpcComments
			TTT_ArousedNipsComments.Start()
		Else
			TTT_ArousedNipsComments.Stop()
		EndIf
	Else
		int i = 0
		while i < 4
			If option == oidMaxValue[i]
				TTT_ArousedNipsMainQuest.MaxValue[i] = TTT_ArousedNipsMainQuest.MaxDefault[i]
				SetSliderOptionValue(option, TTT_ArousedNipsMainQuest.MaxValue[i], "{2}")
				return
			Endif
			i += 1
		endWhile
	endIf
endEvent

Event OnOptionSliderOpen(Int option)
	If option == oidMaxValue[0] || option == oidMaxValue[1] || option == oidMaxValue[2] || option == oidMaxValue[3]
		SetSliderDialogRange(-range, range)
		SetSliderDialogInterval(0.01)
		
		int i = 0
		while i < 4
			If option == oidMaxValue[i]
				SetSliderDialogStartValue(TTT_ArousedNipsMainQuest.MaxValue[i])
				SetSliderDialogDefaultValue(TTT_ArousedNipsMainQuest.MaxDefault[i])
				return
			Endif
			i += 1
		endWhile
		
	ElseIf Option == CommentNipSizeOID_S
		SetSliderDialogStartValue(CommentNipSize)
		SetSliderDialogDefaultValue(70.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(1.0)		
	ElseIf Option == PlayerUpdateFreqOID_S
		SetSliderDialogStartValue(PlayerUpdateFreq)
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(0.0, 300.0)
		SetSliderDialogInterval(1.0)
	ElseIf Option == RollAvgCountOID_S
		SetSliderDialogStartValue(RollAvgCount)
		SetSliderDialogDefaultValue(4.0)
		SetSliderDialogRange(1.0, 50.0)
		SetSliderDialogInterval(1.0)
	EndIf
EndEvent

Event OnOptionSliderAccept(Int option, Float value)
	If option == oidMaxValue[0] || option == oidMaxValue[1] || option == oidMaxValue[2] || option == oidMaxValue[3]
		int i = 0
		while i < 4
			If option == oidMaxValue[i]
				TTT_ArousedNipsMainQuest.MaxValue[i] = value
				SetSliderOptionValue(option, TTT_ArousedNipsMainQuest.MaxValue[i], "{2}")
				return
			Endif
			i += 1
		endWhile
	
	ElseIf Option == CommentNipSizeOID_S
		CommentNipSize = value
		SetSliderOptionValue(CommentNipSizeOID_S, CommentNipSize)
		ForcePageReset()
	ElseIf Option == PlayerUpdateFreqOID_S
		PlayerUpdateFreq = value
		SetSliderOptionValue(PlayerUpdateFreqOID_S, PlayerUpdateFreq)
		ForcePageReset()
		If PlayerUpdateFreq > 0
			NipsAlias.BeginUpdates()
		Else
			NipsAlias.StopUpdates()
		EndIf
	ElseIf Option == RollAvgCountOID_S
		RollAvgCount = value as Int 
		SetSliderOptionValue(RollAvgCountOID_S, RollAvgCount)
		ForcePageReset()
	EndIf
EndEvent

Event OnOptionHighlight(Int option)
	If option == oidDebugMode
		SetInfoText("Will print debug info to screen and log.")
		
	ElseIf option == ExportSettingsOID_T
		SetInfoText("Export your settings to file")
		
	ElseIf option == ImportSettingsOID_T
		SetInfoText("Import your settings from file")
		
	ElseIf Option == PlayerUpdateFreqOID_S
		SetInfoText("How often to update the player character\nSetting to 0 will disable MME/Frostfall updates. Updates from arousal will still occur")
	ElseIf Option == RollAvgCountOID_S
		SetInfoText("How many rolling average updates to base nipple size on\nNipple size for the player is an average of the last X amount of updates\nYour update frequency and how smooth you want nipple size to change will determine what you set this to\nToo low and nipple size will 'pop' to size. Too high and nipple size will be slow to react\nChanging this setting may make nipple size take some time to 'level off' initially")
	ElseIf Option == SillyCommentsOIDT
		SetInfoText("Enable/Disable Npc nipple size comments\nComments will only occur when you are naked/wearing clothes\nIf you have suggestions for comments feel free to post them in the forum")
	ElseIf Option == CommentNipSizeOID_S
		SetInfoText("What percentage of maximum size your nipples must be for Npcs to begin commenting on it")
	ElseIf Option == FrostfallIntOIDT
		SetInfoText("Whether or not the Frostfall interface is working. You might need to save and reload for it to become active.")
		
		;TODO: ElseIfs
	Else
		int i = 0
		while i < 4
			If option == oidMaxValue[i]
				SetInfoText("Value of Morph " + TTT_ArousedNipsMainQuest.MorphNames[i] + " at arousal 100")
				return
			Endif
			i += 1
		endWhile
		
		;Default:
		SetInfoText("ArousedNips "+version+" by TTT.")
	EndIf
EndEvent

Function SaveSettings()
	
	; Floats
	JsonUtil.SetFloatValue("Aroused Nips/Settings.json", "MaxValueZero", TTT_ArousedNipsMainQuest.MaxValue[0])
	JsonUtil.SetFloatValue("Aroused Nips/Settings.json", "MaxValueOne", TTT_ArousedNipsMainQuest.MaxValue[1])
	JsonUtil.SetFloatValue("Aroused Nips/Settings.json", "MaxValueTwo", TTT_ArousedNipsMainQuest.MaxValue[2])
	JsonUtil.SetFloatValue("Aroused Nips/Settings.json", "MaxValueThree", TTT_ArousedNipsMainQuest.MaxValue[3])
	JsonUtil.SetFloatValue("Aroused Nips/Settings.json", "CommentNipSize", CommentNipSize)
	JsonUtil.SetFloatValue("Aroused Nips/Settings.json", "PlayerUpdateFreq", PlayerUpdateFreq)

	; Bools
	JsonUtil.SetIntValue("Aroused Nips/Settings.json", "IgnoreMales", TTT_ArousedNipsMainQuest.IgnoreMales as Int)
	JsonUtil.SetIntValue("Aroused Nips/Settings.json", "DebugMode", TTT_ArousedNipsMainQuest.DebugMode as Int)
	JsonUtil.SetIntValue("Aroused Nips/Settings.json", "NpcComments", NpcComments as Int)
	
	; Ints
	JsonUtil.SetIntValue("Aroused Nips/Settings.json", "RollAvgCount", RollAvgCount)
	
	JsonUtil.Save("Aroused Nips/Settings.json")
	
EndFunction

Function LoadSettings()

	; Floats
	TTT_ArousedNipsMainQuest.MaxValue[0] = JsonUtil.GetFloatValue("Aroused Nips/Settings.json", "MaxValueZero", Missing = -0.75)
	TTT_ArousedNipsMainQuest.MaxValue[1] = JsonUtil.GetFloatValue("Aroused Nips/Settings.json", "MaxValueOne", Missing = 1.0)
	TTT_ArousedNipsMainQuest.MaxValue[2] = JsonUtil.GetFloatValue("Aroused Nips/Settings.json", "MaxValueTwo", Missing = 1.5)
	TTT_ArousedNipsMainQuest.MaxValue[3] = JsonUtil.GetFloatValue("Aroused Nips/Settings.json", "MaxValueThree", Missing = 0.0)
	CommentNipSize = JsonUtil.GetFloatValue("Aroused Nips/Settings.json", "CommentNipSize", Missing = 70.0)
	PlayerUpdateFreq = JsonUtil.GetFloatValue("Aroused Nips/Settings.json", "PlayerUpdateFreq", Missing = 10.0)
	
	; Bools
	TTT_ArousedNipsMainQuest.IgnoreMales = JsonUtil.GetIntValue("Aroused Nips/Settings.json", "IgnoreMales", Missing = 0)
	TTT_ArousedNipsMainQuest.DebugMode = JsonUtil.GetIntValue("Aroused Nips/Settings.json", "DebugMode", Missing = 0)
	NpcComments = JsonUtil.GetIntValue("Aroused Nips/Settings.json", "NpcComments", Missing = 1)
	
	; Ints
	RollAvgCount = JsonUtil.GetIntValue("Aroused Nips/Settings.json", "RollAvgCount", Missing = 4)
	
	ForcePageReset()
	
EndFunction
