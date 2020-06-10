;==============================================================================
; mnu : tray menu
; ntf : try notification
; msg : message
; qst : question

; NOTA: this data structure contain at the same time the active language items and language list (items included)
; 
class DgLang extends DgObject
{

    __New()
    {
        this.languages		  		:= {}
    

        ; in case the configuartion file is lost...
        this.mnuCapsLock     		:= "CapsLock"
        this.mnuDisable      		:= "Disable"
        this.mnuEnable       		:= "Enable"
        this.mnuHotkeys       		:= "HotKeys"
        this.mnuAlwaysOn      		:= "Always On"
        this.mnuAlwaysOff     		:= "Always Off"
        this.mnuAlert         		:= "Alert"
        this.mnuReminder     		:= "Reminder"
        this.mnuNumLock      		:= "NumLock"
        this.mnuSound        		:= "Sound"
        this.mnuLang 				:= "Language"
        this.mnuExit 				:= "Quit"
        this.mnuInsomnia			:= "Insomnia"
        this.mnuLanguage            := "Language"
        this.mnuTools               := "Tools"
        this.mnuSettings            := "Settings!"
        this.mnuHelp                := "Quick guide"
        this.mnuAbout               := "About"

        this.mnuPower        		:= "Power plan"
        this.mnuDashboard			:= "Dashboard"
        this.mnuTaskMan 			:= "Task manager"
        this.mnuKeyboard            := "Keyboard"
        this.mnuInsert				:= "Insert"

        this.lnkDismiss          	:= "Dismiss"
        this.lnkClose 				:=  "Close"
        this.lnkNewTimer 			:= "New Timer"
        this.lnkNewReminder 		:= "New Reminder"
        this.lnkNewInsomnia			:= "New Insomnia"

        this.msgTimer 				:= "Timer"
        this.msgReminder 			:= "Reminder"

        this.msgPowerChanged 		:= "Power plan switched to : "

        this.msgTimerNameExists  	:= "Timer name already exists !"
        this.msgTimerNameInvalid 	:= "Invalid timer name !"
        this.msgTimerNotFound	   	:= "Timer not found!"

        this.msgTimerStartPrefix 	:= "Timer"
        this.msgTimerStartSuffix 	:= "started."

        this.msgTimerDeletePrefix 	:= "Timer"
        this.msgTimerDeleteSuffix 	:= "deleted !"

        this.msgTimeExpired			:= "Time expired !"

        this.msgReminderStartPrefix := "Reminder"
        this.msgReminderStartSuffix := "started."

        this.msgReminderDeletePrefix := "Timer"
        this.msgReminderDeleteSuffix := "deleted !"

        this.msgInsomniaStart		:= "Insomnia task started",
        this.msgInsomniaStop		:= "Insomnia task stopped",

        this.msgOneInsomniaTask	     := "Only one insomnia task is possible"
        this.msgLanguageChange		 := "Changing display language needs restart to take effect"

        this.msgQuitApp				:= "See you!"

        this.qstTaskStop   		       := "Stop "

        this.dlgTimer 					:= "Timer"
        this.dlgAbout                   := "About"
        this.dlgReminder 				:= "Reminder"
        this.dlgInsomnia				:= "Insomnia"

        this.dlgTime					:= "Time"
        this.dlgInfos					:= "Infos"

        this.dlgDelay					:= "Delay"
        this.dlgOnTime					:= "On time"
        this.dlgHour					:= "hour"
        this.dlgMinute					:= "min"
        this.dlgName					:= "Name"
        this.dlgMessage 				:= "Message"
        this.dlgStart 					:= "Start"
        this.dlgCancel 					:= "Cancel"

        this.dlgPeriodic				:= "Periodic"
        this.dlgHourly 					:= "Houly"
        this.dlgEvery 		    		:= "Every"
        this.dlgDuration 				:= "Duration"

        this.dlgTaskMan  				:= "Task manager"
        this.dlgAlwaysOn				:= "Always On"
        this.dlgAlwaysOff 				:= "Always Off"
        this.dlgOn 						:= "On"
        this.dlgOff 					:= "Off"

        this.dlgCapsLock 				:= "CapsLock"
        this.dlgNumLock   				:= "NumLock"
    
    }
    ;------------------------------------------------------------------------------
    loadFromJson( jsonFile_ )
    {
        _Logger.BEGIN( A_ThisFunc ,  "jsonFile_", jsonFile_)

        FileRead, jsonContent, % jsonFile_

        this.languages   := JSON.Load( jsonContent )

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    setLanguage( langName_ )
    {
        if( this.languages.HasKey( langName_ )) {
            
            language := this.languages[langName_]
            ObjectCopy( dest := this , source := language ) ; copy the child language object to the root object for easy access(?)

        } else {
            _Logger.ERROR( A_ThisFunc, "language not found!")
        }
    }

}