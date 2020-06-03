class DgSysTimer
{
    __New( callback_ := "", periodTick_ := "")
    {
        this.callback 		:= callback_
        this.periodTick	   	:= periodTick_
    }
    ;------------------------------------------------------------------------------
    start( callback_ := "", periodTick_ := "")
    {
        if( callback_ ) {
            this.callback := callback_
        }

        if( periodTick_ ) {
            this.periodTick	   := periodTick_
        }

        SetTimer, % this, % this.periodTick
    }
    ;------------------------------------------------------------------------------
    stop()
    {
        SetTimer, % this, Delete
    }
    ;------------------------------------------------------------------------------
    Call()
    {
        this.callback.Call()
    }
    ;------------------------------------------------------------------------------
    __Delete() ;
    {
        ; _Logger.logTRACE( A_ThisFunc)
    }

}