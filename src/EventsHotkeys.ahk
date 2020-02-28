;==============================================================================
OnHotkey_CapsLock()
{
    _Logger.BEGIN( A_ThisFunc )
    _App.switchCapsLockState()
    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnHotkey_NumLock()
{
    _Logger.BEGIN( A_ThisFunc )
    _App.switchNumLockState()
    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnHotkey_MyAppVolumeUp( args_ )
{
    _Logger.BEGIN( A_ThisFunc )

    _App.changeMyAppVolume( deltaVol := +5 )

    if( args_.HasKey("sound") ) {
        _App.audio.sounds[args_.sound].play()
    }

    if( args_.HasKey("macro") ) {
        Send % args_.macro
    }
    _Logger.END( A_ThisFunc, "volume", _App.audio.volume )
}
;==============================================================================
OnHotkey_MyAppVolumeDown( args_ )
{
    _Logger.BEGIN( A_ThisFunc )
    _App.changeMyAppVolume( deltaVol := -5 )

    if( args_.HasKey("sound") ) {
        _App.audio.sounds[args_.sound].play()
    }

    if( args_.HasKey("macro") ) {
        Send % args_.macro
    }
    _Logger.END( A_ThisFunc, "volume", _App.audio.volume  )
}
;==============================================================================
OnHotkey_ActiveAppVolumeUp( args_ )
{
    _Logger.BEGIN( A_ThisFunc )
    _App.changeActiveAppVolume( deltaVol := +5 )

    if( args_.HasKey("sound") ) {
        _App.audio.sounds[args_.sound].play()
    }

    if( args_.HasKey("macro") ) {
        Send % args_.macro
    }
    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnHotkey_ActiveAppVolumeDown( args_ )
{
    _Logger.BEGIN( A_ThisFunc )
    _App.changeActiveAppVolume( deltaVol := -5)

    if( args_.HasKey("sound") ) {
        _App.audio.sounds[args_.sound].play()
    }

    if( args_.HasKey("macro") ) {
        Send % args_.macro
    }
    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnHotkey_MasterVolumeUp( args_ )
{
    _Logger.BEGIN( A_ThisFunc , "masterVolume", _App.audio.masterVolume)
    _App.changeMasterVolume( deltaVol := +5 )

    if( args_.HasKey("sound") ) {
        _App.audio.sounds[args_.sound].play()
    }

    if( args_.HasKey("macro") ) {
        Send % args_.macro
    }
    _Logger.END( A_ThisFunc, "currMasterVol", currMasterVol )
}
;==============================================================================
OnHotkey_MasterVolumeDown( args_ )
{
    _Logger.BEGIN( A_ThisFunc )
    _App.changeMasterVolume( deltaVol := -5 )

    if( args_.HasKey("sound") ) {
        _App.audio.sounds[args_.sound].play()
    }
    if( args_.HasKey("macro") ) {
        Send % args_.macro
    }
    _Logger.END( A_ThisFunc, "masterVol", currMasterVol )
}
;==============================================================================
OnHotkey_AlwaysOnTopEnable()
{
    _Logger.BEGIN( A_ThisFunc )
    _App.setActiveWindowAlwaysOnTopState( state := true)
    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnHotkey_AlwaysOnTopDisable()
{
    _Logger.BEGIN( A_ThisFunc )
     _App.setActiveWindowAlwaysOnTopState( state := false)
    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnHotkey_Esc()
{
    _Logger.BEGIN( A_ThisFunc )
    _App.audio.stopPlayingSounds()
    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnHotkey_Insert()
{
    _Logger.BEGIN( A_ThisFunc )

    if ( _keyboard.insToggled ) {
        _App.audio.sounds.InsertOn.play()
    } else {
        _App.audio.sounds.InsertOff.play()
    }

    _keyboard.insToggled  := ! _keyboard.insToggled
    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnHotkey_AppQuit()
{
    _Logger.BEGIN( A_ThisFunc )

    _Logger.END( A_ThisFunc )

    ExitApp ; seccess
}
;==============================================================================
OnHotkey_MacroSound( args_ )
{
    _Logger.BEGIN( A_ThisFunc )

    if( args_.HasKey("macro") ) {
        Send % args_.macro
    }

    if( args_.HasKey("sound") ) {
        _App.audio.sounds[args_.sound].play()
    }
    
    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnHotkey_Dashboard() {
    _App.showTaskMan()
}
;==============================================================================
