; BEGIN Test
/*
#SingleInstance Ignore

#Include Tools.ahk
#include DgLogger.ahk
#include DgEnum.ahk

    global _Logger := new DgLogger( A_ScriptDir , A_ScriptName ".log", recycle := true)
    global _cTip   := new DgInfoTip( 1 )

    _cTip.show("A", enumColor.ledOn )

    Sleep 500

    _cTip.show("A", enumColor.ledOff )

    Sleep 500

    _cTip.show("1",_LedOffColor)

    Sleep 1000

    _cTip.show("1",_LedOnColor)


    Sleep 1000

    _cTip.show("ðŸš«",_LedWarnColor)

    Sleep 1000


ExitApp

#Esc::ExitApp
*/
;==============================================================================
class DgInfoTip
{
    __New( args_ , texts_ )
    {
        this.timeoutSec     := args_.timeoutSec 		? args_.timeoutSec 	  : 2 ; negative => fire once
        this.winColor       := args_.winColor 		? args_.winColor 	  : enumColor.LightGray
        this.textColor      := args_.textColor 		? args_.textColor 	  : enumColor.LedOffBack 		; message back color
        this.textSize       := args_.textSize 		? args_.textSize 	  : 20
        this.textStyle      := args_.textStyle 		? args_.textStyle 	  : "Regular"
        this.textFont       := args_.textFont 		? args_.textFont 	  : "Segoe UI"

        this.width          := args_.width 		    ? args_.width 	      : 35
        this.height         := args_.height 		    ? args_.height 	      : 35
        this.winRadius      := args_.winRadius 		? args_.winRadius 	  : this.height/4
        this.fadeDelayTick  := args_.fadeDelayTick 	? args_.fadeDelayTick  : 100 ; Milli Sec

        this.transparency   := 180

        this.timerCallback  := this.close.Bind( this )
        this.timer 		    := new DgSysTimer( this.timerCallback, -1000*this.timeoutSec )

        this.inAnimation    := enumAnim.ZOOM_IN
        this.outAnimation   := enumAnim.ZOOM_OUT

        this.texts          := texts_

        this.hWnd           := 0
        this.hText          := 0
    }
    ;------------------------------------------------------------------------------
    __Delete()
    {
       this.destroy()
    }
    ;------------------------------------------------------------------------------
    show( animate_ := true ) ; if message is empty, then use texts object to render info tip
    {
        Critical

        DetectHiddenWindows, On

        winW        := this.width
        winH        := this.height

        this.destroy()

        Gui, New, +AlwaysOnTop +ToolWindow -SysMenu -Caption  hwndhWnd
        this.hWnd   := hWnd

        Gui % this.hWnd ": Color", %  this.winColor

        for _, text in this.texts {

            Gui % this.hWnd ": Font", % " s" text.size " c" text.color " w" text.style, % text.font

            Gui % this.hWnd ": Add", Text, %  " X" text.x " Y" text.y  " BackGroundTrans", % text.content        ;+0x201: +0x1 horizontall center text, +0x200  vertically center, 0x201 => combination , see msdn

        }

        Gui % this.hWnd ": Show", % " W" this.width " H" this.height " NA"

        WinGetPos, winX, winY, winW, winH, % "ahk_id" this.hWnd

        WinSet, Region,% "0-0" " W" winW " H" winH  " R" this.winRadius "-" this.winRadius,  % "ahk_id" this.hWnd

        hWndA := WinExist( "A" )                                                                                        ; Active hWnd

        if ( hWndA > 0 && hWndA != this.hWnd ) {

            WinGetPos, winXA, winYA, winWA, winHA, A                                                                    ; active win position and dimesions

            winCenX := winXA  + winWA/2 - (this.width / 2)                                                              ;  win center X coord
            winCenY := winYA  + winHA/2 - (this.height / 2)                                                             ;  win center Y coord

            if( animate_ ) {

                Gui % this.hWnd ": Show", % " X" winCenX " Y" winCenY " W" this.width " H" this.height " NA Hide"
                w32AnimateWin( this.hWnd, this.fadeDelayTick, this.inAnimation )

            } else {

                Gui % this.hWnd ": Show", % " X" winCenX " Y" winCenY " W" this.width " H" this.height " NA"

            }

            this.timer.start()
        }

        WinSet, Transparent, % this.transparency, % "ahk_id" this.hWnd

        DetectHiddenWindows, Off
        Critical, Off
    }
    ;------------------------------------------------------------------------------
    close()
    {
        this.timer.stop()

        if( this.hWnd && WinExist("ahk_id" this.hWnd) ) {
            w32AnimateWin( this.hWnd, this.fadeDelayTick, this.outAnimation )
            Gui %  this.hWnd ": Destroy"
        }
    }
    ;------------------------------------------------------------------------------
    destroy()
    {
        this.timer.stop()

        if( this.hWnd && WinExist("ahk_id" this.hWnd) ) {
            Gui %  this.hWnd ": Destroy"
        }
    }
    ;------------------------------------------------------------------------------
    isVisible()
    {
        return w32IsWindowVisible(this.hWnd)
    }
}

