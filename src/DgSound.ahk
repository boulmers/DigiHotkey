class DgSound extends DgObject
{
    __New( name_ , relativeFileName_ := "")
    {
        _Logger.BEGIN( A_ThisFunc , "name_", name_)

        this.name               := name_
        this.relativeFileName   := relativeFileName_
        this.fileName           := ""
        this.hStream            := 0

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    loadStream()
    {
        _Logger.BEGIN( A_ThisFunc )

        this.fileName :=  PathCombine( A_WorkingDir, this.relativeFileName )


        attrib :=  FileExist( this.fileName )
        if ( attrib == "D" or attrib == "") {
                _Logger.WARN( A_ThisFunc, "File does not exist",  "name", this.name , "fileName", this.fileName )
                ret := 0
        } else {
            /*    http://www.un4seen.com/doc/#bass/BASS_StreamCreateFile.html
            HSTREAM BASS_StreamCreateFile(
                BOOL mem,
                void *file,
                QWORD offset,
                QWORD length,
                DWORD flags
            );
            */
            file    := this.fileName
            mem     := 0
            offset  := 0
            length  := 0
            flags   := (A_IsUnicode ? 0x80000000 : 0x40000)

            this.hStream := DllCall("BASS\BASS_StreamCreateFile", "UInt", mem, "UInt", &file, "UInt64", offset, "UInt64", length , "UInt", flags )

            if( ! this.hStream ) {
                errorMessage := _App.audio.getErrorMessage()
                _Logger.ERROR( A_ThisFunc,"Failed to create a stream from file", this.fileName, "Error", errorMessage )
                ret := 0
            } else {
                ret := 1
            }
        }


        _Logger.END( A_ThisFunc , "hStream", this.hStream, "ret", ret )
    }
    ;------------------------------------------------------------------------------
    freeStream()
    {
        _Logger.BEGIN( A_ThisFunc , "name", this.name)
        /* http://www.un4seen.com/doc/#bass/BASS_StreamFree.html
        BOOL BASS_StreamFree(
            HSTREAM handle
        );
        */
        if( this.hStream ) {
            ret := DllCall("BASS\BASS_StreamFree", "UInt",  this.hStream)
        } else {
            _Logger.WARN( A_ThisFunc, "hStream", this.hStream, "fileName", this.fileName)
            ret := -1
        }

        _Logger.END( A_ThisFunc , "ret", ret)
        return ret
    }
    ;------------------------------------------------------------------------------
    play()
    {
        _Logger.BEGIN( A_ThisFunc , "name", this.name)
        /* http://www.un4seen.com/doc/#bass/BASS_ChannelPlay.html
        BOOL BASS_ChannelPlay(
            DWORD handle,
            BOOL restart
        );
        */
        if ( this.hStream ) {
            ret  := DllCall("BASS\BASS_ChannelPlay", "UInt", this.hStream, "Int", restart := 1 )

            if( !ret ) {
                errorMessage := _App.audio.getErrorMessage()
                _Logger.ERROR( A_ThisFunc, "Failed to play stream","name", this.name,"fileName", this.fileName, "Error", errorMessage )
                ret := -1
            }
        }
        else {
            _Logger.WARN( A_ThisFunc, "name", this.name ,"hStream",this.hStream,"fileName", this.fileName)
            ret := -1
        }

        _Logger.END( A_ThisFunc , "ret", ret)

        return ret

    }
    ;------------------------------------------------------------------------------
    stop()
    {
        _Logger.BEGIN( A_ThisFunc , "name", this.name)
        /* http://www.un4seen.com/doc/#bass/BASS_ChannelStop.html
        BOOL BASS_ChannelStop(
            DWORD handle
        );
        */
        if ( this.hStream ) {
            if( this.isPlaying() ) {
                 ret := DllCall("BASS\BASS_ChannelStop", "UInt", this.hStream)
                if ( !ret ) {
                    errorMessage :=_App.audio.getErrorMessage()
                    _Logger.ERROR( A_ThisFunc,"Failed to stop stream",  "name", this.name  ,"fileName", this.fileName, "Error", errorMessage )
                    ret := -1
                }
            } else {
                ret := 0
            }
        } else {
            _Logger.WARN( A_ThisFunc, "null Stream ",  "name", this.name ,"hStream", this.hStream,"fileName", this.fileName)
            ret := -1
        }

        _Logger.END( A_ThisFunc , "ret", ret)

        return ret
    }
    ;------------------------------------------------------------------------------
    isPlaying()
    {
        _Logger.BEGIN( A_ThisFunc , "name", this.name)
        /* http://www.un4seen.com/doc/#bass/BASS_ChannelIsActive.html
        DWORD BASS_ChannelIsActive(
            DWORD handle
        );

         BASS_ACTIVE_STOPPED := 0 ;
         BASS_ACTIVE_PLAYING := 1 ;
         BASS_ACTIVE_STALLED := 2 ;
         BASS_ACTIVE_PAUSED  := 3 ;
         */
        if (this.hStream ) {
            ret := DllCall("BASS\BASS_ChannelIsActive", UInt, this.hStream)
        }

        _Logger.END( A_ThisFunc , "ret", ret)

        return ret
    }

}
;EOF