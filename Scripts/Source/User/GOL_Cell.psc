Scriptname GOL_Cell extends ObjectReference

Bool Property CurrentState = True Auto
Bool NextState = False

ISP_Script ISPSelf

GOL_Cell[] Neighbors

Event OnInit()
	ISPSelf = (Self as ObjectReference) as ISP_Script
	Neighbors = new GOL_Cell[0]
EndEvent

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	ISPSelf.Register(Self)
	DisplayState()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akReference)
	ISPSelf.Unregister(Self)
EndEvent

Event ISP_Script.OnSnapped(ISP_Script akSender, Var[] akArgs)
	GOL_Cell C = akArgs[1] as GOL_Cell
	If(Neighbors.Find(C) == -1)
		Neighbors.Add(C)
		Debug.Trace("We snapped!")
	EndIf
EndEvent

Event ISP_Script.OnUnsnapped(ISP_Script akSender, Var[] akArgs)
	Neighbors.Remove(Neighbors.Find(akArgs[1] as GOL_Cell))
	Debug.Trace("We Unsnapped!")
EndEvent

Event OnPowerOff()
	DisplayState()
	int LivingNeighbors
	
	int i
	While(i < Neighbors.Length)
		If(Neighbors[i].CurrentState)
			LivingNeighbors += 1
		EndIf
		i += 1
	EndWhile
	
	If(CurrentState)
		;Any live cell with fewer than two live neighbours dies, as if caused by under-population.
		If(LivingNeighbors < 2)
			NextState = False
			
		;Any live cell with two or three live neighbours lives on to the next generation.
		ElseIf(LivingNeighbors == 2 || LivingNeighbors == 3)
			NextState = True
			
		;Any live cell with more than three live neighbours dies, as if by over-population.
		ElseIf(LivingNeighbors > 3)
			NextState = False
		EndIf
	Else
		;Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
		If(LivingNeighbors == 3)
			NextState = True
		EndIf
	EndIf

EndEvent

Event OnPowerOn(ObjectReference akPowerGenerator)
	DisplayState()
EndEvent

Event OnActivate(ObjectReference akActionRef)
	If(IsPowered())
		NextState = !CurrentState
		DisplayState()
	EndIf
EndEvent

Function DisplayState()
	If(!Is3DLoaded() || (CurrentState == NextState))
		Return
	EndIf
	
	; doing this here is a little ugly
	CurrentState = NextState
	
    If(CurrentState == True)
		PlayAnimation("WhiteBright")
	Else
		PlayAnimation("RedDim")
	EndIf
EndFunction