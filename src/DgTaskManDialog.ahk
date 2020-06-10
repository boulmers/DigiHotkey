class DgTaskManDialog extends DgObject
{
    __New()
    {
        this.fadeDelayTick   	:= 100
        this.timeoutSec   	    := timeoutSec_

        this.winColor      	    := enumColor.FloralWhite 		; windows Back Color
        this.titleColor      	:= enumColor.DimGray 		; title front color
        this.textColor      	:= enumColor.SteelBlue4  	; message back color

        this.radius		 	        := 10         				; corner radius , set to 0 for squared win

        this.progColor          := enumColor.Azure3
        this.title              := ""
        this.transparency       := 220  ; 0-255 invisible-opaque

        this.winX               := 0
        this.winY               := 0

        this.hWnd        	    := 0
    }
    ;------------------------------------------------------------------------------
    redraw( )
    {
        _Logger.BEGIN(  A_ThisFunc )
        
        Critical

        topM    := 10,  leftM := 10, botM := 10, rightM := 10 ; margin
        txtW    := 120, txtH := 20
        progW   := 120, rowH := 20
        btnW    := 20,  btnH := 20
        
        sumY    := topM, sumX := leftM

        DetectHiddenWindows, On

        this.destroy( animate := false )

        Gui, New, +AlwaysOnTop +ToolWindow   hwndhWnd ; +Border
        this.hWnd := hWnd
        WM_CLOSE := 0x0010 
        OnMessage(WM_CLOSE, this.OnCmdClose.Bind(this)) 

        Gui % this.hWnd ": Color", % this.winColor

        for name, task in _App.taskMan.tasks {

            if( task.Type == enumTaskType.Timer || task.Type == enumTaskType.Reminder  || task.Type == enumTaskType.Insomnia ) {

                leftTimeStr := FormatSeconds( task.getRemainingTime() )
                Gui % this.hWnd ": Font", % " c" enumColor.DarkSlateGray  " s10 wRegular", % "Segoe UI"
                Gui % this.hWnd ": Add", Text,     % " X" leftM " Y" sumY " W" txtW " H" txtH " +c" this.textColor   "+0x200 +BackgroundTrans hWndhTextName",  % name

                sumY += rowH

                Gui % this.hWnd ": Add", Progress, % " X" leftM  " Y" sumY " W" progW " H" rowH  " hwndhProgress" " c" this.progColor " +" enumProgress.PBS_SMOOTH, 0
                Gui % this.hWnd ": Add", Text,     % " X" leftM  " Y" sumY " W" txtW " H" txtH " +c" this.textColor   "+0x200 +Center +BackgroundTrans hWndhTextTime",  % leftTimeStr
                
                Gui % this.hWnd ": Font", % " c" enumColor.DarkSlateGray  " s10 wRegular", % "Webdings"
                Gui % this.hWnd ": Add", Button,   % " X" leftM + progW  " Y" sumY " W" btnW " H" btnH " hwndhStopBtn" , % enumUnicode.Stop
                pauseResumeBtnCaption := task.isPaused ? enumUnicode.Play : enumUnicode.Pause
                Gui % this.hWnd ": Add", Button, % " X" leftM + progW + btnW  " Y" sumY " W" btnW " H" btnH " hwndhPauseResumeBtn" , % pauseResumeBtnCaption

                OnPauseResumeTask := this.OnPauseResumeTask.bind( this, task) 
                GuiControl +g, %hPauseResumeBtn%, % OnPauseResumeTask

                if( task.isPausable ) {
                        GuiControl, Enable, % hPauseResumeBtn
                } else {
                        GuiControl, Disable, % hPauseResumeBtn
                }

                OnCmdStopTask := this.OnCmdStopTask.bind( this, task )
                GuiControl +g, %hStopBtn%, % OnCmdStopTask

                task.uiElements := { "hProgress": hProgress, "hTextName": hTextName, "hTextTime": hTextTime , hStopBtn: "hStopBtn" , "hPauseResumeBtn": hPauseResumeBtn}

                sumY += 1.5*rowH
            }
        }

        sumY += 2.0*rowH

        Gui % this.hWnd ": Font",  % " s9 wRegular", % "Segoe UI"

        newTimerLinkContent := "<a>" . _App.ui.lang.lnkNewTimer . "</a>"
        newTimerLinkCallback := this.OnCmdNewTimer.Bind(this)
        Gui % this.hWnd ": Add", Link, % " X" sumX " Y" sumY " hwndhLink", % newTimerLinkContent
        GuiControl, +g, % hLink, % newTimerLinkCallback

        sumX += 60 ; todo : should be computed 

        newReminderLinkContent := "<a>" . _App.ui.lang.lnkNewReminder . "</a>"
        newReminderCallback  := this.OnCmdNewReminder.Bind(this)
        Gui % this.hWnd ": Add", Link, % " X" sumX " Y" sumY " hwndhLink", % newReminderLinkContent
        GuiControl, +g, % hLink, % newReminderCallback

        sumX += 60 ; todo : should be computed 
    
        newInsomniaLinkContent := "<a>" . _App.ui.lang.lnkNewInsomnia . "</a>"
        newInsomniaCallback  :=this.OnCmdNewInsomnia.Bind(this)
        Gui % this.hWnd ": Add", Link, % " X" sumX " Y" sumY " hwndhLink", % newInsomniaLinkContent
        GuiControl, +g, % hLink, % newInsomniaCallback

        minWinW :=  leftM + progW + btnW

        ; added an empty text to ensure a minimun width when there is no elements to show ( todo : fix window not showing at minimu width)
        Gui % this.hWnd ": Add", Text,     % " X" minWinW  " Y" 0,  % ""

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    isVisible()
    {
        return w32IsWindowVisible( this.hWnd )
    }
    ;------------------------------------------------------------------------------
    show( redraw_ := true, animate_ := true)
    {
        _Logger.BEGIN(  A_ThisFunc )
        Critical

        if( redraw_ ) {
            this.redraw()
        }
        
        Gui % this.hWnd ": Show" , % "NA Hide", % _App.ui.lang.mnuTaskMan

        WinGetPos, winX, winY, winW, winH, % "ahk_id" this.hWnd

        WinSet, Region,% "0-0" " W" winW " H" winH  " R" this.radius "-" this.radius, % "ahk_id" this.hWnd

        this.winX :=  this.winX  ? this.winX : A_ScreenWidth - winW
        this.winY :=  this.winY  ? this.winY : A_ScreenHeight -winH -  _App.ui.taskbarHeight

        DetectHiddenWindows,  Off

        Critical, Off

        if( animate_ ) {

            Gui % this.hWnd ": Show", % " X" this.winX " Y" this.winY  " NA Hide", % _App.ui.lang.mnuTaskMan
            w32AnimateWin( this.hWnd, this.fadeDelayTick, enumAnim.FADE_IN )

        } else {
            Gui % this.hWnd ": Show", % " X" this.winX " Y" this.winY " NA", % _App.ui.lang.mnuTaskMan
        }

        WinSet, Transparent, % this.transparency, % "ahk_id" this.hWnd

        _Logger.END( A_ThisFunc )

        Critical, Off
    }
    ;------------------------------------------------------------------------------
    destroy( animate_ )
    {
        ;_Logger.BEGIN(  A_ThisFunc )
        DetectHiddenWindows, On

        if( ! WinExist("ahk_id" this.hWnd ))
            return

        WinGetPos, winX, winY, winW, winH, % "ahk_id" this.hWnd

        this.winX := winX
        this.winY := winY

        if( w32IsWindowVisible( this.hWnd ) ) {
            ; this.hWnd && WinExist("ahk_id" this.hWnd) ) {
            if( animate_ ) {
                w32AnimateWin( this.hWnd, this.fadeDelayTick , enumAnim.FADE_OUT )
            }

            Gui %  this.hWnd ": Destroy"
        }

        DetectHiddenWindows, Off

        ;_Logger.END(  A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    OnCmdStopTask( task_ )
    {
        _App.removeTask( task_ )
    }
    ;------------------------------------------------------------------------------
    OnPauseResumeTask( task_ )
    {
        ;_Logger.TRACE( A_ThisFunc , "task_", task_)
        _App.pauseResumeTask( task_ )
    }
    ;------------------------------------------------------------------------------
    OnCmdNewTimer()
    {
        _Logger.BEGIN( A_ThisFunc )

        _App.addNewTimer()

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    OnCmdNewReminder()
    {
        _Logger.BEGIN( A_ThisFunc )

        _App.addNewReminder()

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    OnCmdNewInsomnia() ; Delete timer after clicking ont its menu
    {
        _Logger.BEGIN( A_ThisFunc )

        _App.addNewInsomnia()

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    OnCmdClose()
    {
        _Logger.BEGIN( A_ThisFunc )

        this.destroy( animate_ := true )

        SoundBeep

        _Logger.END( A_ThisFunc )
    }
}
