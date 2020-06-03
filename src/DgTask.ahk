class DgTask extends DgObject
{
    __New( name_, callback_, dueTime_ , periodSec_ , repeatCount_  )
    {
        _Logger.BEGIN( A_ThisFunc)
        
        this.name 		 		:= name_
        this.repeatCount 		:= repeatCount_
        ; NOTE : any callback should have a task as first parameter; see execute method
        this.callback			:= callback_ 
        this.dueTime 			:= dueTime_
        this.periodSec 			:= periodSec_ 																			; repeat period in seconds
        this.exeCount		 	:= 0

        this.dueTimes			:= []
        this.isLastExecution	:= false
        this.startTime    		:= A_Now
        this.remainingTime		:= 0
        this.isPausable     	:= false

        this.isPaused 			:= false
        this.pausedTime 		:= ""

        this.message 			:= ""
        this.type				:= ""

        this.computeDueTimes()

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    computeDueTimes()
    {
        _Logger.BEGIN( A_ThisFunc)
        
        currDueTime :=  this.dueTime

        this.dueTimes.Push( currDueTime )

        Loop, % this.repeatCount { 	; tested for negative numbers
            currDueTime += % this.periodSec ,   Seconds
            this.dueTimes.Push( currDueTime )
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    execute()
    {
        _Logger.BEGIN( A_ThisFunc )

        this.exeCount += 1

        this.isLastExecution := (this.exeCount >= this.dueTimes.Count())

        if( this.callback ) {
            this.callback.Call( this )
        }

        _Logger.END( A_ThisFunc , "this.isLastExecution", this.isLastExecution)
    }
    ;------------------------------------------------------------------------------
    pause()
    {
        this.isPaused 	:= true
        this.pausedTime := A_Now
    }
    ;------------------------------------------------------------------------------
    isDone()
    {
        _Logger.BEGIN( A_ThisFunc)

        done := (this.exeCount >= this.dueTimes.Count() )

        _Logger.END( A_ThisFunc, "done", done)

        return done
    }
    ;------------------------------------------------------------------------------
    isDue()
    {
        _Logger.BEGIN( A_ThisFunc )

        dueTime := this.dueTimes[this.exeCount+1] ; array are 1 based in AHK
        due := ( A_Now >= dueTime )

        if( due && this.Type == enumTaskType.Timer)  { ; on first due time, disable pause as the remainings are only snooze reminders
            this.isPausable := false
        }

        _Logger.END( A_ThisFunc,"this.exeCount", this.exeCount, "dueTime", dueTime, "this.dueTimes", this.dueTimes, "due", due )
        return   due
    }
    ;------------------------------------------------------------------------------
    resume()
    {
        _Logger.BEGIN( A_ThisFunc )
        this.isPaused  	:= false
        this.resumeTime := A_Now

        timeDiff 		:= A_Now
        timeDiff        -=  this.pausedTime, Seconds

        remainingCount := this.dueTimes.Count() ;- this.exeCount


        Loop, % remainingCount
        {
            dueTime := this.dueTimes[A_Index]
            dueTime += timeDiff, Seconds
            this.dueTimes[A_Index] := dueTime
        }

        this.startTime := A_Now ; so as remaining time progress still remain consistant

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    getRemainingTime()
    {
        _Logger.BEGIN( A_ThisFunc )

        if( this.isPaused ) {
            return this.remainingTime ; stored in a previous call
        }

        if( this.Type == enumTaskType.Reminder or this.Type == enumTaskType.Insomnia ) {
            dueTime := this.dueTimes[this.dueTimes.MaxIndex()]  														; the reminder time left is relative to the last periodic time
        } else {
            dueTime := this.dueTimes[this.dueTimes.MinIndex()]
        }

         ; init
        now := A_Now
        dueTime -= A_Now, Seconds
        this.remainingTime := dueTime
        this.remainingTime := ( this.remainingTime > 0 ) ? this.remainingTime : 0 																	; ensure a positive remainingTime as it still may be displayed on the dashboard

        _Logger.END( A_ThisFunc )

        return  this.remainingTime
    }
    ;------------------------------------------------------------------------------
    getTotalTime()
    {
        if( this.Type == enumTaskType.Reminder ) {
            dueTime := this.dueTimes[this.dueTimes.MaxIndex()]  														; the reminder time left is relative to the last periodic time
        } else {
            dueTime := this.dueTimes[this.dueTimes.MinIndex()]
        }

        totalTime 	:= dueTime
        totalTime 	-= this.startTime, Seconds

        return totalTime
    }
}