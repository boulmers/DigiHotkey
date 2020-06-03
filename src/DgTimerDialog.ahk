
; EXAMPLE BEGIN
/*
#include DgObject.ahk

    global _App.ui.dlgTimer := new DgTimerDialog()
    _App.ui.dlgTimer.show( 1000,1000)


return
#esc::ExitApp
*/
; EXAMPLE END
class DgTimerDialogState extends DgPersistent
{
    __New()
    {
        _Logger.BEGIN(A_ThisFunc)

        this.delayEnabled   := 1
        this.timeEnabled    := 0

        this.timeTime        := ""
        this.timeDate        := ""

        this.delayHour      := 0
        this.delayMin       := 15
        this.name           := "My timer"
        this.message        := ""
        this.ID             := "TimerDialog"

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
class DgTimerDialog ;extends DgObject
{
    __New()
    {
        _Logger.BEGIN(A_ThisFunc)

        this.hWnd              := 0
        this.hRadioDelay       := 0
        this.hRadioTime        := 0
        this.hEditDelayHour    := 0
        this.hEditDelayMin     := 0
        this.hTimeTime         := 0
        this.hTimeDate         := 0
        this.hEditName         := 0
        this.hEditMessage      := 0

        this.state             := new DgTimerDialogState()

        Gui, New, -MinimizeBox -MaximizeBox -SysMenu +AlwaysOnTop +OwnDialogs +Owner   hwndhWnd
        Gui, Font, s9, Segoe UI
        Gui, Add, GroupBox,                        x10     y5      w310    h105,           % _App.ui.lang.dlgTime ; "Timer"

            Gui, Add, Radio,     hWndhRadioDelay   x20     y30     w60     h23 +Checked,   % _App.ui.lang.dlgDelay ;"Delay"
            Gui, Add, Radio,     hWndhRadioTime    x20     y70     w60     h23 ,           % _App.ui.lang.dlgOnTime ;"On time"
            ;_____________________________________________________________________________
            Gui, Add, Edit,     hWndhEditDelayHour x90     y30     w60     h23 Number
            Gui, Add, UpDown,   Range0-24, 0 ; HH:mm  ;
            Gui, Add, Text,                        x155    y35     w40     h23,            % _App.ui.lang.dlgHour ;"hour"
            Gui, Add, Edit,     hWndhEditDelayMin  x190    y30     w45     h23 Number
            Gui, Add, UpDown,    Range0-60, 10 ; HH:mm  ;
            Gui, Add, Text,                        x240    y35     w40     h23,            % _App.ui.lang.dlgMinute ;"min"

            Gui, Add, DateTime,  hWndhDateTimeTime x90     y70     w60     h23 +0x9 +0x1, HH:mm
            Gui, Add, DateTime,  hWndhDateTimeDate x190    y70     w120    h23
        ;_____________________________________________________________________________
        Gui, Add, GroupBox,                        x10     y115    w310    h110,           % _App.ui.lang.dlgInfos ; "Timer"
            Gui, Add, Text,                        x20     y135    w50     h23,            % _App.ui.lang.dlgName ;"Name"
            Gui, Add, Edit,      hWndhEditName     x85     y135    w220    h23     Limit

            Gui, Add, Text,                        x20     y170    w50     h23,            % _App.ui.lang.dlgMessage ;"Message"
            Gui, Add, Edit,  R2 hWndhEditMessage   x85     y170    w220    h23     Limit

        Gui, Add, Button,    hWndhBtnStart         x60     y235    w80     h25 +Default,   % _App.ui.lang.dlgStart ;"Start"
        Gui, Add, Button,    hWndhBtnCancel        x180    y235    w80     h25,            % _App.ui.lang.dlgCancel ;"Cancel"

        OnBtnStartClick := this.OnBtnStartClick.bind( this )
        OnBtnCancelClick   := this.OnBtnCancelClick.bind( this )

        OnRadioDelayClick := this.OnRadioDelayClick.bind( this )
        OnRadioTimeClick  := this.OnRadioTimeClick.bind( this) 


        GuiControl +g, %hBtnStart%, % OnBtnStartClick 
        GuiControl +g, %hBtnCancel%, % OnBtnCancelClick 
        GuiControl +g, %hRadioDelay%, % OnRadioDelayClick 
        GuiControl +g, %hRadioTime%, % OnRadioTimeClick 

        

        this.hWnd               := hWnd
        this.hRadioDelay        := hRadioDelay
        this.hRadioTime         := hRadioTime

        this.hEditDelayHour     := hEditDelayHour
        this.hEditDelayMin      := hEditDelayMin

        this.hDateTimeTime      := hDateTimeTime
        this.hDateTimeDate      := hDateTimeDate
        this.hEditName          := hEditName
        this.hEditMessage       := hEditMessage

        this.enableDelayMode()

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

        this.state.load()

        GuiControl, ,      % this.hRadioDelay,      % this.state.delayEnabled
        GuiControl, ,      % this.hRadioTime,       % this.state.timeEnabled

        GuiControl, Text,  % this.hEditDelayHour,   % this.state.delayHour
        GuiControl, Text,  % this.hEditDelayMin,    % this.state.delayMin
        GuiControl, Text,  % this.hEditName,        % this.state.name
        GuiControl, Text,  % this.hEditMessage,     % this.state.message

        Gui % this.hWnd ": Show", % "w330 h265" " X" this.winX " Y" this.winY, % _App.ui.lang.dlgTimer

        DetectHiddenWindows,  Off ; save := false => restore

        _Logger.END(A_ThisFunc)

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

        GuiControlGet, delayEnabled ,,  % this.hRadioDelay
        GuiControlGet, timeEnabled ,,   % this.hRadioTime

        GuiControlGet, timeTime ,,      % this.hDateTimeTime
        GuiControlGet, timeDate ,,      % this.hDateTimeDate
        GuiControlGet, delayHour ,,     % this.hEditDelayHour
        GuiControlGet, delayMin ,,      % this.hEditDelayMin

        GuiControlGet, name ,,          % this.hEditName
        GuiControlGet, message ,,       % this.hEditMessage

        this.state.delayEnabled    := delayEnabled
        this.state.timeEnabled     := timeEnabled

        this.state.timeTime        := timeTime
        this.state.timeDate        := timeDate

        this.state.delayHour       := delayHour
        this.state.delayMin        := delayMin
        this.state.name            := trim(name)
        this.state.message         := message

        this.state.winX  := this.winX,
        this.state.winY  := this.winY

        return this.state
    }
    ;------------------------------------------------------------------------
    enableDelayMode()
    {
        GuiControl, Disable, % this.hDateTimeTime
        GuiControl, Disable, % this.hDateTimeDate

        GuiControl, Enable,  % this.hEditDelayHour
        GuiControl, Enable,  % this.hEditDelayMin
    }
    ;------------------------------------------------------------------------
    enableTimeMode()
    {
        GuiControl, Enable,  % this.hDateTimeTime
        GuiControl, Enable,  % this.hDateTimeDate

        GuiControl, Disable, % this.hEditDelayHour
        GuiControl, Disable, % this.hEditDelayMin
    }
    ;------------------------------------------------------------------------
    saveState()
    {
        this.state.save()
    }
    ;------------------------------------------------------------------------
    OnRadioDelayClick(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        _Logger.BEGIN(A_ThisFunc)

        this.enableDelayMode()

        _Logger.END(A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    OnRadioTimeClick(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        _Logger.BEGIN(A_ThisFunc)

        this.enableTimeMode()

        _Logger.END(A_ThisFunc)
    }
    ;------------------------------------------------------------------------
    OnBtnStartClick(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        _Logger.BEGIN(  A_ThisFunc )

        state := this.submit()


        if( state.name == "" ) {
            _App.ui.showAlertMessage( _App.name, _App.ui.lang.msgTimerNameInvalid )
            this.show()
            return
        }

        task :=  _App.taskMan.getTaskByName( state.name )


        if( task ) {
            _App.ui.showAlertMessage( _App.name, _App.ui.lang.msgTimerNameExists )
            this.show()
            return
        }

        if( ! state.delayEnabled ) { ; timeEnabled
            YYYYMMDD := SubStr( state.timeDate, 1, 8) ; get date, timeDate has AHK format  YYYYMMDDHH24MISS
            HH24MI   := SubStr( state.timeTime, 9, 4) ; get time without seconds
            SS       := "00"                          ; set seconds to 0, as the timeTime get not set by user seconds from  DateTime UI control

            dueTime := YYYYMMDD . HH24MI . SS     ; join results to form AHK formatted time

            diff := dueTime

            diff -= A_Now, Seconds

            if(  diff < 0 ) {
                _App.ui.showAlertMessage( _App.name, _App.ui.lang.msgTimeExpired )
                this.show()
                return
            }
        }

        task := _App.createTimerTaskFromDialog( state )
        _App.addTask( task )

        this.saveState()
        this.hide()

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------
    OnBtnCancelClick(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        _Logger.BEGIN(  A_ThisFunc )

        this.hide()

        _Logger.END( A_ThisFunc )
    }
}
