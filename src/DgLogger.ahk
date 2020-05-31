

isValidFileName( fileName_, isLong=true)  ;https://autohotkey.com/board/topic/70761-validate-filenames/ by rbrtryn
{
    forbiddenChars := isLong ? "[!=|""\\/:*?]" : "[;=+!=|""\]\[\\/']"
    ErrorLevel := RegExMatch( fileName_ , forbiddenChars )
    Return ! ErrorLevel
}
;==============================================================================
class DgLogger
{
    __New( fileName_ := "", recycle_ := true )
    {
        this.logON      := true
        this.logBEGIN   := true
        this.logEND     := true
        this.logTRACE   := true
        this.logCOUNT   := true
        this.logINFO    := true
        this.logWARN    := true
        this.logERROR   := true
        this.logCRITICAL:= true
        this.LogOFF     := true
        this.beepOnError:= true

        this.indentStr     := "`t"
        this.indentCount   := 0
        this.Delimiter     := " , "

        this.errorBipFrequency  := 2000
        this.errorBipDurarionMS := 50

        success := false

        this.counter  := 0

        SplitPath, fileName_ , $file, $dir, $ext, $nameNoExt, $drive

        if( isValidFileName( $file ) ) {
            this.fileName := fileName_

            if ( recycle_ )
            {
                if( myFileExist( this.fileName ) )
                {
                    bakFileLocation  := $dir . "\" . $nameNoExt . ".bak"
                    FileCopy,  %  this.fileName, % bakFileLocation , 1 ; 1 = true = Overwrite
                    FileRecycle, %  this.fileName
                }
            }
        }

        /* MsgBox % fileName_ 
        */
        
        file := FileOpen( this.fileName, "a `r`n")

        if ( ! file ) {
            MsgBox % "Failed to create Logger, File=" fileName_
            return ""
        }

        file.WriteLine(  A_Now . ":" . " Start logging.")

        file.fileClose()

    }
    ;------------------------------------------------------------------------------
    __Delete()
    {
        file := FileOpen( this.fileName, "a `r`n")

        file.WriteLine( A_Now . ":" . " Stop logging.")

        file.fileClose()

    }
     ;------------------------------------------------------------------------------
    LogLine( logType , message, params* )
    {
        logLine :=  A_Now ":" logType " > " message " > "

        for i, param in params {

            if( IsObject(param)) {
                logLine .= JSON.Dump(param) . this.Delimiter ;. "`r`n"
            } else {
                logLine .= param . this.Delimiter ;. "`n"
            }
        }

        file := FileOpen( this.fileName, "a `r`n")
        file.WriteLine( logLine )
        file.fileClose()
    }
    ;------------------------------------------------------------------------------
    BEGIN( message, params* )
    {
        if( this.logBEGIN ) {

            this.indentCount := this.indentCount + 1

            Loop, % this.indentCount {
                indent .=  this.indentStr
            }

            this.LogLine( indent . "begin" , message, params* )
        }
    }
    ;------------------------------------------------------------------------------
    END( message, params* )
    {
        if( this.logEND )  {

            Loop, % this.indentCount {
                indent .= this.indentStr
            }

            this.LogLine( indent . "end  " , message, params* )

            this.indentCount := this.indentCount - 1                                                                    
        }
    }
    ;------------------------------------------------------------------------------
    INFO( message, params* )
    {
        if( this.logINFO ) {

            Loop, % this.indentCount + 1 {
                indent .= this.indentStr
            }

            this.LogLine( indent . "INFO " , message, params* )
        }
    }
    ;------------------------------------------------------------------------------
    COUNT( message, params* ) ; outputs a message and automatic information such as a sequencial number and line number
    {
        if( this.logCOUNT ) {

            Loop, % this.indentCount + 1 {
                indent .= this.indentStr
            }

            this.counter  := this.counter + 1
            this.LogLine( indent . "COUNT " , message . " (" . this.counter . ")" , params* )
        }
    }
    ;------------------------------------------------------------------------------
    TRACE( message, params* )
    {
        if( this.logTRACE ) {

            Loop, % this.indentCount + 1 {
                indent .= this.indentStr
            }

            this.LogLine( indent . "TRACE" , message , params* )
        }
    }
    ;------------------------------------------------------------------------------
    WARN( message, params* )
    {
        if( this.logWARN ) {

            Loop, % this.indentCount + 1 {
                indent .= this.indentStr
            }

            this.LogLine( indent . "WARN " , message, params* )
        }
    }
    ;------------------------------------------------------------------------------
    ERROR( message, params* )
    {
        if( this.logERROR ) {

            Loop, % this.indentCount + 1 {
                indent .= this.indentStr
            }

            this.LogLine( indent  . "ERROR" , message, params* )

            if( this.beepOnError ) {
                SoundBeep, % this.errorBipFrequency, $ this.errorBipDurarionMS
            }
        }
    }
    ;------------------------------------------------------------------------------
    CRITICAL( message, params* )
    {
        if( this.logCRITICAL) {

            Loop, % this.indentCount + 1 {
                indent .= this.indentStr
            }

            this.LogLine( indent .  this.indentStr . "CRITICAL" , message, params* )
        }
    }
    ;------------------------------------------------------------------------------
    OFF( message, params* )
    {
        if( this.LogOFF) {
            this.LogLine( "OFF  " , message, params* )
        }
    }
}
