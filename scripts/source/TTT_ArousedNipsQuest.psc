ScriptName TTT_ArousedNipsQuest extends Quest Conditional
{Hosts all state.}

TTT_ArousedNipsAlias Property TTT_ArousedNipsPlayerAlias Auto

Bool Property SillyComments = False Auto Hidden Conditional

bool Property isNioOk = false Auto Hidden
bool Property isSLArousedOk = false Auto Hidden

bool Property DebugMode = false Auto Hidden
bool Property IgnoreMales = true Auto Hidden
bool Property IgnoreNPCs = false Auto Hidden
bool Property Isinitialized = false Auto Hidden

string[] Property MorphNames Auto Hidden
float[] Property MaxValue Auto Hidden
;float[] Property MaxDefault Auto Hidden

Event OnInit()
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
EndEvent

Function ResetDefaults()
{Keeps defaults up-to-date}

;/ 	MaxDefault = new float[4]
	MaxDefault[0] = DefaultSize
	MaxDefault[1] = DefaultLength
	MaxDefault[2] = DefaultCone
	MaxDefault[3] = DefaultArea /;
EndFunction

function ReloadMorphList()
	; Reload json file
	JsonUtil.Unload("Aroused Nips/MorphList.json")

	; load defaults
	;MaxDefault = JsonUtil.FloatListToArray("Aroused Nips/MorphList.json", "DefaultValues")

	; cache new values
	;float[] tempvalues = JsonUtil.FloatListToArray("Aroused Nips/MorphList.json", "DefaultValues")
	float[] tempvalues = Utility.CreateFloatArray(JsonUtil.StringListCount("Aroused Nips/MorphList.json", "MorphNames"))

	int i = 0
	int j = -1

	while i < MorphNames.Length
		j = JsonUtil.StringListFind("Aroused Nips/MorphList.json", "MorphNames", MorphNames[i])
		if j == -1 ; morph wasnt found in the list
			; clear applied morphs
			if TTT_ArousedNipsPlayerAlias.IsSlifInstalled
				;TTT_ArousedNipsPlayerAlias.SetBodyMorph(TTT_ArousedNipsPlayerAlias.PlayerRef, MorphNames[i], 0.0)
				int SLIF_event = ModEvent.Create("SLIF_unregisterMorph")
				If (SLIF_event)
					ModEvent.PushForm(SLIF_event, TTT_ArousedNipsPlayerAlias.PlayerRef)
					ModEvent.PushString(SLIF_event, "Aroused Nips")
					ModEvent.PushString(SLIF_event, MorphNames[i])
					ModEvent.Send(SLIF_event)
				EndIf
			else
				; NiOverride.SetBodyMorph(TTT_ArousedNipsPlayerAlias.PlayerRef, MorphNames[i], TTT_ArousedNipsPlayerAlias.NIO_KEY, 0.0)
				NiOverride.ClearBodyMorph(TTT_ArousedNipsPlayerAlias.PlayerRef, MorphNames[i], TTT_ArousedNipsPlayerAlias.NIO_KEY)
			endif
		else
			; overwrite with existing values (if names match)
			tempvalues[j] = MaxValue[i]
		endif
		i += 1
	endWhile
	MaxValue = tempvalues

	; load morph names
	MorphNames = JsonUtil.StringListToArray("Aroused Nips/MorphList.json", "MorphNames")
	NiOverride.UpdateModelWeight(TTT_ArousedNipsPlayerAlias.PlayerRef)
endfunction
