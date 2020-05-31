
class DgAboutDialog ;extends DgObject
{
    __New()
    {
        _Logger.BEGIN(A_ThisFunc)

        this.hWnd              := 0

        Gui, New, -MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop +OwnDialogs +Owner   hwndhWnd
        Gui, Font, s9, Segoe UI
        Gui, Add, GroupBox, x10     y5      w310    h105,           % "About" ; "Timer"
        Gui, Add, Text,     x155    y35     w40     h23,            % "DigiHotkey"
        ;_____________________________________________________________________________
        Gui, Add, Button,    hWndhBtnOK        x180    y235    w80     h25,            % "OK"

        OnBtnOKClick := this.OnBtnOKClick.bind( this )

        GuiControl +g, %hWndhBtnOK%, % OnBtnOKClick 
       
        this.hWnd               := hWnd

        _Logger.END(A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    show()
    {
        _Logger.BEGIN(A_ThisFunc)

        Gui % this.hWnd ": Show" , hide

        WinGetPos, winX, winY, winW, winH, % "ahk_id" this.hWnd

        if( this.winX < 0 && this.winY < 0 ) {

            this.winX := A_ScreenWidth - winW,
            this.winY := A_ScreenHeight  - winH - _App.ui.taskbarHeight
        }

        Gui % this.hWnd ": Show", % "w330 h265" " X" this.winX " Y" this.winY, % _App.ui.lang.dlgTimer

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
