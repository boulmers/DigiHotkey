
class DgPowerMan extends DgObject
{
    __New()
    {
        powerCmd := "POWERCFG.EXE /list"
        cmdOutput := StdoutToVar_CreateProcess(powerCmd, sEncoding :="", sDir:="", iExitCode)
        cmdOutput := SubStr( cmdOutput, (Sep:=InStr( cmdOutput,"-`r`n" )+3), StrLen(cmdOutput)-Sep-1 )

        StringReplace, cmdOutput, cmdOutput, % "Power Scheme GUID: " ,, All
        StringSplit, Entries, cmdOutput, `n, `r

        Loop, %Entries0% {
            planEntry := Entries%A_Index%
            planBegin := RegExMatch(planEntry, "\(")
            planEnd   := RegExMatch(planEntry, "\)")
            planName  := Trim( SubStr(planEntry, planBegin + 1, planEnd - planBegin - 1 ) )
            planGuid  := Trim( SubStr(planEntry, 1, planBegin - 3) )
            this[planName] := planGuid
        }
     }
    ;------------------------------------------------------------------------------
    getActivePlanName()
    {
        ;StdoutToVar_CreateProcess(sCmd, sEncoding:="CP0", sDir:="", ByRef nExitCode:=0)
        powerCmd := "POWERCFG.EXE /getactivescheme"
        cmdOutput := StdoutToVar_CreateProcess( powerCmd, "", "", iExitCode )

        planEntry := cmdOutput

        planBegin := RegExMatch(planEntry, "\(")
        planEnd   := RegExMatch(planEntry, "\)") ;- 1 - planBegin
        planName  := Trim( SubStr(planEntry, planBegin + 1, planEnd - planBegin - 1 ) )
        planGuid  := Trim( SubStr(planEntry, 1, planBegin - 3) )

        return planName
    }
    ;------------------------------------------------------------------------------
    setActivePlan( planName_ )
    {
        if ( planGuid := this[planName_] ) {
            powerCmd := "POWERCFG.EXE /setactive " planGuid
            cmdOutput := StdoutToVar_CreateProcess(powerCmd, sEncoding :="", sDir:="", iExitCode)
            pos := InStr( cmdOutput, "Invalid", caseSensitive := false)

            if ( pos > 0 ) {
                return false
            } else {
                this.sActivePlan := planName_
                return true
            }
        } else {
            return false
        }
    }
}

