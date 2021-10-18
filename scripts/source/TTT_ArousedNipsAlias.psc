ScriptName TTT_ArousedNipsAlias extends ReferenceAlias
{For event handling.}

TTT_ArousedNipsQuest Property TTT_ArousedNipsMainQuest Auto

FormList Property TTT_ArousedNipsArrayCopyFl Auto

int Property NIO_VERSION = 6 AutoReadOnly hidden
int Property NIO_SCRIPT_VERSION = 6 AutoReadOnly hidden

string Property NIO_KEY = "TTT_ArousedNips.esp" AutoReadOnly hidden

Actor Property PlayerRef Auto

slaMainScr Property sla_Main Auto
slaFrameworkScr Property sla_Framework Auto
SexLabFramework Property SexLabQuestFramework Auto
TTT_ArousedNipsConfigMenu Property Menu Auto
TTT_ArousedNipsinterfaceFrostfall Property Frostfallint Auto

Bool IsMmeInstalled
Bool IsFrostfallInstalled
Bool property IsSlifInstalled = false auto
bool property isMMEInstalledProp
	bool function get()
		return IsMmeInstalled
	endFunction
endProperty

float NipsTweakVersion
float[] RollAvg

function ShiftArrayLeft(float[] ArraySelect, int ArrayLength)
	int i = 0
	while i < ArrayLength - 1
		ArraySelect[i] = ArraySelect[i+1]
		i += 1
	endWhile
endFunction

float function AddArray(float[] ArraySelect, int ArrayLength)
	int i = 0
	float Sum = 0.0
	while i < ArrayLength
		Sum += ArraySelect[i]
		i += 1
	endWhile
	Return Sum
endFunction

event OnPlayerLoadGame()
{Checking requirements every game load.}

	if TTT_ArousedNipsMainQuest.DebugMode
		Debug.Notification("ArousedNips: checking for requirements")
		Debug.Trace("TTT_ArousedNips: checking for requirements")
	endif

	; Check Requirements
	if !CheckNiOverride()
		; NiO check fail
		TTT_ArousedNipsMainQuest.isNioOk = false
		Debug.Notification("ArousedNips: NiOverride version check failed, aborting.")
		Debug.Trace("TTT_ArousedNips: NiOverride version check failed, aborting.")
		return
	else
		TTT_ArousedNipsMainQuest.isNioOk = true
	endif

	if (sla_Main.slaConfig.GetVersion() < 26 || sla_Main.slaConfig.GetVersion() > 20110000)
		; Aroused version check fail
		TTT_ArousedNipsMainQuest.isSLArousedOk = false
		Debug.Notification("ArousedNips: [Warning]: Unsupported version of SexLab Aroused, aborting")
		Debug.Trace("TTT_ArousedNips: [Warning]: Unsupported version of SexLab Aroused, aborting")
		return
	else
		TTT_ArousedNipsMainQuest.isSLArousedOk = true
	endif

	if TTT_ArousedNipsMainQuest.DebugMode
		Debug.Notification("ArousedNips: requirements check successful")
		Debug.Trace("TTT_ArousedNips: requirements check successful")
	endif

	; success
	;TTT_ArousedNipsMainQuest.ResetDefaults()

	RegisterForModEvent("sla_UpdateComplete", "OnArousalComputed")
	RegisterForModEvent("StageStart", "OnStageStart")

	; MME
	IsMmeInstalled = (Game.GetModByName("MilkModNEW.esp") != 255)

	; Frostfall
	IsFrostfallInstalled = (Game.GetModByName("Frostfall.esp") != 255)

	; SLif
	IsSlifInstalled = (Game.GetModByName("SexLab Inflation Framework.esp") != 255)

	if NipsTweakVersion < 1.1
		RollAvg = new float[50]
		NipsTweakVersion = 1.1
	endif
	SendModEvent("TTT_ArousedNips_LoadGame")
endEvent

Bool function CheckNiOverride()
	;Return SKSE.GetPluginVersion("NiOverride") >= NIO_VERSION && NiOverride.GetScriptVersion() >= NIO_SCRIPT_VERSION
	return NiOverride.GetScriptVersion() >= NIO_SCRIPT_VERSION
endFunction

event OnArousalComputed(string eventName, string argstring, float argNum, form sender)
{event thrown by Aroused}

	bool doDebug = TTT_ArousedNipsMainQuest.DebugMode
	if doDebug
		Debug.Notification("ArousedNips: Arousal event")
		Debug.Trace("TTT_ArousedNips: Arousal event")
	endif

	;player needs an extrawurst
	UpdateActor(PlayerRef, doDebug)

	if TTT_ArousedNipsMainQuest.IgnoreNPCs
		if doDebug
			Debug.Notification("ArousedNips: NPC processing disabled, updating player only")
			Debug.Trace("TTT_ArousedNips: NPC processing disabled, updating player only")
		endif
		return
	endif

	if(argNum <= 0)
		if doDebug
			Debug.Notification("ArousedNips: No aroused NPCs nearby, updating player only")
			Debug.Trace("TTT_ArousedNips: No aroused NPCs nearby, updating player only")
		endif
		return
	endif

	;;modifying that nice Redux example code:
	;int myLockNum = Utility.randomint(10, 32000)
	int myLockNum = 7 ; "That value is constrained from 0 to 7, in SLAX" - https://www.loverslab.com/topic/107720-monomans-mod-tweaks/?do=findComment&comment=3053379
	Actor[] myActors = sla_Main.getLoadedActors(myLockNum)
	;This could be null if called at the wrong time
	;Debug.Trace("TTT: myActors: " + myActors)

	int t = 0
	while (myActors.Length == 0 && t < 5)
		if doDebug
			Debug.Notification("Warning: ArousedNips could not access Aroused's actor array. Retrying.")
		endif
		Debug.Trace("Warning: TTT_ArousedNips could not access Aroused's actor array. Retrying. t = "+t)
		Utility.Wait(1.0)
		myActors = sla_Main.getLoadedActors(myLockNum)
		t += 1
	endWhile

	Form[] theActors
	if myActors.Length > 0
		TTT_ArousedNipsArrayCopyFl.Revert()
		i = 0
		while i < myActors.Length
			TTT_ArousedNipsArrayCopyFl.AddForm(myActors[i])
			i += 1
		endWhile
		theActors = TTT_ArousedNipsArrayCopyFl.ToArray()

		;It is imparative to call unlock
		sla_Main.UnlockScan(myLockNum)
	else
		if doDebug
			Debug.Notification("Warning: ArousedNips gave up accessing Aroused's actor array.")
		endif
		Debug.Trace("Warning: TTT_ArousedNips gave up accessing Aroused's actor array.")
		;Debug.Messagebox("Warning: TTT_ArousedNips gave up accessing Aroused's actor array.")

		Debug.Trace("TTT: Failed to get actors this time around")
		return
	endif

	int i = 0
	while i < theActors.Length
		if theActors[i] as Actor ;make sure there is an actor
			UpdateActor(theActors[i] as Actor, doDebug)
		endif
		i+= 1
	endWhile

	if doDebug
		Debug.Notification("ArousedNips: Arousal event end")
		Debug.Trace("TTT_ArousedNips: Arousal event end")
	endif
endEvent

function UpdateActor(Actor who, bool doDebug = false, int modifier = 0)
{Set morphs of "who" according to their arousal, offset by "modifier".}

	ActorBase _actorBase = who.GetLeveledActorBase()
	if TTT_ArousedNipsMainQuest.OnlyUniqueNPCs && !_actorBase.IsUnique()
		if doDebug
			string _actorName = _actorBase.GetName()
			Debug.Notification("ArousedNips: " + _actorName + " is not unique, skipping")
			Debug.Trace("TTT_ArousedNips: " + _actorName + ", is unique, skipping")
		endif
		return
	endif

	int _actorSex = _actorBase.GetSex()
	if _actorSex == 0
		if TTT_ArousedNipsMainQuest.IgnoreMales
			if doDebug
				string _actorName = _actorBase.GetName()
				Debug.Notification("ArousedNips: " + _actorName + " is male, skipping")
				Debug.Trace("TTT_ArousedNips: " + _actorName + ", is male, skipping")
			endif
			return
		elseif TTT_ArousedNipsMainQuest.MaleMorphNames.Length == 0
			if doDebug
				string _actorName = _actorBase.GetName()
				Debug.Notification("ArousedNips: " + _actorName + " is male and male morph list is empty, skipping")
				Debug.Trace("TTT_ArousedNips: " + _actorName + ", is male and male morph list is empty, skipping")
			endif
			return
		endif
	elseif _actorSex == 1 
		if TTT_ArousedNipsMainQuest.IgnoreFemales
			if doDebug
				string _actorName = _actorBase.GetName()
				Debug.Notification("ArousedNips: " + _actorName + " is female, skipping")
				Debug.Trace("TTT_ArousedNips: " + _actorName + ", is female, skipping")
			endif
			return
		elseif TTT_ArousedNipsMainQuest.MorphNames.Length == 0
			if doDebug
				string _actorName = _actorBase.GetName()
				Debug.Notification("ArousedNips: " + _actorName + " is female and female morph list is empty, skipping")
				Debug.Trace("TTT_ArousedNips: " + _actorName + ", is female and female morph list is empty, skipping")
			endif
			return
		endif
	endif

	;int Arousal = who.GetFactionRank(sla_Framework.slaArousal)
	float Arousal = who.GetFactionRank(sla_Framework.slaArousal)

	if doDebug
		string _actorName = _actorBase.GetName()
		Debug.Notification("ArousedNips: " + _actorName + " has Arousal " + Arousal + "(+" + modifier + ")")
		Debug.Trace("TTT_ArousedNips: " + _actorName + " has Arousal " + Arousal + "(+" + modifier + ")")
	endif

	if Arousal < 0 && who != PlayerRef
		return
	endif

	Arousal = Arousal + modifier
	if Arousal > 100
		Arousal = 100
	elseif Arousal < 0
		Arousal = 0
	endif

	float Multiplier = (Arousal / 100.0)
	if who == PlayerRef
		int NumOfUpdatesRollAvg = Menu.RollAvgCount ; Number of updates to calculate the rolling average from
		float ColdValue = 0.0
		float MilkValue = 0.0
		if IsMmeInstalled
			float MilkCount = StorageUtil.GetfloatValue(PlayerRef, "MME.MilkMaid.MilkCount")
			float MilkMax = StorageUtil.GetfloatValue(PlayerRef, "MME.MilkMaid.MilkMaximum")
			if MilkMax > 0.0
				MilkValue = (MilkCount / MilkMax)
				if MilkValue > 1.0
					MilkValue = 1.0
				endif
			endif
		endif
		if IsFrostfallInstalled
			ColdValue = (Frostfallint.GetFfExposure() / 100.0) ; Frostfalls max exposure is 120. Set nipples to get fully erect at 100 exposure instead. Can't admire your hard nipples if you're dead... (not that I recommend standing around admiring your nipples while you freeze to death)
			if ColdValue > 1.0
				ColdValue = 1.0
			endif
		endif
		if ColdValue > Multiplier
			Multiplier = ColdValue
		endif
		if MilkValue > Multiplier
			Multiplier = MilkValue
		endif

		;Debug.Notification("Arousal: " + (Arousal / 100.0) + ". ColdValue: " + ColdValue + ". MilkValue: " + MilkValue)
		float NipCurrent = Multiplier
		ShiftArrayLeft(RollAvg, NumOfUpdatesRollAvg)
		RollAvg[NumOfUpdatesRollAvg - 1] = Multiplier
		Multiplier = AddArray(RollAvg, NumOfUpdatesRollAvg) / NumOfUpdatesRollAvg
		;Debug.Notification("Nip: Current: " + NipCurrent + ". Avg: " + Multiplier)

		if Multiplier > (Menu.CommentNipSize / 100.0)
			TTT_ArousedNipsMainQuest.SillyComments = true
		else
			TTT_ArousedNipsMainQuest.SillyComments = false
		endif
	endif

	int j = 0
	string[] _morphs
	float[] _values

	if _actorSex == 0
		StorageUtil.FormListAdd(none, "TTT_ArousedNips_MaleActors", who, false)
		_morphs = TTT_ArousedNipsMainQuest.MaleMorphNames
		_values = TTT_ArousedNipsMainQuest.MaleMaxValue
	else
		StorageUtil.FormListAdd(none, "TTT_ArousedNips_FemaleActors", who, false)
		_morphs = TTT_ArousedNipsMainQuest.MorphNames
		_values = TTT_ArousedNipsMainQuest.MaxValue
	endif

	while j < _morphs.Length
		float Value = _values[j] * Multiplier
		if IsSlifInstalled
			SetBodyMorph(who, _morphs[j], Value)
		else
			NiOverride.SetBodyMorph(who, _morphs[j], NIO_KEY, Value)
			NiOverride.UpdateModelWeight(who)
		endif
		if doDebug
			Debug.Notification("ArousedNips: setting " + _morphs[j] + " to " + Value)
			Debug.Trace("TTT_ArousedNips: setting " + _morphs[j] + " to " + Value)
		endif
		j += 1
	endWhile
endFunction

function SetBodyMorph(Actor kActor, string morphName, float value)
	SLif_morph(kActor, morphName, value)
endFunction

function SLif_morph(Actor kActor, string morphName, float value)
	int SLif_event = ModEvent.Create("SLif_morph")
	if (SLif_event)
		ModEvent.PushForm(SLif_event, kActor)
		ModEvent.PushString(SLif_event, "Aroused Nips")
		ModEvent.PushString(SLif_event, morphName)
		ModEvent.PushFloat(SLif_event, value)
		ModEvent.PushString(SLif_event, NIO_KEY)
		ModEvent.Send(SLif_event)
	endif
endFunction

;/
function SLif_UnRegisterActor(Actor akActor)
	int SLif_event = ModEvent.Create("SLif_unregisterActor")
	if (SLif_event)
		ModEvent.PushForm(SLif_event, akActor)
		ModEvent.PushString(SLif_event, "Aroused Nips")
		ModEvent.Send(SLif_event)
	endif
endFunction
/;

event OnStageStart(string eventName, string argstring, float argNum, form sender)
{Experimental.}

	Actor[] actorList = SexLabQuestFramework.HookActors(argstring)

	if (actorList.length < 1)
		return
	endif

	Utility.Wait(1)
	;giving Aroused time to do its thing.

	int i = 0
	while i < actorList.length
		if !TTT_ArousedNipsMainQuest.IgnoreNPCs || actorList[i] == PlayerRef
			UpdateActor(actorList[i], TTT_ArousedNipsMainQuest.DebugMode, 50)
		endif
		i += 1
	endWhile
endEvent

function BeginUpdates()
	RegisterForSingleUpdate(Menu.PlayerUpdateFreq)
endFunction

function StopUpdates()
	UnregisterForUpdate()
endFunction

event OnUpdate()
	UpdateActor(PlayerRef, doDebug = false)
	if Menu.PlayerUpdateFreq > 0
		RegisterForSingleUpdate(Menu.PlayerUpdateFreq)
	endif
endEvent
