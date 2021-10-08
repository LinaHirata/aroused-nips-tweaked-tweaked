Scriptname TTT_ArousedNipsInterfaceFrostfall extends Quest

Event OnInit()
	RegisterForModEvent("TTT_ArousedNips_LoadGame", "OnTTT_ArousedNips_LoadGame")
EndEvent

Event OnTTT_ArousedNips_LoadGame(string eventName, string strArg, float numArg, Form sender)
	PlayerLoadsGame()
EndEvent

Function PlayerLoadsGame()
	If Game.GetModByName("Frostfall.esp") != 255
		If GetState() != "Installed"
			GoToState("Installed")
		EndIf

	Else
		If GetState() != ""
			GoToState("")
		EndIf
	EndIf
EndFunction

Bool Function GetIsInterfaceActive()
	;If GetState() == "Installed"
	;	Return true
	;EndIf
	;Return false
	return GetState() == "Installed"
EndFunction

; Installed =======================================

State Installed
	Float Function GetFfExposure()
		Return TTT_ArousedNipsIntFrost.GetFfExposure()
	EndFunction
EndState

; Not Installed ====================================
Float Function GetFfExposure()
	Return 0.0
EndFunction

Event OnEndState()
	Utility.Wait(5.0) ; Wait before entering active state to help avoid making function calls to scripts that may not have initialized yet.

EndEvent
