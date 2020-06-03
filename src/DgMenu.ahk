; BEGIN EXAMPLE
 /*
    #Persistent
    #SingleInstance

    #include %A_ScriptDir%\..\lib\json.ahk
    #include %A_ScriptDir%\..\src\DgObject.ahk
    #include %A_ScriptDir%\..\src\DgLogger.ahk
    #Include  %A_ScriptDir%\..\src\Tools.ahk

    SetWorkingDir % A_ScriptDir

    global _Logger      := new DgLogger( A_WorkingDir . "\DgMenu.log")

    iconFile            := A_WorkingDir . "\DigiHotkey.ICO"

    separator           := new DgMenu(  { name: "-" })
    fileNewProjectMenu  := new DgMenu(  { name: "fileNewProjectMenu",  caption: "New Project",    func: Func("OnMenu_File_New_Project_Click").Bind( 77) , checked: true} )
    fileNewSolutionMenu := new DgMenu(  { name: "fileNewSolutionMenu", caption: "New Solution",    func: Func("OnMenu_File_New_Solution_Click") } )

    fileNewMenu         := new DgMenu(  { name: "fileNewMenu",         caption: "New",    children:[ fileNewProjectMenu, separator, fileNewSolutionMenu]  } )

    fileSaveMenu        := new DgMenu(  { name: "fileSaveMenu",  caption: "Save",   func: Func("OnMenu_File_Save_Click") } )
    fileMenu            := new DgMenu(  { name: "fileMenu",      caption: "File",   children:[ fileNewMenu, separator, fileSaveMenu] } )

    editCopyMenu        := new DgMenu(  { name: "editCopyMenu", caption: "Copy",    func: Func("OnMenu_Edit_Copy_Click") } )
    editPastMenu        := new DgMenu(  { name: "editPastMenu", caption: "Past",    func: Func("OnMenu_Edit_Past_Click") } )
    editSaveMenu        := new DgMenu(  { name: "editSaveMenu", caption: "Save",    func: Func("OnMenu_Edit_Save") } )
    editMenu            := new DgMenu(  { name: "editMenu",     caption: "Edit",    children: [ editCopyMenu, separator, editPastMenu, editSaveMenu ] } )

    settingsMenu        := new DgMenu(  { name: "settings",  caption: "Settings",    func: Func("OnMenu_Settings") } )
    trayMenu            := new DgMenu(  { name: "Tray", children: [ fileMenu, editMenu, settingsMenu ], iconFile: iconFile } )


    trayMenu.build()

    trayMenu.show()

    ;trayMenu.setIcon( "FR.ICO" )

    fileMenu.setIcon( "FR.ICO" )
    fileNewProjectMenu.setIcon( "FR.ICO" )

    trayMenu.removeStandardMenus()
    trayMenu.setDefaultClickCount( 1 ) ; one click on the tray menu to fire default menu event handler (callback)
    settingsMenu.setDefault()


    return

    !z::
        mainMenu.show()
    return

    !c::
        fileSaveMenu.setChecked( true )
    return

    !d::
        editSaveMenu.toggleChecked()
    return

    !Esc::
        ExitApp
    return

    ;------------------------------------------------------------------------------
    OnMenu_File_New_Project_Click( param )
    {
        MsgBox,,, OnMenu_File_New_Project_Click| bound param: %param%
    }
    ;------------------------------------------------------------------------------
    OnMenu_File_New_Solution_Click()
    {
        MsgBox,,, OnMenu_File_New_Solution_Click
    }
    ;------------------------------------------------------------------------------
    OnMenu_File_Save_Click()
    {
        MsgBox,,, OnMenu_File_Save_Click
    }
    ;------------------------------------------------------------------------------
    OnMenu_Edit_Copy_Click()
    {
        MsgBox,,, OnMenu_Edit_Copy_Click
    }
    ;------------------------------------------------------------------------------
    OnMenu_Edit_Past_Click()
    {
        MsgBox,,, OnMenu_Edit_Past_Click
    }
    ;------------------------------------------------------------------------------
    OnMenu_Edit_Save()
    {
        MsgBox,,, OnMenu_Edit_Save
    }
    ;------------------------------------------------------------------------------
    OnMenu_Settings()
    {
        MsgBox,,, OnMenu_Settings
    }


; END EXAMPLE
*/
;==============================================================================
;==============================================================================
; NOTES:
; name is mandatory if it's not a final menu ( leaf ) with callback
; to avoid confusion, both name and caption should be supplied
; for Tray menu, root menu name property must be 'Tray'
; one shared separator menu is recommended to be shared across the menu tree ( not mandatory )
; this class wraps a subset of menu commands to keep it simple stupid... extensible as needed
;==============================================================================
class DgMenu  extends DgObject
{

    __New( args_ )
    {
        this.name       := args_.name      ;? args_.name      : ""
        this.caption    := args_.caption   ;? args_.caption   : ""
        this.func   := args_.func  ;? args_.func  : ""
        this.checked    := args_.checked   ? args_.checked : false
        this.enabled    := args_.enabled   ? args_.enabled : true
        this.iconFile   := args_.iconFile  ;? args_.iconFile      : ""
        this.options    := args_.options   ;? args_.options   : ""

        this.isSeparator := ( this.name == "-")
        this.isTray  := ( this.name == "Tray" )

        this.parent     := ""

        this.isBuilt    := false  ;todo: delete, for debug purposes

        this.isMenuItem := true

        if( args_.children ) {

            this.isMenuItem := false
            this.children := args_.children
                     ; todo: check for redendency in build method

            for _, child in this.children {
                child.parent := this
            }

        } else {
            this.children := {}
        }
    }
    ;------------------------------------------------------------------------------
    addItem( child_ )
    {
        if( !this.name ) {

            _Logger.ERROR( A_ThisFunc, "name property is mandatory for a parent menu")
        }

        ; let it be...
        this.isMenuItem := false
        this.children.Push( child_ )
        child_.parent := this
    }
    ;------------------------------------------------------------------------------
    getMenuItemByCaption( caption_ )
    {

        for i , item in this.children {

            if( item.caption == caption_ ) {
                ret := item
            }
        }

        return ret
    }
    ;------------------------------------------------------------------------------
    setChecked( state_ )
    {
        if( this.isMenuItem ) {

            this.checked := state_
            Menu, % this.parent.name, % this.checked ? "Check" : "Uncheck", % this.caption

        } else {
            _Logger.ERROR( A_ThisFunc, "Menu " . this.name " cannot be checked/unchecked!" )
        }
    }
    ;------------------------------------------------------------------------------
    toggleChecked()
    {
        if( this.isMenuItem ) {

            Menu, % this.parent.name, ToggleCheck, % this.caption
            this.checked := ! this.checked

        } else {

            _Logger.ERROR( A_ThisFunc, "Menu " . this.name " cannot be checked/unchecked!" )
        }
    }
    ;------------------------------------------------------------------------------
    setEnabled( state_ )
    {
        if( this.isMenuItem ) {

            this.enabled := state_
            Menu, % this.parent.name, % this.enabled ? "Enable" : "Disable", % this.caption

        } else {
            _Logger.ERROR( A_ThisFunc, "Menu " . this.name " cannot be checked/unchecked!" )
        }
    }
    ;------------------------------------------------------------------------------
    ; must be called after show method except when it is a Tray menu ( in which case, call afrer show method is recommended)
    setIcon( fileName_ := "", iconNumber_ := 1 )
    {

        if( fileName_ ) {
            this.iconFile   := fileName_
        }

        this.iconNumber := iconNumber_

        if( ! myFileExist( this.iconFile)) {
            _Logger.WARN( A_ThisFunc, "icon file does not exists, file name:" . this.iconFile )
            return
        }

        if( this.isTray ) {

            Menu, Tray, Icon, % this.iconFile, % this.iconNumber

        } else if( this.parent && this.caption ) {

            Menu, % this.parent.name, Icon, % this.caption, % this.iconFile, % this.iconNumber
        }
    }
    ;------------------------------------------------------------------------------
    setDefault() ; apply to menu items
    {
        if( this.isMenuItem ) {

            this.enabled := state_
            Menu, % this.parent.name, Default, % this.caption

        } else {
            _Logger.ERROR( A_ThisFunc, "Menu " . this.name " cannot be checked/unchecked!" )
        }
    }
    ;------------------------------------------------------------------------------
    setDefaultClickCount( clickCount ) ; apply to tray menu,  click numbers on the tray menu to fire default menu (if present) event handler
    {
        if( this.isTray ) {
            Menu, Tray, Click, % clickCount
        }
    }
    ;------------------------------------------------------------------------------
    removeStandardMenus()
    {
        Menu, % this.name, NoStandard
    }
    ;------------------------------------------------------------------------------
    show( x :=  "", y := "" )
    {
        if( ! this.isTray ) {

             Menu, % this.name, Show , % x, % y

        } else {

           _Logger.WARN( A_ThisFunc, "Tray menu does not need to be shown, except intentionally wanted to be")
        }

    }
    ;------------------------------------------------------------------------------
    getId() ; for debugging purposes ; todo: delete this fuction
    {
        return this.name ? this.name : this.caption
    }
    ;------------------------------------------------------------------------------
    build() ; reverse recursive walk
    {
        _Logger.BEGIN( A_ThisFunc)
         
        thisId := this.getId()
        partentId := this.parent ? this.parent.getId() : ""

        if( this.isBuilt ) { ; todo : delete this algorithmic debug check
            _Logger.WARN( A_ThisFunc, "Already buit!", "thisId", thisId )
        }

        if( this.children.count() > 0 ) {

            this.isMenuItem := false

            for _, child in this.children {

               if( child.isSeparator ) {

                    Menu, % this.name, Add

               } else {

                    child.build()

                    if( child.children.count() > 0 ) {
                        Menu, % this.name, Add, % child.caption, % ":" child.name
                    }
               }
            }

        } else {

            this.isMenuItem := this.parent && this.parent.name && this.caption && !this.isSeparator

            if( this.isMenuItem ) {

                fn := this.func
                Menu, % this.parent.name, Add, % this.caption, % fn ;, % child.options

                ;_Logger.TRACE( A_ThisFunc, "Menu, " this.parent.name ", Add, " this.caption ", % """ this.func """" )

                this.setChecked( this.checked )

                this.setEnabled( this.enabled )

                if( this.iconFile ) {
                    this.setIcon( this.iconFile )
                }
            }       
        }

        if( this.isTray && this.iconFile ) {
            this.setIcon( this.iconFile )
        }

        this.isBuilt := true

        _Logger.END( A_ThisFunc, "thisId", thisId, "partentId", partentId )
    }
    ;------------------------------------------------------------------------------
}
