OnMenu_PowerProfileSelect()
{
    _Logger.BEGIN( A_ThisFunc )

    _App.setActivePowerPlan( powerPlanName := A_ThisMenuItem )

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_LanguageSelect() 
{
    _Logger.BEGIN( A_ThisFunc )

    _App.setActiveLanguage( languageName := A_ThisMenuItem)

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_CapsLockAlwaysOn()
{
    _Logger.BEGIN( A_ThisFunc )

    _App.switchCapsLockAlwaysOn()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_CapsLockAlwaysOff()
{
    _Logger.BEGIN( A_ThisFunc )

    _App.switchCapsLockAlwaysOff()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_CapsLockAlert()
{
    _Logger.BEGIN( A_ThisFunc )

    _App.switchCapsLockAlert()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_NumLockAlwaysOn()
{
    _Logger.BEGIN( A_ThisFunc )

    _App.switchNumLockAlwaysOn()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_NumLockAlwaysOff()
{
    _Logger.BEGIN( A_ThisFunc )

    _App.switchNumLockAlwaysOff()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_NumLockAlert()
{
    _Logger.BEGIN( A_ThisFunc )

    _App.switchNumLockAlert()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_InsKeyEnable( )
{
    _Logger.BEGIN( A_ThisFunc )

    _App.InsKeySetEnabled( true )

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_InsKeyDisable( )
{
    _Logger.BEGIN( A_ThisFunc )

    _App.InsKeySetEnabled( false )

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_SoundProfileSelect()
{
    _Logger.BEGIN( A_ThisFunc )

    _App.setActiveSoundProfile( profileName := A_ThisMenuItem )

    _Logger.BEGIN( A_ThisFunc )
}
;==============================================================================
OnMenu_ActionGroupSelect()
{
    _Logger.BEGIN( A_ThisFunc )

    _App.toggleHotkeyActionGroup( groupName := A_ThisMenuItem )

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_TaskMan()
{
    _Logger.BEGIN( A_ThisFunc )
    
    _App.showTaskMan()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_About()
{
    _Logger.BEGIN( A_ThisFunc )
    
    _App.showAboutBox()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_Settings()
{
    _Logger.BEGIN( A_ThisFunc )
    
    _App.showSettings()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_Help()
{
    _Logger.BEGIN( A_ThisFunc )
    
    _App.showHelp()

    _Logger.END( A_ThisFunc )
}
;==============================================================================
OnMenu_Exit()
{
    ExitApp
}
;==============================================================================
OnKeyboardLayoutChange(wParam, lParam, msg, hwnd)
{
     _Logger.WARN( A_ThisFunc , "NOT IMPLEMENTED!!")
}
;==============================================================================
;                  EVENTS 
;==============================================================================
OnExitApp( Reason, ExitCode )
{

    _Logger.BEGIN( A_ThisFunc )

    exitCode := _App.quit()

    _Logger.END( A_ThisFunc )

    return exitCode ; 0 allow exit , 1 prevent exit
}
