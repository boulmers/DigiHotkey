; Begin Test
/*
    #SingleInstance Ignore

    #Include Tools.ahk
    #include DgLogger.ahk
    #include DgEnum.ahk

    start:
        logFile := A_ScriptName ".log"
        global _Logger:= new DgLogger( A_ScriptDir , logFile, recycle := true)

        global SliderTip := new DgProgressTip(width := 150, height := 20, timeoutSec := 1 )

        SliderTip.show( 50, enumColor.LedOn )

        Sleep 250

        SliderTip.show( 75, enumColor.LedOffBack )

        Sleep 1000

        ExitApp
    return
*/
; End Test
;==============================================================================
class DgProgressTip
{
   __New( args_ )
    {

        this.width          := args_.width 		    ? args_.width 	        : 150
        this.height         := args_.height 		    ? args_.height 	        : 20
        this.fadeDelayTick  := args_.fadeDelayTick   ? args_.fadeDelayTick 	: 50
        this.timeoutSec     := args_.timeoutSec      ? args_.timeoutSec 	    : 2

        this.textColor       := args_.textColor        ? args_.textColor 	    : enumColor.Azure1
        this.winColor       := args_.winColor        ? args_.winColor 	    : enumColor.Azure3
        this.textSize        := args_.textSize         ? args_.textSize 	        : 5

        this.timerCallback  := this.close.Bind( this )
        this.timer 			:= new DgSysTimer( this.timerCallback, -1000*this.timeoutSec )

        this.hWnd           := 0
        this.hProgess       := 0
    }
    ;------------------------------------------------------------------------------
    __Delete()
    {
        this.destroy()
    }
    ;------------------------------------------------------------------------------
    show( value_ , color_, text_ := "" )
    {
        winRadius      := this.height, ; window corner radius
        winColor    := this.winColor,
        textColor    := this.textColor,
        textSize     := this.textSize

    DetectHiddenWindows, On

        if( w32IsWindowVisible( this.hWnd ) ) {

            GuiControl, % "+c"color_, % this.hProgess ;
            GuiControl, , % this.hProgess , % Round( value_ )

            this.timer.stop()
            this.timer.start()
            return
        }

        this.destroy()

        Gui, New, +AlwaysOnTop +ToolWindow -SysMenu -Caption -Border  hwndhWnd ;
        this.hWnd := hWnd
        Gui % this.hWnd ": Color", %winColor%

        Gui, % hWnd ": Add", Progress, % " W" this.width + 5 " H" this.height + 5 " X" -2 " Y" -2 " C" color_ " Range0-100 hwndhProgess", % Round(value_)   ; " +" PBS_MARQUEE

        if( text_ ) {
            _Logger.TRACE( A_ThisFunc, "text_", text_ )

            Gui % this.hWnd ": Color", %winColor%
            Gui % this.hWnd ": Font", s%textSize% c%textColor%, Calibri
            Gui % this.hWnd ": Add", Text, Center hwndhText, % text_
        }

        Gui, % hWnd ": Show", % " Hide"  " W" this.width " H" this.height " X" 0 " Y" 0 ; Center ; w+150 h+22 x0 y0, volume
        this.hProgess := hProgess

        WinGetPos, winX, winY, winW, winH, % "ahk_id" hWnd

        WinSet, Region, % "0-0" " W" winW " H" winH  " R" winRadius "-" winRadius,  % "ahk_id" hWnd

        hWndA := WinExist( "A" )

        if ( hWndA > 0 && hWndA != hWnd ) {

            WinGetPos, winXA, winYA, winWA, winHA, A ; active win position and dimestions

            winCenX := winXA  + (winWA / 2) - (this.width / 2)  ;  win center X coord
            winCenY := winYA  + (winHA / 2) - (this.height / 2) ;  win center Y coord

            Gui, % hWnd ": Show", % " X" winCenX " Y" winCenY " NA Hide"

            w32AnimateWin( hWnd, this.fadeDelayTick, enumAnim.ZOOM_IN )

            this.timer.start()
        }

    DetectHiddenWindows, Off
    }
    ;------------------------------------------------------------------------------
    close()
    {
        this.timer.stop()

        if( this.hWnd && WinExist( "ahk_id" this.hWnd ) ) {
            w32AnimateWin(this.hWnd, this.fadeDelayTick, enumAnim.ZOOM_OUT )
            Gui %  this.hWnd ": Destroy"
        }
    }
    ;------------------------------------------------------------------------------
    destroy()
    {
        this.timer.stop()

        if( this.hWnd && WinExist( "ahk_id" this.hWnd ) ) {
            Gui %  this.hWnd ": Destroy"
        }
    }
}
