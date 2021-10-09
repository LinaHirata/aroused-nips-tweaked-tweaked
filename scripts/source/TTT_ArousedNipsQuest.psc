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
float[] Property MaxDefault Auto Hidden

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
	if !JsonUtil.IsGood("Aroused Nips/MorphList.json")
		Debug.MessageBox("Aroused Nips: Couldnt load MophList.json.\n\n" + JsonUtil.GetErrors("Aroused Nips/MorphList.json") + "\nPlease check its formatting and data structure and reload the file using a button in MCM menu.\nFormat and structure referece can be found in the example file (MorphListExample.json)")
		return
	endif

	; cache new values
	string[] tempnames = JsonUtil.PathMembers("Aroused Nips/MorphList.json", ".")
	float[] tempvalues = Utility.CreateFloatArray(tempnames.Length)
	MaxDefault = Utility.CreateFloatArray(tempnames.Length)

	int i = 0
	float tempvalue = 0.0
	while i < tempnames.Length
		tempvalue = JsonUtil.GetPathFloatValue("Aroused Nips/MorphList.json", "." + tempnames[i], 0.0)
		tempvalues[i] = tempvalue
		MaxDefault[i] = tempvalue
		i += 1
	endWhile

	; clear old morphs and add new morphs keeping our existing data
	i = 0
	int j = -1
	while i < MorphNames.Length
		j = tempnames.Find(MorphNames[i])
		if j < 0 ; morph wasnt found in the list
			; clear applied morphs
			if TTT_ArousedNipsPlayerAlias.IsSlifInstalled
				int SLIF_event = ModEvent.Create("SLIF_unregisterMorph")
				If (SLIF_event)
					ModEvent.PushForm(SLIF_event, TTT_ArousedNipsPlayerAlias.PlayerRef)
					ModEvent.PushString(SLIF_event, "Aroused Nips")
					ModEvent.PushString(SLIF_event, MorphNames[i])
					ModEvent.Send(SLIF_event)
				EndIf
			else
				NiOverride.ClearBodyMorph(TTT_ArousedNipsPlayerAlias.PlayerRef, MorphNames[i], TTT_ArousedNipsPlayerAlias.NIO_KEY)
			endif
		else
			; overwrite with existing values (if names match)
			tempvalues[j] = MaxValue[i]
		endif
		i += 1
	endWhile

	; set actual values to be used
	MorphNames = tempnames
	MaxValue = tempvalues
	
	; update player mophs to reflect changes (in case morphs were removed)
	NiOverride.UpdateModelWeight(TTT_ArousedNipsPlayerAlias.PlayerRef)
endfunction
