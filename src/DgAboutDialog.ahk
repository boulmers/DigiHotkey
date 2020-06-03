
class DgAboutDialog ;extends DgObject
{
    __New()
    {
        _Logger.BEGIN(A_ThisFunc)

        Gui, New, -MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop hwndhWnd
        this.hWnd   := hWnd

        Gui, Font, s9, Segoe UI
        Gui, Add, GroupBox, X5 Y0 W290  H105, % "" ; "Timer"
        
        Gui, Add, Text, X110 Y30 W200 H20 ,  % "DigiHotkey v" . _dhkVersion
        Gui, Add, Text, X110 Y50 W200 H20 ,  % "boulmers@gmail.com"
        Gui, Add, Text, X110 Y80 W200 H20 ,  % "MIT License"
    
        ;_____________________________________________________________________________
        Gui, Add, Button, x110  y110   w100   h25 hWndhBtnOK,            % "OK"

        OnBtnOKClick := this.OnBtnOKClick.bind( this )

        GuiControl +g, %hBtnOK%, % OnBtnOKClick 

        _Logger.END(A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    show()
    {
        _Logger.BEGIN(A_ThisFunc)
        
        DetectHiddenWindows, On ; save := true => save

        Gui % this.hWnd ": Show" , hide

        WinGetPos, winX, winY, winW, winH, % "ahk_id" this.hWnd

       
        if( this.winX < 0 && this.winY < 0 ) {

            this.winX := A_ScreenWidth - winW,
            this.winY := A_ScreenHeight  - winH - _App.ui.taskbarHeight
        }

        Gui % this.hWnd ": Show", % "W300 H145" " X " this.winX " Y " this.winY, % _App.ui.lang.dlgAbout

        DetectHiddenWindows,  Off ; save := false => restore

        _Logger.END(A_ThisFunc)

    }
    ;------------------------------------------------------------------------
    hide()
    {
        Gui % this.hWnd ": Show", Hide
    }
    ;------------------------------------------------------------------------
    OnBtnOKClick(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        _Logger.BEGIN(  A_ThisFunc )

        this.hide()

        _Logger.END( A_ThisFunc )
    }
    
}
