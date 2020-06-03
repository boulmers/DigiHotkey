;==============================================================================----------------------
Class DgNotification
{
    static stackCount   := 0 ; visible notification windows
    static stackHeight  := 0
    static stackPadding := 5


    __New( args_ )
    {
        this.fadeDelayTick  := args_.fadeDelayTick 	? args_.fadeDelayTick : 125
        this.timeoutSec		:= args_.timeoutSec 		? args_.timeoutSec 	 : 2
        this.winColor      	:= args_.winColor 		? args_.winColor 	 : enumColor.FloralWhite ;Gainsboro     				; windows Back Color
        this.titleColor     := args_.titleColor 		? args_.titleColor 	 : enumColor.DimGray  					; title front color
        this.msgColor      	:= args_.msgColor 		? args_.msgColor 	 : enumColor.SteelBlue4    				; message back color
        this.cornerRad		:= args_.cornerRad 		? args_.cornerRad 	 : 15         							; corner cornerRad , set to 0 for squared win
        this.hasCloseBtn    := args_.hasCloseBtn 	? args_.msgColor 	 : false
        this.isStackable    := args_.isStackable 	? args_.isStackable 	 : true

        this.titleBakColor  := enumColor.Gainsboro

        this.linkText	 	:= args_.linkText
        this.linkCallback   := args_.linkCallback

        this.hWnd        	:= 0
        this.width 			:= 250
        this.height 		:= 0

        this.msgSize 		:= 12
        this.msgStyle 		:= "Regular"

        this.titleStyle 	:= "Bold"
        this.titleSize		:= 10

        this.font			:= "Segoe UI"

        this.destroyCallback  	:= this.destroy.Bind( this , true )
        this.timer 				:= new DgSysTimer( this.destroyCallback, -1000*this.timeoutSec )

    }
    ;------------------------------------------------------------------------------
    __Delete()
    {
        this.destroy( animate := false )
    }
    ;------------------------------------------------------------------------------
    show( title_, message_ := "" )
    {

    Critical
    DetectHiddenWindows, On
                                                        ; prevents WinGetPos to fail
        if( ! this.isStackable ) {
            this.destroy( animate := false )
        }

        Gui, New, +AlwaysOnTop +ToolWindow -SysMenu -Caption  hwndhWnd ; +Border
        this.hWnd := hWnd
        Gui % this.hWnd ": Color", % this.winColor

        leftM 	:= 10, 		  		textY  	:= 5
        progX 	:= 0, 		  		progY 	:= 0
        progH 	:= 30 ,  ; the title height ( progress bar used here to color the title background for simplicity)

        if( message_ ) {

            Gui, % hWnd ": Add", Progress, % " W" this.width + 2*leftM  " H" progH  " X" progX " Y" progY " C" this.titleBakColor " Range0-100 hwndhProgess", % 100
            Gui % this.hWnd ": Font", % " c" this.titleColor " s" this.titleSize "w" this.titleStyle, % this.font
            Gui % this.hWnd ": Add", Text, % " X" leftM " Y" textY  " hwndhwndTxt BackGroundTrans" , % title_

            ;WinGetPos, textX, textY, textW, textH, % "ahk_id" hwndTxt

            textY += progH

            Gui % this.hWnd ": Font",% " c" this.msgColor " s" this.msgSize  "w" this.msgStyle, % this.font
            Gui % this.hWnd ": Add", Text, % " X"  leftM " Y"  textY " W" this.width  " hwndhwndTxt", % message_

            WinGetPos, textX, textY, textW, textH, % "ahk_id" hwndTxt

        } else {

            this.hasCloseBtn    := false
            Gui % this.hWnd ": Font", % " c" this.msgColor " s" this.msgSize  "w" this.msgStyle, % this.font
            Gui % this.hWnd ": Add", Text, % " X" leftM " Y" textY " W" this.width " hwndhwndTxt" , % title_

            WinGetPos, textX, textY, textW, textH, % "ahk_id" hwndTxt
        }

        textY += textH

        if ( this.linkText ) {

            linkContent := "<a>" . this.linkText . "</a>"
            Gui % this.hWnd ": Font", s10 wRegular, Segoe UI
            Gui % this.hWnd ": Add", Link, % " X" leftM " Y" textY " hwndhLink", % linkContent
            linkCallback := this.linkCallback
            GuiControl +g, %hLink%, % linkCallback
        }

        Gui % this.hWnd ": Show" , % " W" this.width + leftM " hide "

        WinGetPos, winX, winY, winW, winH, % "ahk_id" this.hWnd
        this.height := winH

        if ( this.hasCloseBtn ) {

            btnW := 16,
            btnH := 16
            btnX := winW - 3*btnW ,
            btnY := 5,
            btnCol := enumColor.NotifyCloseBtn ;gray

            Gui % this.hWnd ": Font", c%btnCol% s10 wRegular, Segoe UI	
            Gui % this.hWnd ": Add", Button, % " X" btnX " Y" btnY " W" btnW " H" btnH " hwndhCloseBtn " , % Chr(0x2A09) ; unicode X

            GuiControl +g, %hCloseBtn%, % this.destroyCallback
        }

        WinSet, Region,% "0-0" " W" winW " H" winH  " R" this.cornerRad "-" this.cornerRad, % "ahk_id" this.hWnd


        if( this.isStackable ) {
            this.stackPush() 													; uses this.height to update stack info
        }

        winX := A_ScreenWidth - winW
        winY := A_ScreenHeight - DgNotification.stackHeight - _App.ui.taskbarHeight

        Gui % this.hWnd ": Show", % " X" winX " Y" winY " NA Hide" ;" H" winH

        w32AnimateWin(this.hWnd, this.fadeDelayTick, enumAnim.SLIDE_BOTTOM_TO_TOP )

        this.timer.start()

    DetectHiddenWindows,  Off
    Critical, Off
        ;_Logger.END(  A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    destroy( animate )
    {
        _Logger.BEGIN(  A_ThisFunc )
    Critical

        if( this.hWnd && WinExist("ahk_id" this.hWnd) ) { 						; test this.hWnd before going further

            if( this.isStackable ) {
                this.stackPop() 												; uses this.height to update stack info
            }

            w32AnimateWin(this.hWnd, this.fadeDelayTick , enumAnim.SLIDE_LEFT_TO_RIGHT  )
            Gui %  this.hWnd ": Destroy"
        }

    Critical, Off
        _Logger.END(  A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    stackPush()
    {
        DgNotification.stackCount := DgNotification.stackCount + 1
        DgNotification.stackHeight := DgNotification.stackHeight + (this.height + DgNotification.stackPadding)

    }
    ;------------------------------------------------------------------------------
    stackPop()
    {
        DgNotification.stackCount := DgNotification.stackCount - 1

        if( this.stackCount < 1 ) {
            DgNotification.stackHeight := 0
        } else {
            DgNotification.stackHeight := DgNotification.stackHeight - (this.height - DgNotification.stackPadding)
        }

    }
    ;------------------------------------------------------------------------------
    isVisible()
    {
        return w32IsWindowVisible(this.hWnd)
    }
}
; EOF

