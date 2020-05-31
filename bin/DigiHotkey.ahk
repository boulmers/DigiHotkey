;AutoHotKey    : v1.1.29.01    https://autohotkey.com/
;Description   : Keyboard hotkeys and utilities
;Author        : boulmers@gmail.com
;Version       : 0.0.1

;#Warn   ; Enable warnings.

#SingleInstance Ignore
#InstallKeybdHook ;Fforces keyboard hook installation;
#KeyHistory 0  ; disable key histoy to optimize time and space
#MenuMaskKey vkFF
#NoEnv

SetBatchLines -1    ; never micro-sleep for performance

;==============================================================================
#include %A_ScriptDir%\..\lib\json.ahk
#Include %A_ScriptDir%\..\lib\volume.ahk
#Include %A_ScriptDir%\..\lib\VA.ahk
#include %A_ScriptDir%\..\lib\RHotKey.ahk


#include %A_ScriptDir%\..\src\DgInsomniaDialog.ahk
#include %A_ScriptDir%\..\src\DgTimerDialog.ahk
#include %A_ScriptDir%\..\src\DgReminderDialog.ahk
#include %A_ScriptDir%\..\src\DgTaskManDialog.ahk


#include %A_ScriptDir%\..\src\DgObject.ahk
#include %A_ScriptDir%\..\src\DgLogger.ahk
#include %A_ScriptDir%\..\src\DgPerfCounter.ahk
#include %A_ScriptDir%\..\src\DgApp.ahk

#Include %A_ScriptDir%\..\src\DgPersistent.ahk
#Include %A_ScriptDir%\..\src\WinApi.ahk
#include %A_ScriptDir%\..\src\DgConfig.ahk

#include %A_ScriptDir%\..\src\Tools.ahk
#include %A_ScriptDir%\..\src\DgEnum.ahk
#include %A_ScriptDir%\..\src\DgSysTimer.ahk
#include %A_ScriptDir%\..\src\DgLang.ahk
#Include %A_ScriptDir%\..\src\DgInfoTip.ahk
#include %A_ScriptDir%\..\src\DgProgressTip.ahk
#include %A_ScriptDir%\..\src\DgNotification.ahk

#include %A_ScriptDir%\..\src\EventsUI.ahk

#Include %A_ScriptDir%\..\src\EventsHotkeys.ahk
#include %A_ScriptDir%\..\src\DgMenu.ahk
#include %A_ScriptDir%\..\src\DgUI.ahk
#Include %A_ScriptDir%\..\src\DgSound.ahk
#include %A_ScriptDir%\..\src\DgAudio.ahk
#include %A_ScriptDir%\..\src\DgTask.ahk
#include %A_ScriptDir%\..\src\DgPowerMan.ahk
#include %A_ScriptDir%\..\src\DgTaskMan.ahk
#include %A_ScriptDir%\..\src\DgAction.ahk
#include %A_ScriptDir%\..\src\DgKeyboard.ahk

;==============================================================================
; global variables are prefixed with _ sign ie _App
; function parameters are supposed to be suffixed with _ sign ie name_
; out variable (by ref) are prefixed with the $ ie $outFile

;==============================================================================
subMain:

   ; OnMessage( enumWinMsg.WM_INPUTLANGCHANGE,  "OnKeyboardLayoutChange")

    SetWorkingDir % A_ScriptDir

    ListLines Off                                                                                                       ; disable ListLines which is equivalent to selecting the "View->Lines most recently executed" => peformance optimization after debug
   ; Process, Priority, , H
   
   global _appDataFolder := A_AppData . "\DigiHotkey"
   attrib := FileExist( appDataFolder)
   if( ! attrib ) {
         FileCreateDir, % appDataFolder
   }
  
    global _Logger      := new DgLogger( appDataFolder . "\DigiHotkey.log")

    global _PerfCounter := new DgPerfCounter()

    _Logger.logBEGIN    := true
    _Logger.logEND      := true

    _Logger.BEGIN( "subMain" )           

 ahk64Bits := IsAhk64bit()
    
    _Logger.TRACE( "AHK version", A_AhkVersion, "IsAhk64", ahk64Bits )                                                                               ; Ensures a consistent starting directory.

    SendMode Input                                                                                                      ; Better  speed

    ;_PerfCounter.start()

    global _App    := new DgApp()

    ;t1 := _PerfCounter.check()

    _App.init()

    _App.ui.createDialogs()
    
    ;t2 := _PerfCounter.stop()  

    ;_Logger.TRACE( "subMain", "t1_", t1, "t2_", t2 )

    OnExit( "OnExitApp" ) ; set up exit callback

    SetBatchLines, 10ms ; return to default speed settings

    _Logger.END( "subMain" )

return

/*
#include %A_ScriptDir%\..\src\DgTaskManDialog.ahk
#include %A_ScriptDir%\..\src\DgInsomniaDialog.ahk
#include %A_ScriptDir%\..\src\DgTimerDialog.ahk
#include %A_ScriptDir%\..\src\DgReminderDialog.ahk
*/




; EOF
    