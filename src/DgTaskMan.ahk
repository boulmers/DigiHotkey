
class DgTaskMan extends DgObject
{
    __New( checkPeriodSec_ := 15)
    {
        _Logger.BEGIN( A_ThisFunc )

        this.checkPeriodSec := checkPeriodSec_
        this.periodTick 	:= 1000*checkPeriodSec_
        this.tasks     		:= {}
        this.timer 			:= new DgSysTimer()

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    start()
    {
        _Logger.BEGIN( A_ThisFunc)

        callback := this.check.Bind(this) ; Binds this to the check() function call so that `this` can have the correct context on the callback

        this.timer.start( callback, this.periodTick)

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    stop()
    {
        _Logger.BEGIN(A_ThisFunc)

        this.timer.stop()

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    getTaskByName( name_ )
    {
        _Logger.BEGIN(A_ThisFunc)

        return this.tasks[name_]

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    addTask( task_ ) ; Code repetition for extension
    {
        _Logger.BEGIN( A_ThisFunc)

        if( this.tasks[task_.name] ) {
            _Logger.ERROR( A_ThisFunc, "task Already exists")
            return ""
        } else {

            this.tasks[task_.name] := task_
        }

        cnt := this.tasks.Count()

        if( cnt > 0 ) {
            this.start()
        }

        _Logger.END( A_ThisFunc ,"this.tasks.Count", cnt)
    }
    ;------------------------------------------------------------------------------
    removeTask( task_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        deletedTask := this.tasks.Delete( task_.name )

        _Logger.END( A_ThisFunc )

        return deletedTask
    }
    ;------------------------------------------------------------------------------
    check()
    {
        _Logger.BEGIN( A_ThisFunc)

        Critical

        if( this.tasks.Count() > 0 ) {
            for name, task in this.tasks {
                if( ! task.isPaused ) {

                    if( task.isDue() ) {
                        task.execute()
                        if( task.isDone() ) {
                            _App.removeTask( task ) ; todo : UGLY , refacor later to avoid _App method call here
                        }
                    }
                }
            }
        } else {
            this.stop()
        }

        _App.ui.updateTasksProgress()

        Critical, Off

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    getReminderTask() ;   todo : ugly => rewrite it later
    {
        _Logger.BEGIN( A_ThisFunc)

        for name, task in this.tasks {
            if( task.type == enumTaskType.Reminder ) {
                return task
            }
        }

        _Logger.END( A_ThisFunc )

        return ""
    }
    ;------------------------------------------------------------------------------
    getInsomniaTask()
    {
        _Logger.BEGIN( A_ThisFunc)

        for name, task in this.tasks {
            if( task.type == enumTaskType.Insomnia) {
                return task
            }
        }

        _Logger.END( A_ThisFunc )

        return ""
    }
}
