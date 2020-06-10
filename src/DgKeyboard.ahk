
; ahk : standard AutoHotkey hotkey format, eg: ~>!A
; rhk : RHotkey class instance: RHotkey is a class encapsulation the AutoHotkey "Hotkey" command
; dhk : DigiHotkey hotkey formay : designed for easy reading and configuaration with config file

class DgKeyboard extends DgPersistent
{
    __New()
    {

        this.keys    				:= {}
        this.modifierKeys			:= ["SHIFT","LSHIFT","RSHIFT","CONTROL","LCONTROL","RCONTROL","ALT","LALT","RALT","LWIN","RWIN"]
        this.mandatoryProperties   	:= ["Enabled", "passThrough","Handler","DigiHotkeys"]
        this.actionGroups   		:= {}

        this.capsLockBehaviour  	:= enumLockBehaviour.Free
        this.numLockBehaviour   	:= enumLockBehaviour.Free

        this.insKeyEnabled			:= true

        this.insToggled     		:= true
        this.layoutConfigFile		:= PathCombine( A_WorkingDir, "..\config\Keyborad_US.json"  )
        this.actionsConfigFile		:= PathCombine( A_WorkingDir, "..\config\Actions.json"    )
        this.hotstringsConfigFile	:= PathCombine( A_WorkingDir, "..\config\HotStrings.json" )
    }
    ;------------------------------------------------------------------------------
    init()
    {
        this.loadLayout()
        this.loadActions()
        this.loadHotstrings( )

        this.applyConfig()
        this.setupHotkeys()
        this.setupHotstrings()
    }
    ;------------------------------------------------------------------------------
    getCapsLockState()
    {
        _Logger.BEGIN(  A_ThisFunc )

        return GetKeyState( "CapsLock", "T" )

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    getNumLockState()
    {
        _Logger.BEGIN(  A_ThisFunc )

        return GetKeyState("NumLock", "T")

        _Logger.END(  A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    insKeySetEnabled( state_ )
    {
        _Logger.BEGIN( A_ThisFunc )

        this.insKeyEnabled := state_


        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    setCapsLockBehaviour( enLockBehavior )
    {
        _Logger.BEGIN( A_ThisFunc)

        this.capsLockBehaviour := enLockBehavior

        if(  enLockBehavior == enumLockBehaviour.AlwaysOn) {

            SetCapsLockState, AlwaysOn

        } else if(  enLockBehavior == enumLockBehaviour.AlwaysOff ) {

            SetCapsLockState, AlwaysOff

        } else if( enLockBehavior == enumLockBehaviour.Free) {

            SetCapsLockState, Off
        }

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------------
    getCapsLockDashboardState()
    {
        if( this.capsLockBehaviour == enumLockBehaviour.AlwaysOn) {

            return _App.ui.lang.dlgAlwaysOn

        } else if( this.capsLockBehaviour == enumLockBehaviour.AlwaysOff) {

            return _App.ui.lang.dlgAlwaysOff

        } else {

            return this.getCapsLockState() ? _App.ui.lang.dlgOn : _App.ui.lang.dlgOff
        }
    }
    ;------------------------------------------------------------------------------
    getNumLockDashboardState()
    {
        if( this.numLockBehaviour == enumLockBehaviour.AlwaysOn ) {

            return _App.ui.lang.dlgAlwaysOn

        } else if( this.numLockBehaviour == enumLockBehaviour.AlwaysOff) {

            return _App.ui.lang.dlgAlwaysOff

        } else {

            return this.getNumLockState() ? _App.ui.lang.dlgOn : _App.ui.lang.dlgOff
        }
    }
    ;------------------------------------------------------------------------------
    setNumLockBehaviour( enLockBehavior )
    {
        _Logger.BEGIN(  A_ThisFunc ,"enLockBehavior", enLockBehavior)

        this.numLockBehaviour := enLockBehavior

        if( enLockBehavior == enumLockBehaviour.AlwaysOn) {

            SetNumLockState, AlwaysOn

        } else if( enLockBehavior == enumLockBehaviour.AlwaysOff ) {

            SetNumLockState, AlwaysOff

        } else if( enLockBehavior == enumLockBehaviour.Free) {

            SetNumLockState, On 																						; todo : replace with default app parametrable behaviour or saved from last session
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    getKeyboardLayout()
    {
        SetFormat, Integer, H ; todo : code review
        WinGet, WinID,, A
        ThreadID		:= DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
        InputLocaleID	:= DllCall("getKeyboardLayout", "UInt", ThreadID, "UInt")										; Return For US English, the ID will be 0x4090409. For others see Language Codes.
        return InputLocaleID
    }
    ;------------------------------------------------------------------------------
    loadLayout(  )
    {
        _Logger.BEGIN( A_ThisFunc , "layoutConfigFile", this.layoutConfigFile )

        if( FileExist( this.layoutConfigFile ) ) {

            FileRead, jsonContent, % this.layoutConfigFile
            this.keys := JSON.Load( jsonContent )

            for i, key in this.keys {
                key.VK  := HexToDec( key.VK )
            }

        } else {

            _Logger.ERROR( A_ThisFunc, "File : " jsonFile_, " does not exist!")
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    loadActions()
    {
         _Logger.BEGIN( A_ThisFunc , "actionsConfigFile", this.actionsConfigFile )

        FileRead, jsonContent, % this.actionsConfigFile

        if( jsonContent  ) {

            actions := JSON.Load( jsonContent )

            if( ! IsObject(actions)) {
                _Logger.ERROR(A_ThisFunc, "File : " this.actionsConfigFile, " Invalid Hotkey file format!")
            }

            for _, action in actions {
                if( action.Enabled)	{
                    ; some lightweight validation
                    for i, property in this.mandatoryProperties {
                        if( ! action.HasKey( property ) )  {
                            _Logger.ERROR(A_ThisFunc,"action :" action.description " is missing " property " property!")
                        }
                    }

                    for _, digiHotkey in action.digiHotkeys {
                        for __, keyName in digiHotkey  {
                            if( !this.keys.HasKey( keyName ) ) {
                                _Logger.ERROR( A_ThisFunc,"key  " keyName, " is not supported!")
                            }
                        }
                    }

                    ; provide a default groupName to actions that does not belong to a particular groupName
                    if( ! action.groupName ) {
                        action.groupName := "Default"
                    }

                    ; add this action to action groupName and enable it for ui menu item check
                    actionGroup := this.actionGroups[action.groupName]

                    if( ! actionGroup ) {
                        actionGroup := new DgActionGroup( action.groupName )
                        this.actionGroups[action.groupName] := actionGroup
                    }
                    action.Delete( "groupName") ; now that it's moved to the group, remove groupe name property
                    actionGroup.actions.Push( action )
                }
            }
        } else {
            ; todo: fine grain exceptions later (perhaps never)
            _Logger.ERROR(A_ThisFunc," cannot read file : " . this.actionsConfigFile )
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    setupHotkeys()
    {
        _Logger.BEGIN( A_ThisFunc )

        for _, actionGroup in this.actionGroups {
            if( actionGroup.enabled ) {  ; perviously  loaded enabled state in this.applyConfig() => don't setup perviously disabled action groups
                for __, action in actionGroup.actions {
                    passThru 	:= action.passThrough ? "~" : ""
                    for i, digiHotkey in action.digiHotkeys {
                        ahk := this.getAutoHotkey( digiHotkey )
                        ahk := passThru . ahk

                        if( ahk != "~" && ahk != "" ) {

                            args := {}

                            if( action.macro ) {
                                args.macro := action.macro
                            }

                            if( action.sound ) {
                                args.sound := action.sound
                            }

                            if( args.Count() > 0) {
                                target := Func( action.Handler ).Bind( args )
                            }
                            else {
                                target := Func( action.Handler )
                            }
                            /*
                            Window	- *OPTIONAL* The window the hotkey should be related to
	                        Type	- *OPTIONAL* What context the hotkey has to the window (Active, Exist, NotActive, NotExist)
                            */

                            window := action.Window ? "ahk_class " . action.window : ""
                            ;window := action.Window
                            type   := action.Condition ? action.Condition : "Active"

                            digiHotkey.rhk := new RHotkey( ahk, target, window, type ) ;% autoHotkey, % callback, UseErrorLevel
                        }
                    }
                }
            }
        }
        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    applyConfig()
    {
        ; propagate enabled/disabled to keyboard.actiongroups from config file

        for name , configActionGroup  in _App.config.actionGroups {

            actionGroup := this.actionGroups[ name ]

            if( actionGroup ) {
                actionGroup.enabled := configActionGroup.enabled
            }
        }

        this.setCapsLockBehaviour( _App.config.capsLockBehaviour )
        this.setNumLockBehaviour(  _App.config.numLockBehaviour )
    }
    ;------------------------------------------------------------------------------
    loadHotstrings(  )
    {
         _Logger.BEGIN( A_ThisFunc , "hotstringsConfigFile", this.hotstringsConfigFile )

        FileRead, jsonContent, % this.hotstringsConfigFile

        if( jsonContent  ) {
            this.digiHotstrings := JSON.Load( jsonContent )

            ; some primitive Validation
            if( ! IsObject(this.digiHotstrings)) {
                _Logger.ERROR(A_ThisFunc,"File : " . this.hotstringsConfigFile, " Invalid Hotkey file format !")
            }

        } else {
            _Logger.ERROR(A_ThisFunc," cannot read file : " . this.hotstringsConfigFile ) ; todo: fine grain exceptions later
        }

        _Logger.END( A_ThisFunc )
    }
    ;------------------------------------------------------------------------------
    setupHotstrings()												; ahs = AutoHotstring , dhs = digiHotstring
    {
         for _, dhs in this.digiHotstrings {

            if( dhs.enabled) {
                
                modifiers := ""

                if( ! dhs.requireEndingChar ) {
                    modifiers .= "*"
                }

                if( ! dhs.requireWholeWord ) {
                    modifiers .= "?"
                }

                if(  dhs.caseSensitive ) {  ;dhs.hasKey( "caseSensitive") &&
                    modifiers .= "c"
                }

                ahs := ":" . modifiers . ":" . dhs.hotString

                Hotstring( ahs , dhs.replacement )
            }
        }
    }
    ;------------------------------------------------------------------------------
    getAutoHotkey( dhk_ ) ; AHK Hotkey syntax
    {
        _Logger.BEGIN( A_ThisFunc ,"dhk_", dhk_)

        n := dhk_.Length()

        for i, keyName in dhk_ {
            isModifer := IndexOf( this.modifierKeys, keyName )
            key 	  := this.keys[keyName]

            if( isModifer > 0 ) {
                ahk .=  key.AHK
            } else {
                ahk .=  key.AHK  . ( (i < n) ? " & " : "" )
            }
        }

        _Logger.END( A_ThisFunc, "ahk", ahk )

        return ahk
    }
    ;------------------------------------------------------------------------------
    toggleHotkeyActionGroup( groupName_ )
    {
        _Logger.BEGIN( A_ThisFunc  )

        actionGroup := this.actionGroups[groupName_]

        if( actionGroup ) {

            actionGroup.enabled := ! actionGroup.enabled

            for _, action in actionGroup.actions {

                    for __, digiHotkey in action.digiHotkeys {

                        digiHotkey.rhk.Toggle()
                    }
            }
        }

        _Logger.END( A_ThisFunc )

        return actionGroup.enabled
    }
    ;------------------------------------------------------------------------------

}
