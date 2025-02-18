SetTimer AntiIdleUnknown, 58000, 0

;;;;;;;;;;;;;;;;;;;;;
;Sends F22 to anti idle
;;;;;;;;;;;;;;;;;;;;

SendF22()
{
send "{F22}"
}

AntiIdleUnknown()
{
	if (A_TimeIdle > 58000)
	{
		SendF22()
	}
}



VarBotName := InputBox("Bot Name", "")
 

 
global VarBotName
SetKeyDelay 75, 25

MCSendKey(VarCommand) {
		send "{esc}"
		sleep 100
		send "/"
		sleep 100
		send "{esc}"
		sleep 100
		
		send "/"
		sleep 100
		send "msg " VarBotName.value " {!}stop"
		sleep 100
		send "{enter}"
		sleep 100

  

		send "/"
		sleep 100
		send "msg " VarBotName.value " {!}" VarCommand
		sleep 100
		send "{enter}"
		sleep 100

}


MCSendKeyNonBot(VarCommand) {
		send "{esc}"
		sleep 100
		send "/"
		sleep 100
		send "{esc}"
		sleep 100

		send "/"
		sleep 100
		send VarCommand
		sleep 100
		send "{enter}"
		sleep 100
}


f1::{
		VarCommand := InputBox("Command", "")
		global VarCommand
		MCSendKey(VarCommand)
	}

f2::{

	MCSendKey('!stop' )
	}
 
Strings := [
   ; Array[1] contains the caption used in the Switch/Case section, Array[2] contains the text displayed in the Menu
   ["MenuTitle" ,    "Quick Access Menu" ],
   ["Command1"  ,    "FollowPlayer"],
   ["Command2",    "Search For Block"],
   ["Command3"  ,    "searchForEntity"],
   ["Command4"   ,    "collectBlocks"],
   ["Command5"   ,    "Spectate / Follow Bot"],
   ["Command6"   ,    "goToCoordinates"],

]

; Create the menu ----------------------------------------------------------------------------------

ONQAMenu := Menu()
ONQAMenu.SetColor("FFFFFF", true)

For V In Strings
   ONQAMenu.Add(V[2], MenuHandler) ; Using the Display names listed in the menu
   
;ONQAMenu.ToggleEnable( "* * * OneNote Quick Access Menu * * *") ; Title in display not enabled here 
;so it doesn't foul up the indexing for the Switch/case.  Using array reference picks up the correct string title.

ONQAMenu.ToggleEnable(Strings[1][2]) 


; Ctrl+Shift+M: Show the menu ----------------------------------------------------------------------

^+M::ONQAMenu.Show()

; Menu handlers ------------------------------------------------------------------------------------

MenuHandler(ItemName, ItemPos, ThisMenu) {
   ; The menu handler uses the selected string, but sets up the Switch/Case section 
   ; with the caption string based on the ItemPos index and assigns it to variable res 
   
   res := Strings[ItemPos][1]  ; Note the Caption is used in the Switch/Case for brevity in defining the Case references
   
   ToolTip(res . "`n`nhas been selected to open")
   SetTimer(() => ToolTip(), -2000)  
     
   Switch res
   {
    case "Command1": 
        {
			MCSendKey('followPlayer("desk509",4)')
	}

    case "Command2":
		VarBlock := InputBox("searchForBlock", "")
		global VarBlock
		MCSendKey('searchForBlock("' VarBlock.value '",32)' )
			
	case "Command3":
		VarBlock := InputBox("searchForEntity", "")
		global VarBlock
		MCSendKey('searchForEntity("' VarBlock.value '",32)' )
		
	case "Command4":
		VarBlock := InputBox("collectBlocks", "")
		global VarBlock
		MCSendKey('collectBlocks("' VarBlock.value '",999)' )
	case "Command5":
		MCSendKeyNonBot("gamemode spectator desk509")
		MCSendKeyNonBot('tp desk509 ' VarBotName.value )
		MCSendKeyNonBot('gamerule doDaylightCycle false' )
		MCSendKeyNonBot('time set 6000' )
	case "Command6":
		VarBlock := InputBox("x,y,z", "")
		global VarBlock
		MCSendKey('goToCoordinates("' VarBlock.value '",1)' )

    default: 
    }
   
  
}
