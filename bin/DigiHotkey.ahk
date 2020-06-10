/*
AutoHotKey    : v1.1.29.01    https://autohotkey.com/
Description   : Windows productivity tools and keyboard sounds.
Author        : boulmers@gmail.com
License       : MIT
*/

#SingleInstance Ignore
#InstallKeybdHook ;Fforces keyboard hook installation;
#KeyHistory 0  ; disable key histoy to optimize time and space
#MenuMaskKey vkFF
#NoEnv

SetBatchLines -1    ; never micro-sleep for performance
ListLines Off  ; disable ListLines which is equivalent to selecting the "View->Lines most recently executed" => peformance optimization after debug
SetBatchLines -1 ; never sleep until initialization is done.
Process, Priority, , H
;==============================================================================
#include %A_ScriptDir%\..\lib\json.ahk
#Include %A_ScriptDir%\..\lib\volume.ahk
#Include %A_ScriptDir%\..\lib\VA.ahk
#include %A_ScriptDir%\..\lib\RHotKey.ahk

#include %A_ScriptDir%\..\src\DgInsomniaDialog.ahk
#include %A_ScriptDir%\..\src\DgTimerDialog.ahk
#include %A_ScriptDir%\..\src\DgReminderDialog.ahk
#include %A_ScriptDir%\..\src\DgTaskManDialog.ahk
#include %A_ScriptDir%\..\src\DgAboutDialog.ahk

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
; global variables are prefixed with _ sign (ex _App )
; function parameters are supposed to be suffixed with _ sign (ex name_ )
; out variable (by ref) are prefixed with the $ (ex $outFile )
;==============================================================================
main:
      SetWorkingDir % A_ScriptDir

      global _dhkVersion    := "0.2.0"

      logFile             := PathCombine( A_WorkingDir, "..\config\DigiHotkey.log")
      global _Logger      := new DgLogger( logFile )
      _Logger.logBEGIN    := true
      _Logger.logEND      := true
      
      _Logger.BEGIN( "main" )      

      global _PerfCounter := new DgPerfCounter()           

      ahk64Bits := IsAhk64bit()

      _Logger.TRACE( A_ThisLabel, "ahk64Bits", ahk64Bits)
    
      SendMode Input                                                                                                      ; Better  speed

      /* 
      _PerfCounter.start() 
      */

      global _App    := new DgApp()

      /*
      t1 := _PerfCounter.check()
      */

      _App.init()

      _App.ui.createDialogs()
    
      /*
      t2 := _PerfCounter.stop()  
      _Logger.TRACE( "subMain", "t1_", t1, "t2_", t2 )
      */

      OnExit( "OnExitApp" )   ; set up exit callback

      Process, Priority, , N  ; return to normal precess priority

      SetBatchLines, 10ms     ; return to default sleep settings

      _Logger.END( "main" )

return

    