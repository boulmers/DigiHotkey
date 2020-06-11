
;==============================================================================
class DgApp extends DgObject
{
    __New()
    {
        _Logger.BEGIN( A_ThisFunc )

        this.PID            := DllCall("GetCurrentProcessId")
        this.name           := "DigiHotkey"
        this.regKey         := "HKEY_CURRENT_USER\SOFTWARE\" . this.name

        configFile          := PathCombine( A_WorkingDir, "..\config\config.json" )
        this.config         := new DgConfig( configFile )

        this.audio          := new DgAudio(this.PID)
        this.powerMan       := new DgPowerMan()
        this.keyboard       := new DgKeyboard()
        this.taskMan        := new DgTaskMan( checkPeriodSec := 1 )
        this.ui             := new DgUI()

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    init()
    {
        _Logger.BEGIN( A_ThisFunc )

        ;t1 := _PerfCounter.check()
        this.config.load()      ; load config
        ;t2 := _PerfCounter.check()
        this.audio.init()       ; contains apply config

        ;t3 := _PerfCounter.check()

        this.keyboard.init() ; contains apply config
        this.ui.init()      ; contains apply config

        ;t5 := _PerfCounter.check()

        ;_Logger.TRACE( A_ThisFunc, "t1", t1, "t2", t2, "t3", t3, "t4", t4, "t5", t5, "t6", t6 )

        _Logger.END( A_ThisFunc )
    }

    ;------------------------------------------------------------------------------
    quit()
    {
        _Logger.BEGIN( A_ThisFunc )

        this.config.save()
        this.ui.showNotification( this.name,  this.ui.lang.msgQuitApp )

        Sleep, 1000

        _Logger.END( A_ThisFunc )

        return 0 ; 0 allow exit , 1 prevent exit
    }
    ;------------------------------------------------------------------------------
    insKeySetEnabled( state_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        this.keyboard.insKeySetEnabled( state_ )

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    switchCapsLockState()
    {
        _Logger.BEGIN( A_ThisFunc )

        isCapsLocked := this.keyboard.getCapsLockState()


        if( this.keyboard.capsLockBehaviour == enumLockBehaviour.Free ) {
            this.ui.notifyCapsLockState( isCapsLocked )
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    switchNumLockState()
    {
        _Logger.BEGIN( A_ThisFunc)

        isNumLocked := this.keyboard.getNumLockState() ; TRACE

        if( this.keyboard.numLockBehaviour == enumLockBehaviour.Free) {

            this.ui.notifyNumLockState( isNumLocked )
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    addTask( task_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        this.taskMan.addTask( task_ )

        this.ui.addTask( task_ )

        _Logger.END( A_ThisFunc)
    }
    ;--------------------------------------------------------s----------------------
    removeTask( task_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        this.taskMan.removeTask( task_ ) ; was task_ := this.taskMan.removeTask( task_ )

        this.ui.removeTask( task_ )

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------------
    createInsomniaTaskFromDialog( state_ )
    {
         ;name_,  message_,  periodSec_, durationSec_,  periodicEnabled_
         _Logger.BEGIN(  A_ThisFunc )

        periodSec       := this.config.insomniaPeriodSec
        durationSec     := state_.durationHour*60*60 + state_.durationMin*60

        repeatCount     := ( durationSec > 0 ) ? ( durationSec // periodSec ) - 1 : 0
        repeatCount     := ( repeatCount >= 0 ) ? repeatCount : 0
        
        startTime       := A_Now
        startTime       += periodSec, Seconds

        name            := state_.name
        callback        := this.preventSystemSleep.bind( this )
        
        task            := new DgTask( name , callback, startTime, periodSec, repeatCount )

        task.type       := enumTaskType.Insomnia
        task.isPausable := true

        _Logger.END( A_ThisFunc )

        return task
    }
    ;------------------------------------------------------------------------------
    preventSystemSleep()
    {
        MouseMove, 1, 1, 0, R  ; simulate a mouse move
        MouseMove, -1, -1, 0, R ; return to original position

        if( _App.config.beepOnInsomnia )
            SoundBeep, 1000, 10

    
    }
    ;------------------------------------------------------------------------------
    createReminderTaskFromDialog( state_ ) ; simplified facrory
    {
         ;name_,  message_,  periodSec_, durationSec_,  periodicEnabled_
         _Logger.BEGIN(  A_ThisFunc )

        periodSec       := state_.periodicEnabled ? state_.periodMin*60 : 60                                                   ; assumig a period of 1 hour in case of hourly reminder
        durationSec     := state_.durationHour*60*60 + state_.durationMin*60

        if( state_.periodicEnabled ) {

            repeatCount := ( durationSec > 0) ? ( durationSec // periodSec ) - 1 : 0
            repeatCount := ( repeatCount >= 0 ) ? repeatCount : 0
            isPausable   := true

            startTime     := A_Now
            startTime     += periodSec, Seconds

        } else {
            repeatCount := 24 ;hourlyEnabled
            isPausable   := false

            year  := A_YYYY
            month := A_MM
            day   := A_DD
            hour  := A_Hour
            min   := A_Min ; todo Set to "00" ( after test with every minute reminder )
            sec   := "00"

            startTime := year . month . day . hour . min . sec ; hourly Rounded Time
        }


        name            := state_.name
        callback        := this.notifyReminder.bind( this ) 
        task            := new DgTask( name , callback , startTime, periodSec, repeatCount )
        task.type       := enumTaskType.Reminder
        task.message    := state_.message
        task.isPausable := isPausable
    

        _Logger.END( A_ThisFunc )

        return task
    }
    ;------------------------------------------------------------------------------
    createTimerTaskFromDialog( state_ )
    {
        _Logger.BEGIN(  A_ThisFunc )

        delaySec  := state_.delayHour*60*60 +  state_.delayMin*60

        YYYYMMDD := SubStr( state_.timeDate, 1, 8) ; get date, timeDate has AHK format  YYYYMMDDHH24MISS
        HH24MI   := SubStr( state_.timeTime, 9, 4) ; get time without seconds
        SS       := "00"                          ; set seconds to 0, as the timeTime get not set by user seconds from  DateTime UI control

        dueTime := YYYYMMDD . HH24MI . SS     ; join results to form AHK formatted time

        if( state_.delayEnabled ) {
            dueTime         := GetTimeFromNow( delaySec )
            isPausable       := true

        } else {  ; timeEnabled
           
           ;dueTime       := dueTime ( do nothing )
            isPausable       := false
        }

        name            := state_.name
        callback        := this.notifyTimer.bind( this )
        periodSec       := this.config.timerSnoozePeriodSec
        repeatCount     := this.config.timerMaxSnoozeCount

        task            := new DgTask( name, callback, dueTime, periodSec, repeatCount )
        task.type       := enumTaskType.Timer
        task.isPausable := isPausable
        task.message    := state_.message

        _Logger.END( A_ThisFunc )

        return task
    }
    ;------------------------------------------------------------------------------
    showTaskMan()
    {
        _Logger.BEGIN(  A_ThisFunc )
        
        this.ui.dlgTaskMan.show( redraw := true, animate := true)

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    setActiveSoundProfile( profileName_ )
    {
        _Logger.BEGIN(  A_ThisFunc )

        this.audio.setActiveSoundProfile( profileName_ )
        this.ui.setActiveSoundProfile(    profileName_ )

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    changeMyAppVolume( deltaVol_ )
    {
        _Logger.BEGIN(  A_ThisFunc )

        this.changeAppVolume( this.PID, deltaVol_,  this.name )

        _Logger.END( A_ThisFunc )

    }
    ;------------------------------------------------------------------------------
    changeActiveAppVolume( deltaVol_ )
    {
        _Logger.BEGIN(  A_ThisFunc )

        WinGet, activeAppPID,  PID, A ; Active Window Process ID
        WinGet, activeAppName, ProcessName, A ; Active Window Process Name

        _Logger.TRACE(A_ThisFunc, "activeAppPID", activeAppPID, "activeAppName", activeAppName)

        this.changeAppVolume( activeAppPID, deltaVol_,  activeAppName )

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    changeAppVolume( appPID_, deltaVol_ , appName_ := "")
    {
        _Logger.BEGIN(  A_ThisFunc )

        ;epsilon     := 0.01
        currVol     := this.audio.changeAppVolume( appPID_, deltaVol_ )

        ;if( currVol > epsilon ) { ; to show mute symbole if currVol is already in min (deprecated)
          
            this.ui.showVolumeTip( currVol, enumColor.AppVolTip, appName_)
        ;} else { ; show mute symbole 
        ;    this.ui.showInfoTip( enumUnicode.Mute ,  enumColor.LedWarn )
        ;}

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    changeMasterVolume( deltaVol_ )  {  ; deltaVol_: number  
        _Logger.BEGIN(  A_ThisFunc )

        ; currMasterVol   := this.audio.changeMasterVolume( deltaVol_ )

        ;if( currMasterVol >  epsilon) {
            this.ui.showVolumeTip( currMasterVol, enumColor.MasterVolTip, "Master" )
        ;} else {
        ;    this.ui.showInfoTip( enumUnicode.Mute ,  enumColor.LedWarn)
        ;}

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    ;------------------------------------------------------------------------------
    setActiveWindowAlwaysOnTopState( state_ ) ; state_: bool
    {
        _Logger.BEGIN(  A_ThisFunc )

        hWnd := WinActive( "A" )

        FlashWindowEx(hWnd, dwFlags := 1, uCount := 1, dwTimeout := 0) 

        if( state_ ) {
            Winset, Alwaysontop, On, A
            this.audio.sounds.SwitchOn.play()
        } else {
            Winset, Alwaysontop, Off, A
            this.audio.sounds.SwitchOff.play()
        }



        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    switchCapsLockAlwaysOn()
    {
        _Logger.BEGIN( A_ThisFunc )

        if( this.keyboard.capsLockBehaviour == enumLockBehaviour.AlwaysOn ) {

            this.keyboard.setCapsLockBehaviour(  enumLockBehaviour.Free )
            this.ui.setCapsLockBehaviour(        enumLockBehaviour.Free )
            this.audio.sounds.SwitchOff.play()

        } else {
            this.keyboard.setCapsLockBehaviour(  enumLockBehaviour.AlwaysOn )
            this.ui.setCapsLockBehaviour(        enumLockBehaviour.AlwaysOn )
            this.audio.sounds.SwitchOn.play()
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    switchCapsLockAlwaysOff()
    {
        _Logger.BEGIN( A_ThisFunc )

        if( this.keyboard.capsLockBehaviour == enumLockBehaviour.AlwaysOff ) {

            this.keyboard.setCapsLockBehaviour( enumLockBehaviour.Free )
            this.ui.setCapsLockBehaviour(      enumLockBehaviour.Free )
            this.audio.sounds.SwitchOff.play()

        } else {
            this.keyboard.setCapsLockBehaviour( enumLockBehaviour.AlwaysOff )
            this.ui.setCapsLockBehaviour(       enumLockBehaviour.AlwaysOff )
            this.audio.sounds.SwitchOff.play()
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    switchCapsLockAlert()
    {
        _Logger.BEGIN( A_ThisFunc )

        if( this.ui.capsLockAlertEnabled ) {
            this.ui.setCapsLockAlert( false )
            this.audio.sounds.SwitchOff.play()
        } else {
            this.ui.setCapsLockAlert( true )
            this.audio.sounds.SwitchOn.play()
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    switchNumLockAlert()
    {
        _Logger.BEGIN( A_ThisFunc )

        if( this.ui.numLockAlertEnabled ) {
            this.ui.setNumLockAlert( false )
            this.audio.sounds.SwitchOff.play()
        } else {
            this.ui.setNumLockAlert( true )
            this.audio.sounds.SwitchOn.play()
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    switchNumLockAlwaysOn()
    {
        _Logger.BEGIN( A_ThisFunc )

        if( this.keyboard.numLockBehaviour == enumLockBehaviour.AlwaysOn )  {
            this.keyboard.setNumLockBehaviour( enumLockBehaviour.Free )
            this.ui.setNumLockBehaviour(      enumLockBehaviour.Free )
            this.audio.sounds.SwitchOff.play()
        } else {
            this.keyboard.setNumLockBehaviour( enumLockBehaviour.AlwaysOn )
            this.ui.setNumLockBehaviour(      enumLockBehaviour.AlwaysOn )
            this.audio.sounds.SwitchOn.play()
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    switchNumLockAlwaysOff()
    {
        _Logger.BEGIN( A_ThisFunc )

        if( this.keyboard.numLockBehaviour == enumLockBehaviour.AlwaysOff) {
            this.keyboard.setNumLockBehaviour( enumLockBehaviour.Free )
            this.ui.setNumLockBehaviour(      enumLockBehaviour.Free )
            this.audio.sounds.SwitchOff.play()
        } else {
            this.keyboard.setNumLockBehaviour( enumLockBehaviour.AlwaysOff )
            this.ui.setNumLockBehaviour(      enumLockBehaviour.AlwaysOff  )
            this.audio.sounds.SwitchOff.play()
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    notifyReminder( task_ )
    {
        _Logger.BEGIN( A_ThisFunc )


        if( task_.type !=  enumTaskType.Reminder ) {
            _Logger.ERROR( A_ThisFunc, "something went wrong, task_.type !=  enumTaskType.Reminder")
        }

        title   := this.name
        message :=  task_.message

        this.ui.showNotification( title, message )

        if( task_.isLastExecution) {
            Loop, 3 {
                this.audio.sounds.Reminder.play()
                Sleep, 2000
            }
        }
        else {
            this.audio.sounds.Reminder.play()
        }
        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    notifyTimer( task_ )
    {

        if( task_.type !=  enumTaskType.Timer ) {
            _Logger.ERROR( A_ThisFunc, "something went wrong, task_.type !=  enumTaskType.Timer")
        }

        this.ui.showTimerNotification( task_ )

        this.audio.sounds.Timer.play()
    }
    ;------------------------------------------------------------------------------
    dismissTimerNotification( task_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        
        if( task_.type !=  enumTaskType.Timer ) {
            _Logger.ERROR( A_ThisFunc, "something went wrong: task_.type !=  enumTaskType.Timer", "task_", task_)
        }

        task_.uiElements.timerNotification.destroy( animate := false)

        Sleep 100

        this.audio.sounds.Timer.stop()

        this.removeTask( task_ )

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    addNewReminder()
    {
        reminderTask := this.taskMan.getReminderTask()

        if ( reminderTask ) {
            this.ui.showAlertMessage( this.name , "Only one reminder is allowed!")
        } else {
            
            this.ui.dlgReminder.show()
        }
    }
    ;------------------------------------------------------------------------------
    addNewTimer()    
    {
        this.ui.dlgTimer.show()     ; todo : set position to botom right
    }
    ;------------------------------------------------------------------------------
    addNewInsomnia()  
    {
        insomniaTask := this.taskMan.getInsomniaTask()

        if ( insomniaTask ) {
            this.ui.showAlertMessage( this.name , "Only one insomnia task is allowed!")
        } else {

            this.ui.dlgInsomnia.show()
        }
    }
    ;------------------------------------------------------------------------------
    showAboutBox() 
    { 
        this.ui.dlgAbout.show()
    }
    ;------------------------------------------------------------------------------
    showSettings() ; actually shows settings folder ! 
    { 
        configPath := PathCombine( A_WorkingDir, "..\config")
        Run, explore %configPath%
    }
    ;------------------------------------------------------------------------------
    showHelp() 
    { 
        docPath := PathCombine( A_WorkingDir, "..\doc")
        Run, explore %docPath%
    }
    ;------------------------------------------------------------------------------
    removeTimerConfirm( timerName_ )   
    {
        timerTask := this.taskMan.getTaskByName( timerName_ )

        if( ! timerTask ) {
            this.ui.showAlertMessage( this.name, this.ui.lang.msgTimerNotFound )
            return
        }

        this.removeTaskConfirm( task_ )
    }
    ;------------------------------------------------------------------------------
   removeTaskConfirm( task_ )   
   {
        message :=   this.ui.lang.qstTaskStop . " " . task_.name . " ?"

        if( this.ui.yesNoQuestion( this.name, message )) {
            this.removeTask( task_ ) ; todo : supply reminder param or refactor
        }
    }
    ;------------------------------------------------------------------------------
    pauseResumeTask( task_ )   
    {
        _Logger.TRACE( A_ThisFunc, "task_", task_ )

        if( task_.isPaused ) {
            task_.resume()
        } else {
            task_.pause()
        }

        this.ui.updateTaskProgress( task_ )
    }
    ;------------------------------------------------------------------------------
    setActivePowerPlan( planName_ )  
    {
        currPowerPlanName := this.powerMan.getActivePlanName()

        if( currPowerPlanName != planName_ ) {
            ret := this.powerMan.setActivePlan( planName_ )
            if( ret ) {
                this.ui.setActivePowerPlan( planName_ )
                this.audio.sounds.Start.play()
            }
        }
    }
    ;------------------------------------------------------------------------------
    setActiveLanguage( languageName_ ) 
    {
        this.ui.setActiveLanguage( languageName_ )
        this.ui.updateActiveLanguageMenu( languageName_ , showInfoMessage := true) 
    }
    ;------------------------------------------------------------------------------
    toggleHotkeyActionGroup( groupName_ ) ; enable/disable hotkeys action groups as defined in hotkeys config file
    {  ;  todo : refactor to put ui code in the ui class
                                  
        _Logger.BEGIN( A_ThisFunc )

        actionGroup     := this.keyboard.actionGroups[ groupName_ ] ; debug

        newState    := this.keyboard.toggleHotkeyActionGroup( groupName_ )

        this.ui.updateActionGroupState( groupName_, newState) ; just toggle ui menu check enabled without good implemenation and testing would lead to problems

        _Logger.END( A_ThisFunc )
    }

}


