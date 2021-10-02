ScriptName TTT_ArousedNipsAlias extends ReferenceAlias
{For event handling.}

TTT_ArousedNipsQuest Property TTT_ArousedNipsMainQuest Auto

Formlist Property TTT_ArousedNipsArrayCopyFl Auto

Int Property NIO_VERSION = 6 AutoReadOnly hidden
Int Property NIO_SCRIPT_VERSION = 6 AutoReadOnly hidden

String Property NIO_KEY = "TTT_ArousedNips.esp" AutoReadOnly hidden

Actor Property PlayerRef Auto

slaMainScr Property sla_Main Auto
slaFrameworkScr Property sla_Framework Auto
SexLabFramework Property SexLabQuestFramework Auto
TTT_ArousedNipsConfigMenu Property Menu Auto
TTT_ArousedNipsInterfaceFrostfall Property FrostfallInt Auto

Bool IsMmeInstalled
Bool IsFrostfallInstalled
Bool IsSlifInstalled = false

Float NipsTweakVersion
Float[] RollAvg

Function ShiftArrayLeft(Float[] ArraySelect, Int ArrayLength)
	Int i = 0
	While i < ArrayLength - 1
		ArraySelect[i] = ArraySelect[i+1]
		i += 1
	EndWhile
EndFunction

Float Function AddArray(Float[] ArraySelect, Int ArrayLength)
	Int i = 0
	Float Sum = 0.0
	While i < ArrayLength
		Sum += ArraySelect[i]
		i += 1
	EndWhile
	Return Sum
EndFunction

Event OnPlayerLoadGame()
	{Checking requirements every game load.}
	if TTT_ArousedNipsMainQuest.DebugMode
		debug.Notification("ArousedNips: checking for requirements")
		debug.Trace("TTT_ArousedNips: checking for requirements")
	EndIf
	
	
	;Check Requirements
	if !CheckNiOverride()
		;NiO check fail
		TTT_ArousedNipsMainQuest.isNioOk = false
		debug.Notification("ArousedNips: NiOverride Version check failed, aborting.")
		debug.Trace("TTT_ArousedNips: NiOverride Version check failed, aborting.")
		return
	Else
		TTT_ArousedNipsMainQuest.isNioOk = true
	EndIf
	
	if (sla_Main.slaConfig.GetVersion() < 26 || sla_Main.slaConfig.GetVersion() > 20110000)
		;Aroused version check fail
		TTT_ArousedNipsMainQuest.isSLArousedOk = false
		debug.Notification("ArousedNips: [Warning]: Unsupported Version of SLAroused Redux, aborting")
		debug.Trace("TTT_ArousedNips: [Warning]: Unsupported Version of SLAroused Redux, aborting")
		return
	Else
		TTT_ArousedNipsMainQuest.isSLArousedOk = true
	EndIf
	
	;success
	TTT_ArousedNipsMainQuest.ResetDefaults()
	
	RegisterForModevent("sla_UpdateComplete", "OnArousalComputed")
	
	RegisterForModEvent("StageStart", "OnStageStart")
	
	IF TTT_ArousedNipsMainQuest.DebugMode
		debug.Notification("ArousedNips: requirements check successful")
		debug.Trace("TTT_ArousedNips: requirements check successful")
	EndIf
	
	; MME
	IsMmeInstalled = (Game.GetModByName("MilkModNEW.esp") != 255)
	
	; Frostfall
	IsFrostfallInstalled = (Game.GetModByName("Frostfall.esp") != 255)
	
	; SLIF
	IsSlifInstalled = (Game.GetModByName("SexLab Inflation Framework.esp") != 255)
	
	If NipsTweakVersion < 1.1
		RollAvg = new Float[50]
		NipsTweakVersion = 1.1
	EndIf
	SendModEvent("TTT_ArousedNips_LoadGame")
EndEvent

Bool Function CheckNiOverride()
	Return SKSE.GetPluginVersion("NiOverride") >= NIO_VERSION && NiOverride.GetScriptVersion() >= NIO_SCRIPT_VERSION
EndFunction

Event OnArousalComputed(string eventName, string argString, float argNum, form sender)
	{Event thrown by Aroused}
	bool doDebug = TTT_ArousedNipsMainQuest.DebugMode
	If doDebug
		debug.Notification("ArousedNips: Arousal event")
		debug.Trace("TTT_ArousedNips: Arousal event")
	EndIf
	
	
	;player needs an extrawurst
	UpdateActor(PlayerRef, doDebug)
	
	if(argNum <= 0)
		If doDebug
			debug.Notification("ArousedNips: No aroused NPCs nearby, updating player only")
			debug.Trace("TTT_ArousedNips: No aroused NPCs nearby, updating player only")
		EndIf
		return
	endif
	
	;;modifying that nice Redux example code:
	;int myLockNum = Utility.randomInt(10, 32000)
	int myLockNum = 7 ; "That value is constrained from 0 to 7, in SLAX" - https://www.loverslab.com/topic/107720-monomans-mod-tweaks/?do=findComment&comment=3053379
	Actor [] myActors = sla_Main.getLoadedActors(myLockNum) 
	;This could be null if called at the wrong time
	;Debug.Trace("TTT: myActors: " + myActors)
	
	int t = 0
	while(myActors.Length == 0 && t < 5)
		If doDebug
			debug.Notification("Warning: ArousedNips could not access Aroused's actor array. Retrying.")
		EndIf
		debug.Trace("Warning: TTT_ArousedNips could not access Aroused's actor array. Retrying. t = "+t)
		Utility.Wait(1.0)
		myActors = sla_Main.getLoadedActors(myLockNum)
		t += 1
	endWhile
	
	Form [] theActors
	If myActors.Length > 0

		;Debug.Trace("TTT: Sucessfully got actors! - " + myActors)

;/		SLAX returns a variable sized array
		theActors = new Actor[20]
		int i = 0;
		;Copy the actors to a private array            
		while(i < 20)
			theActors[i] = myActors[i]
			i+= 1
		endwhile
/;
		
		TTT_ArousedNipsArrayCopyFl.Revert()
		i = 0
		While i < myActors.Length
			TTT_ArousedNipsArrayCopyFl.AddForm(myActors[i])
			i += 1
		EndWhile
		theActors = TTT_ArousedNipsArrayCopyFl.ToArray()
		
		
		;It is imparative to call unlock
		sla_Main.UnlockScan(myLockNum)
		
		;Now do whatever I want with those actors  
	Else
		If doDebug
			debug.Notification("Warning: ArousedNips gave up accessing Aroused's actor array.")
		EndIf
		debug.Trace("Warning: TTT_ArousedNips gave up accessing Aroused's actor array.")
		;debug.Messagebox("Warning: TTT_ArousedNips gave up accessing Aroused's actor array.")
		
		Debug.Trace("TTT: Failed to get actors this time around")
		return
	EndIf

	int i = 0          
	while i < theActors.Length
		if theActors[i] as Actor ;make sure there is an actor
			UpdateActor(theActors[i] as Actor, doDebug)
		EndIf
		i+= 1
	endwhile
	
	If doDebug
		debug.Notification("ArousedNips: Arousal event end")
		debug.Trace("TTT_ArousedNips: Arousal event end")
	EndIf
endEvent

Function UpdateActor(Actor who, bool doDebug=false, int modifier=0)
	{Set morphs of "who" according to their arousal, offset by "modifier".}

	If TTT_ArousedNipsMainQuest.IgnoreMales && (Who.GetLeveledActorBase().GetSex() == 0)
		If doDebug
			debug.Notification("ArousedNips: "+who.GetLeveledActorBase().GetName()+" is male, skipping")
			debug.Trace("TTT_ArousedNips: "+who.GetLeveledActorBase().GetName()+", is male, skipping")
		EndIF
		return
	EndIf
	
	;int Arousal = who.GetFactionRank(sla_Framework.slaArousal)
	Float Arousal = who.GetFactionRank(sla_Framework.slaArousal)
	
	If doDebug
		debug.Notification("ArousedNips: "+who.GetLeveledActorBase().GetName()+" has Arousal "+Arousal+"(+" + modifier +")")
		debug.Trace("TTT_ArousedNips: "+who.GetLeveledActorBase().GetName()+" has Arousal "+Arousal+"(+" + modifier +")")
	EndIF
	
	If Arousal < 0 && who != PlayerRef
		return
	EndIf
	
	
	Arousal = Arousal + modifier

	If Arousal > 100
		Arousal = 100
	ElseIf Arousal < 0
		Arousal = 0
	EndIf
	
	Float Multiplier = (Arousal / 100.0)
	If who == PlayerRef
		Int NumOfUpdatesRollAvg = Menu.RollAvgCount ; Number of updates to calculate the rolling average from
		float ColdValue = 0.0
		float MilkValue = 0.0
		If IsMmeInstalled
			Float MilkCount = StorageUtil.GetFloatValue(PlayerRef, "MME.MilkMaid.MilkCount")
			Float MilkMax = StorageUtil.GetFloatValue(PlayerRef, "MME.MilkMaid.MilkMaximum")
			If MilkMax > 0.0
				MilkValue = (MilkCount / MilkMax)
				If MilkValue > 1.0
					MilkValue = 1.0
				EndIf
			EndIf
		EndIf
		If IsFrostfallInstalled
			ColdValue = (FrostfallInt.GetFfExposure() / 100.0) ; Frostfalls max exposure is 120. Set nipples to get fully erect at 100 exposure instead. Can't admire your hard nipples if you're dead... (not that I recommend standing around admiring your nipples while you freeze to death)
			If ColdValue > 1.0
				ColdValue = 1.0
			EndIf
		EndIf
		If ColdValue > Multiplier
			Multiplier = ColdValue
		EndIf
		If MilkValue > Multiplier
			Multiplier = MilkValue
		EndIf
		
		;Debug.Notification("Arousal: " + (Arousal / 100.0) + ". ColdValue: " + ColdValue + ". MilkValue: " + MilkValue)
		Float NipCurrent = Multiplier
		ShiftArrayLeft(RollAvg, NumOfUpdatesRollAvg)
		RollAvg[NumOfUpdatesRollAvg - 1] = Multiplier
		Multiplier = AddArray(RollAvg, NumOfUpdatesRollAvg) / NumOfUpdatesRollAvg
		;Debug.Notification("Nip: Current: " + NipCurrent + ". Avg: " + Multiplier)
		
		If Multiplier > (Menu.CommentNipSize / 100.0)
			TTT_ArousedNipsMainQuest.SillyComments = true
		Else
			TTT_ArousedNipsMainQuest.SillyComments = false
		EndIf
	EndIf
	
	int j = 0
	while j<4
		float Value = TTT_ArousedNipsMainQuest.MaxValue[j] * Multiplier
		If IsSlifInstalled
			SetBodyMorph(who, TTT_ArousedNipsMainQuest.MorphNames[j], Value)
		Else
			NiOverride.SetBodyMorph(who, TTT_ArousedNipsMainQuest.MorphNames[j], NIO_KEY, Value)
		EndIf
		If doDebug
			debug.Notification("ArousedNips: setting "+TTT_ArousedNipsMainQuest.MorphNames[j]+" to "+Value)
			debug.Trace("TTT_ArousedNips: setting "+TTT_ArousedNipsMainQuest.MorphNames[j]+" to "+Value)
		EndIf
		j+=1
	EndWhile
	NiOverride.UpdateModelWeight(who)
	
EndFunction

Function SetBodyMorph(Actor kActor, String morphName, float value)
		SLIF_morph(kActor, morphName, value)
EndFunction

Function SLIF_morph(Actor kActor, String morphName, float value)
	int SLIF_event = ModEvent.Create("SLIF_morph")
	If (SLIF_event)
		ModEvent.PushForm(SLIF_event, kActor)
		ModEvent.PushString(SLIF_event, "Aroused Nips")
		ModEvent.PushString(SLIF_event, morphName)
		ModEvent.PushFloat(SLIF_event, value)
		ModEvent.PushString(SLIF_event, NIO_KEY)
		ModEvent.Send(SLIF_event)
	EndIf
EndFunction

;/
Function SLIF_UnRegisterActor(Actor akActor)
	int SLIF_event = ModEvent.Create("SLIF_unregisterActor")
	If (SLIF_event)
		ModEvent.PushForm(SLIF_event, akActor)
		ModEvent.PushString(SLIF_event, "Aroused Nips")
		ModEvent.Send(SLIF_event)
	EndIf
EndFunction
/;

Event OnStageStart(string eventName, string argString, float argNum, form sender)
	{Experimental.}
	
	Actor[] actorList = SexLabQuestFramework.HookActors(argString)
	
	If (actorList.length < 1)
		return
	EndIf
	
	Utility.Wait(1)
	;giving Aroused time to do its thing.
	
	int i = 0
	While i < actorList.length
		UpdateActor(actorList[i], TTT_ArousedNipsMainQuest.DebugMode, 50)
		i += 1
	EndWhile
	
EndEvent

Function BeginUpdates()
	RegisterForSingleUpdate(Menu.PlayerUpdateFreq)
EndFunction

Function StopUpdates()
	UnregisterForUpdate()
EndFunction

Event OnUpdate()
	UpdateActor(PlayerRef, doDebug = false)
	If Menu.PlayerUpdateFreq > 0
		RegisterForSingleUpdate(Menu.PlayerUpdateFreq)
	EndIf
EndEvent
