
class DgInsomniaDialogState extends DgPersistent
{
    __New()
    {
        _Logger.BEGIN(A_ThisFunc)

        this.durationHour     := 1
        this.durationMin      := 0

        this.ID               := "InsomniaDialog"
        this.name             := "Insomnia"

        this.winX           := -1
        this.winY           := -1

        _Logger.END(A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    save()
    {
        _Logger.BEGIN(A_ThisFunc)

        this.toRegistry( _App.regKey, this.ID)

        _Logger.END(A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    load()
    {
        _Logger.END(A_ThisFunc)

        this.fromRegistry( _App.regKey, this.ID)

        _Logger.END(A_ThisFunc)
    }
}
;==============================================================================
class DgInsomniaDialog ;extends DgObject
{

    __New()
    {
        _Logger.BEGIN(A_ThisFunc)

        this.hWnd               := 0

        this.hEditPeriodMin     := 0
        this.hEditDurationHour  := 0
        this.hEditDurationMin   := 0

        this.state              := new DgInsomniaDialogState()

        Gui New, -MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop +OwnDialogs +Owner   hwndhWnd
        Gui Font, s9, Segoe UI
        Gui Add, GroupBox,                                   x10  y5  w310  h80,                  % _App.ui.lang.dlgTime ;"Time"
            ;______________________________________________________________________________________________________________
            Gui, Add, Text,                                  x20    y35     w50     h23,        % _App.ui.lang.dlgDuration ;"Duration"
            Gui, Add, Edit,  hWndhEditDurationHour           x80    y30     w50     h23 Number
            Gui, Add, UpDown, Range0-24, 10 ; HH:mm  ;
            Gui, Add, Text,                                  x135    y35     w25     h23,        % _App.ui.lang.dlgHour ;"hr"

            Gui, Add, Edit,  hWndhEditDurationMin            x170    y30     w50     h23 Number
            Gui, Add, UpDown, Range0-60, 10 ; HH:mm  ;
            Gui, Add, Text,                                  x225    y35     w25     h23,        % _App.ui.lang.dlgMinute ;"min"
            ;______________________________________________________________________________________________________________

        Gui, Add, Button,    hWndhBtnStart                  x65     y100    w80     h25 +Default, % _App.ui.lang.dlgStart ;"Start"
        Gui, Add, Button,    hWndhBtnCancel                 x185    y100    w80     h25,          % _App.ui.lang.dlgCancel ;"Cancel"

        OnStartButtonClick := this.OnStartButtonClick.Bind(this)
        GuiControl +g, %hBtnStart%, % OnStartButtonClick

        OnCancelButtonClick := this.OnCancelButtonClick.Bind(this)
        GuiControl +g, %hBtnCancel%, % OnCancelButtonClick

        this.hWnd               := hWnd                     ; dialog handle

        this.hEditDurationHour  := hEditDurationHour        ; Time hours text edit handle
        this.hEditDurationMin   := hEditDurationMin         ; Time minutes text edit handle

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    show()
    {
        _Logger.BEGIN(A_ThisFunc)

        DetectHiddenWindows, On ; save := true => save

        Gui % this.hWnd ": Show" , hide

        WinGetPos, winX, winY, winW, winH , % "ahk_id" this.hWnd

        this.state.load()

        this.winX := this.state.winX,
        this.winY := this.state.winY

        if( this.winX < 0 && this.winY < 0 ) {
            this.winX := A_ScreenWidth - winW,
            this.winY := A_ScreenHeight - winH - _App.ui.taskbarHeight
        }

        GuiControl, Text,   % this.hEditDurationHour, % this.state.durationHour
        GuiControl, Text,   % this.hEditDurationMin,  % this.state.durationMin

        Gui % this.hWnd ": Show", % "w330 h130" " X" this.winX " Y" this.winY, % _App.ui.lang.dlgInsomnia

        DetectHiddenWindows,  Off ; save := false => restore

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    hide()
    {
        Gui % this.hWnd ": Show", Hide
    }
    ;------------------------------------------------------------------------
    submit()
    {
        Gui % this.hWnd ": Submit"

        DetectHiddenWindows, On
            WinGetPos, winX, winY, winW, winH, % "ahk_id" this.hWnd
        DetectHiddenWindows,  Off

        this.winX := winX,
        this.winY := winY

        GuiControlGet, durationHour ,,      % this.hEditDurationHour
        GuiControlGet, durationMin ,,       % this.hEditDurationMin

        this.state.durationHour     := durationHour
        this.state.durationMin      := durationMin

        this.state.winX  := this.winX,
        this.state.winY  := this.winY

        return this.state
    }
    ;------------------------------------------------------------------------
    OnStartButtonClick()
    {
        state := this.submit()
        task  := _App.taskMan.getTaskByName( state.name )

        if( task ) {
            _App.ui.showAlertMessage( _App.name, _App.ui.lang.msgOneInsomniaTask`)
            this.show()
            return
        }

        task := _App.createInsomniaTaskFromDialog( state )

        _App.addTask( task )

        this.saveState()
        this.hide()

        _Logger.END(  A_ThisFunc )
    }
    ;------------------------------------------------------------------------
    OnCancelButtonClick()
    {
        this.hide()
    }
    ;------------------------------------------------------------------------
    saveState()
    {
        this.state.save()
    }
}
