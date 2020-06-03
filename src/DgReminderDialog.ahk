
class DgReminderDialogState extends DgPersistent
{
    __New()
    {
        _Logger.BEGIN(A_ThisFunc)

        this.periodicEnabled  := 1
        this.hourlyEnabled    := 0
        this.periodMin        := 5
        this.durationHour     := 1
        this.durationMin      := 0

        this.name             := "My reminder"
        this.message          := "Get a pause!"

        this.ID               := "ReminderDialog"

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
class DgReminderDialog ;extends DgObject
{

    __New()
    {
        _Logger.BEGIN(A_ThisFunc)

        this.hWnd               := 0
        this.hRadioPeriodic     := 0
        this.hRadioHourly       := 0

        this.hEditPeriodMin     := 0
        this.hEditDurationHour  := 0
        this.hEditDurationMin   := 0

        this.hEditName         := 0
        this.hEditMessage      := 0

        this.state              := new DgReminderDialogState()

        Gui New, -MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop +OwnDialogs +Owner   hwndhWnd
        Gui Font, s9, Segoe UI
        Gui Add, GroupBox,                            x10  y5  w310  h135,                  % _App.ui.lang.dlgTime ;"Time"
            Gui Add, Radio,  hWndhRadioPeriodic       x20     y25     w100     h23 +Checked,   % _App.ui.lang.dlgPeriodic ;"Periodic"
            Gui Add, Radio,  hWndhRadioHourly         x20     y110    w100     h23 ,          % _App.ui.lang.dlgHourly ;"Hourly"
            ;___________________________________________________________________________________
            Gui, Add, Text,                           x85     y50     w50     h23,        % _App.ui.lang.dlgEvery ;"Every"
            Gui, Add, Edit,  hWndhEditPeriodMin       x235    y45     w50     h23 Number
            Gui, Add, UpDown, Range0-60, 10 ; HH:mm  
            Gui, Add, Text,                           x290    y50     w25     h23,        % _App.ui.lang.dlgMinute ;"min"
            ;___________________________________________________________________________________
            Gui, Add, Text,                           x85     y85     w50     h23,        % _App.ui.lang.dlgDuration ;"Duration"
            Gui, Add, Edit,  hWndhEditDurationHour    x145    y80     w50     h23 Number
            Gui, Add, UpDown, Range0-24, 10 ; HH:mm  
            Gui, Add, Text,                           x200    y85     w25     h23,        % _App.ui.lang.dlgHour ;"hr"

            Gui, Add, Edit,  hWndhEditDurationMin     x235    y80     w50     h23 Number
            Gui, Add, UpDown, Range0-60, 10 ; HH:mm  
            Gui, Add, Text,                           x290    y85     w25     h23,        % _App.ui.lang.dlgMinute ;"min"
        Gui Add, GroupBox,                            x10     y145  w310  h110,                  % _App.ui.lang.dlgInfos ;"Reminder"
            Gui, Add, Text,                           x20     y170    w50     h23,        % _App.ui.lang.dlgName ;"Name"
            Gui, Add, Edit,  hWndhEditName            x85     y165    w220    h23 Limit
            ;___________________________________________________________________________________
            Gui, Add, Text,                           x20     y200    w50     h23,        % _App.ui.lang.dlgMessage ;"Message"
            Gui, Add, Edit, R2 hWndhEditMessage                                    x85     y200    w220    h23 Limit
        Gui, Add, Button,    hWndhBtnStart            x65     y260    w80     h25 +Default, % _App.ui.lang.dlgStart ;"Start"
        Gui, Add, Button,    hWndhBtnCancel           x185    y260    w80     h25,          % _App.ui.lang.dlgCancel ;"Cancel"

        OnBtnStartClick := this.OnBtnStartClick.bind( this )
        OnBtnCancelClick   := this.OnBtnCancelClick.bind( this )
        OnRadPeriodicClick := this.OnRadPeriodicClick.bind( this )
        OnRadHourlyClick  := this.OnRadHourlyClick.bind( this) 


        GuiControl +g, %hBtnStart%, % OnBtnStartClick 
        GuiControl +g, %hBtnCancel%, % OnBtnCancelClick 
        GuiControl +g, %hRadioPeriodic%, % OnRadPeriodicClick 
        GuiControl +g, %hRadioHourly%, % OnRadHourlyClick 


        this.hWnd               := hWnd             ; dialog handle
        this.hRadioPeriodic     := hRadioPeriodic     ; Periodic radio handle
        this.hRadioHourly       := hRadioHourly       ; Hourly radio handle

        this.hEditPeriodMin     := hEditPeriodMin       ; Period minutes textedit handle

        this.hEditDurationHour  := hEditDurationHour        ; Time hours text edit handle
        this.hEditDurationMin   := hEditDurationMin         ; Time minutes text edit handle

        this.hEditName          := hEditName
        this.hEditMessage       := hEditMessage          ; Message text edit handle

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

        this.winX := -1 ;this.state.winX,
        this.winY := -1 ;this.state.winY

        if( this.winX < 0 && this.winY < 0 ) {
            this.winX := A_ScreenWidth - winW,
            this.winY := A_ScreenHeight - winH - _App.ui.taskbarHeight
        }


        GuiControl, ,       % this.hRadioPeriodic,    % this.state.periodicEnabled
        GuiControl, ,       % this.hRadioHourly,      % this.state.hourlyEnabled

        GuiControl, Text,   % this.hEditPeriodMin,    % this.state.periodMin
        GuiControl, Text,   % this.hEditDurationHour, % this.state.durationHour
        GuiControl, Text,   % this.hEditDurationMin,  % this.state.durationMin
        GuiControl, Text,   % this.hEditName,         % this.state.name
        GuiControl, Text,   % this.hEditMessage,      % this.state.message

        Gui % this.hWnd ": Show", % "w330 h290" " X" this.winX " Y" this.winY, % _App.ui.lang.dlgReminder

        ;_Logger.TRACE( A_ThisFunc, "WinX", this.winX, "winY", this.winY)

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

        GuiControlGet, periodicEnabled ,,   % this.hRadioPeriodic
        GuiControlGet, hourlyEnabled ,,     % this.hRadioHourly

        GuiControlGet, periodMin ,,         % this.hEditPeriodMin
        GuiControlGet, durationHour ,,      % this.hEditDurationHour
        GuiControlGet, durationMin ,,       % this.hEditDurationMin
        GuiControlGet, name ,,              % this.hEditName
        GuiControlGet, message ,,           % this.hEditMessage

        ; UGLY to use _App.UI global var, event handler's inside the class arn't feasible without some boilerplate
        this.state.periodicEnabled  := periodicEnabled
        this.state.hourlyEnabled    := hourlyEnabled
        this.state.periodMin        := periodMin
        this.state.durationHour     := durationHour
        this.state.durationMin      := durationMin
        this.state.name             := trim(name)
        this.state.message          := message

        this.state.winX  := this.winX,
        this.state.winY  := this.winY

        return this.state
    }
    ;------------------------------------------------------------------------
    saveState()
    {
        this.state.save()
    }
    ;------------------------------------------------------------------------
    OnRadPeriodicClick(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        _Logger.BEGIN(A_ThisFunc)

        GuiControl, Enable,     % this.hEditPeriodMin

        GuiControl, Enable,     % this.hEditDurationHour
        GuiControl, Enable,     % this.hEditDurationMin

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    OnRadHourlyClick(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        _Logger.BEGIN(A_ThisFunc)

        GuiControl, Disable, % this.hEditPeriodMin

        GuiControl, Disable, % this.hEditDurationHour
        GuiControl, Disable, % this.hEditDurationMin

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    OnBtnStartClick(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        _Logger.BEGIN(  A_ThisFunc )

        state := this.submit()
        task  := _App.taskMan.getTaskByName( state.name )

        ; _Logger.TRACE(A_ThisFunc,"taskName", name, "task",  task)

        if( task ) {
            _App.ui.showAlertMessage( _App.name, _App.ui.lang.msgTimerNameExists)
            this.show()
            return
        }

        task := _App.createReminderTaskFromDialog( state )

        _App.addTask( task )

        this.saveState()
        this.hide()

        ;_Logger.TRACE( A_ThisFunc, "task", task )
        _Logger.END(  A_ThisFunc )
    }
    ;------------------------------------------------------------------------
    OnBtnCancelClick(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        _Logger.BEGIN(  A_ThisFunc )

        this.hide()

        _Logger.END(  A_ThisFunc )
    }
}

