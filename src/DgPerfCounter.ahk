    class DgPerfCounter
    {
        __New()
        {
            this.counterBefore  := 0
            this.counterAfter   := 0
            this.frequency      := 0
            this.timeMS         := 0
            DllCall( "QueryPerformanceFrequency", "Int64*", frequency )
            this.frequency := frequency
        }
        ;------------------------------------------------------------------------------
        start()
        {
            SetBatchLines -1 ;to never sleep (i.e. have the script run at maximum speed).

            DllCall( "QueryPerformanceCounter", "Int64*", counter )
            this.counterBefore := counter
        }
        ;------------------------------------------------------------------------------
        stop() ; final time check
        {
            SetBatchLines 10ms ;  return to default script speed

            DllCall("QueryPerformanceCounter", "Int64*", counter)
            this.counterAfter := counter

            this.timeMS       := 1000 * (this.counterAfter  - this.counterBefore) / this.frequency

            return this.timeMS
        }
        ;------------------------------------------------------------------------------
        check() ; check at certain time without affecting script speed ( SetBatchLines )
        {
            DllCall("QueryPerformanceCounter", "Int64*", counter)
            this.counterAfter   := counter

            this.timeMS         :=  1000 * (this.counterAfter  - this.counterBefore) / this.frequency
            this.counterBefore  := this.counterAfter

            return this.timeMS
        }
    }



