
class DgAudio extends DgObject
{
    __New( myPID_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        this.hAudioLib      := ""
        this.errors         := []
        this.myPID       := myPID_

        this.initErrors()
        libFile := PathCombine( A_WorkingDir, ".\bass.dll")
        this.loadLib( libFile )


        this.profiles       := {}
        this.sounds         := {}  ; List<DgSoung>
        this.soundProfile   := enumSoundProfile.Modern
        this.masterVolume   := VA_GetMasterVolume()
        this.volume         := this.getAppVolume( myPID_ )
        this.profilesConfigFile :=  PathCombine( A_WorkingDir, "..\config\Audio.json")

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    __Delete()
    {
        _Logger.BEGIN( A_ThisFunc )

        this.freeStreams()
        this.freeLib()

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    doNoting()
    {
        ; dummy method for call Performance test purpose, can be deleted anytime
    }
    ;------------------------------------------------------------------------------
    init()
    {
        this.loadProfiles()
        this.applyConfig()
    }
    ;------------------------------------------------------------------------------
    applyConfig()
    {
        this.setVolume( _App.PID, _App.config.volume     )
        this.setActiveSoundProfile( _app.config.soundProfile )
    }
    ;------------------------------------------------------------------------------
    ; WARNING : helper function to purge draft audio files. DO NOT CALL until you understand how it works.
    deleteUnusedFiles() 
    {
        
        for key, profile in this.profiles {
            relativeFirstPath :=  PathCombine( A_WorkingDir, profile.Alpha )
            SplitPath, relativeFirstPath , outFileName, outDir, outExtension, outNameNoExt, outDrive
            
            
            Loop %outDir%\*.*
            {
                fileToPurge := A_LoopFileName
                found := false
                fileToPurgePath := PathCombine( outDir, fileToPurge )
                
                for soundName, soundFile in profile {

                    soundFilePath :=  PathCombine( A_WorkingDir, soundFile )
                    
                    if( soundFilePath == fileToPurgePath) 
                    {
                        found := true
                        break
                    }
                }
                
                if(! found) 
                {
                    FileRecycle, % fileToPurgePath
                }
            }
        }

    }
    ;------------------------------------------------------------------------------
    loadStreams()
    {
        _Logger.BEGIN( A_ThisFunc )

        ; key = DgSound, val := object instance
        for key, val in this.sounds {
            if( IsObject( val ) && val.__Class = "DgSound" ) {
                sound := val
                sound.loadStream()
            }
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    freeStreams()
    {
        _Logger.BEGIN( A_ThisFunc )

        for key, val in this {      ; key = DgSound, val := object instance

            if( IsObject( val ) && val.__Class = "DgSound") {
                sound := val
                sound.freeStream()    ; DgSound:freeStream()
            }
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    loadLib( audioLibFile_ )
    {
        _Logger.BEGIN( A_ThisFunc , "audioLibFile_", audioLibFile_ )

        this.hAudioLib := DllCall( "LoadLibrary", "Str", audioLibFile_)

        if (! this.hAudioLib ) {
            _Logger.ERROR( A_ThisFunc , "Failed to start audio library", audioLibFile_ )
            return
        }
        /* http://www.un4seen.com/doc/#bass/BASS_Init.html
        BOOL BASS_Init(
        int device,
        DWORD freq,
        DWORD flags,
        HWND  win,
        GUID *clsid
        );
        */
        device := -1
        freq   := 44100
        flags  := 0
        win    := 0
        clsid  := 0

        ret := DllCall("BASS\BASS_Init", "Int" ,device, "Int", freq, "Int", flags, "UInt", win, "UInt", clsid)

        if( ! ret ) {
            sErr := this.getErrorMessage()
            _Logger.ERROR(A_ThisFunc, "Failed to initialize Audio library", "Error", sErr )
            return
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    freeLib()
    {
        _Logger.BEGIN( A_ThisFunc )
        /* http://www.un4seen.com/doc/#bass/BASS_Free.html
        BOOL BASS_Free();
        */
        DllCall("BASS\BASS_Free")                      ; free resources
        DllCall("FreeLibrary", UInt, hHBassDll)        ; free dll

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    loadProfiles()
    {
        _Logger.BEGIN( A_ThisFunc ,  "profilesConfigFile", this.profilesConfigFile)

        FileRead, jsonContent, % this.profilesConfigFile

        this.profiles       := JSON.Load( jsonContent )

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    ; NOTA : sounds are intentionally dynamic for flexebility, it's up to profile designer to carefully name the sounds( not the audio file obviously) and to respect existing sound name in the source code.
    ;        new sounds can be safely added and then referenced form Hotkey json config file or the source code itself
    setActiveSoundProfile( profileName_ )
    {
        _Logger.BEGIN( A_ThisFunc , profileName_, "profileName_")

        this.soundProfile    := profileName_

        if( this.profiles.HasKey( profileName_ ) ) {
            profile := this.profiles[ profileName_ ]

            for soundName, sound in this.sounds { ; not necessary but for lack of a deep knowldge of AHK GC( ref counting)
                sound.freeStream()
                sound := ""                         ; seems to be the correct way to free an object, recommended by Lexikos
            }

            this.sounds := {}

            for soundName, soundFile in profile {
                sound := new DgSound( soundName , soundFile )
                sound.loadStream()

                this.sounds[soundName] := sound
            }

        }

        this.sounds.Profile.play()

       _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    changeAppVolume( appPID_, deltaVol_ )
    {
        _Logger.BEGIN( A_ThisFunc , "appPID_",  appPID_, "deltaVol_", deltaVol_)

        newVol   := this.getAppVolume( appPID_ ) + deltaVol_
        currVol  := this.setVolume( appPID_, newVol )

        _Logger.END( A_ThisFunc, "newVol", newVol, "currVol", currVol )

        return currVol
    }
    ;------------------------------------------------------------------------------
    getAppVolume( appPID_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        ISAV := GetISimpleAudioVolume( appPID_ )

        _Logger.TRACE( A_ThisFunc, "appPID_", appPID_, "ISAV", ISAV)
        ISimpleAudioVolume_GetMasterVolume( ISAV, level )

        ObjRelease( ISAV )

        _Logger.END( A_ThisFunc)

        return level*100
    }
    ;------------------------------------------------------------------------------
    setVolume( appPID_, vol_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        ISAV    := GetISimpleAudioVolume( appPID_ )
        level   := ( (vol_ > 100) ? 100 : ( (vol_ < 0) ? 0: vol_) ) / 100

        if( this.myPID == appPID_) {
            this.volume := level*100 
        }

        ISimpleAudioVolume_SetMasterVolume( ISAV, level )

        _Logger.TRACE( A_ThisFunc, "appPID_", appPID_, "ISAV", ISAV, "level", level)
        

        ObjRelease(ISAV)

        _Logger.END( A_ThisFunc, " 100*level", 100*level )

        return  level*100
    }
    ;------------------------------------------------------------------------------
    changeMasterVolume( deltaVol_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        newMasterVol := VA_GetMasterVolume() + deltaVol_
        VA_SetMasterVolume( newMasterVol )

        this.masterVolume := VA_GetMasterVolume()

        _Logger.END( A_ThisFunc )

        return this.masterVolume
    }
    ;------------------------------------------------------------------------------
    stopPlayingSounds()
    {
       _Logger.BEGIN( A_ThisFunc )

       this.sounds.Timer.stop()
       this.sounds.Reminder.stop()
       this.sounds.Esc.play()

       _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------------
    getErrorMessage()
    {
        _Logger.BEGIN( A_ThisFunc )
        /* http://www.un4seen.com/doc/#bass/BASS_ErrorGetCode.html
        int BASS_ErrorGetCode();
        */
        errorIndex := DllCall("BASS\BASS_ErrorGetCode", Int)
        if( errorIndex == -1) {
            return "some other mystery problem " ; BASS_ERROR_UNKNOWN
        }

        min := this.errors.MinIndex()
        max := this.errors.MaxIndex()

        if( errorIndex >= min  && errorIndex <= max  ) {
            message := this.errors[errorIndex]
        } else {
            message := " Unknown error!"
        }

        _Logger.END( A_ThisFunc , "return message", message)

        return message
    }
    ;------------------------------------------------------------------------------
    initErrors()
    {

        _Logger.BEGIN( A_ThisFunc )

        this.errors[0]  := " all is OK"                                        ; 0  = BASS_OK
        this.errors[1]  := " memory error"                                     ; 1  = BASS_ERROR_MEM
        this.errors[2]  := " can't open the file"                              ; 2  = BASS_ERROR_FILEOPEN
        this.errors[3]  := " can't find a free/valid driver"                   ; 3  = BASS_ERROR_DRIVER
        this.errors[4]  := " the sample buffer was lost"                       ; 4  = BASS_ERROR_BUFLOST
        this.errors[5]  := " invalid handle"                                   ; 5  = BASS_ERROR_HANDLE
        this.errors[6]  := " unsupported sample format"                        ; 6  = BASS_ERROR_FORMAT
        this.errors[7]  := " invalid position"                                 ; 7  = BASS_ERROR_POSITION
        this.errors[8]  := " BASS_Init has not been successfully called"       ; 8  = BASS_ERROR_INIT
        this.errors[9]  := " BASS_Start has not been successfully called"      ; 9  = BASS_ERROR_START
        this.errors[10] := " SSL/HTTPS support isn't available"                ; 10 = BASS_ERROR_SSL
        this.errors[14] := " already initialized/paused/whatever"              ; 14 = BASS_ERROR_ALREADY
        this.errors[18] := " can't get a free channel"                         ; 18 = BASS_ERROR_NOCHAN
        this.errors[19] := " an illegal type was specified"                    ; 19 = BASS_ERROR_ILLTYPE
        this.errors[20] := " an illegal parameter was specified"               ; 20 = BASS_ERROR_ILLPARAM
        this.errors[21] := " no 3D support"                                    ; 21 = BASS_ERROR_NO3D
        this.errors[22] := " no EAX support"                                   ; 22 = BASS_ERROR_NOEAX
        this.errors[23] := " illegal device number"                            ; 23 = BASS_ERROR_DEVICE
        this.errors[24] := " not playing"                                      ; 24 = BASS_ERROR_NOPLAY
        this.errors[25] := " illegal sample rate"                              ; 25 = BASS_ERROR_FREQ
        this.errors[27] := " the stream is not a file stream"                  ; 27 = BASS_ERROR_NOTFILE
        this.errors[29] := " no hardware voices available"                     ; 29 = BASS_ERROR_NOHW
        this.errors[31] := " the MOD music has no sequence data"               ; 31 = BASS_ERROR_EMPTY
        this.errors[32] := " no internet connection could be opened"           ; 32 = BASS_ERROR_NONET
        this.errors[33] := " couldn't create the file"                         ; 33 = BASS_ERROR_CREATE
        this.errors[34] := " effects are not available"                        ; 34 = BASS_ERROR_NOFX
        this.errors[37] := " requested data/action is not available"           ; 37 = BASS_ERROR_NOTAVAIL
        this.errors[38] := " the channel is/isn't a 'decoding channel"         ; 38 = BASS_ERROR_DECODE
        this.errors[39] := " a sufficient DirectX version is not installed"    ; 39 = BASS_ERROR_DX
        this.errors[40] := " connection timedout"                              ; 40 = BASS_ERROR_TIMEOUT
        this.errors[41] := " unsupported file format"                          ; 41 = BASS_ERROR_FILEFORM
        this.errors[42] := " unavailable speaker"                              ; 42 = BASS_ERROR_SPEAKER
        this.errors[43] := " invalid BASS version (used by add-ons)"           ; 43 = BASS_ERROR_VERSION
        this.errors[44] := " codec is not available/supported"                 ; 44 = BASS_ERROR_CODEC
        this.errors[45] := " the channel/file has ended"                       ; 45 = BASS_ERROR_ENDED
        this.errors[46] := " the device is busy"                               ; 46 = BASS_ERROR_BUSY

        _Logger.END( A_ThisFunc )
    }
}
