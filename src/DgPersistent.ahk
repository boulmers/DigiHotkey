/*
; BEGIN EXAMPLE
#include ..\lib\json.ahk
#include DgObject.ahk
#Include Tools.ahk

subMain:
    global obj := new DgPersistent()
    global obj2 := new DgPersistent()

    obj.fromFile("..\config\US_Kb.json")
    obj.toFile( "..\test\Test.json")
    obj.toRegistry( "HKEY_CURRENT_USER\SOFTWARE\DigiKey", "obj")
    obj2.fromRegistry( "HKEY_CURRENT_USER\SOFTWARE\DigiKey", "obj")
    Sleep, 1000
return
; END EXAMPLE
*/

class DgPersistent extends DgObject
{
    fromRegistry( keyName_, valueName_, mergeData_ := false)
    {
        _Logger.BEGIN( A_ThisFunc)

        RegRead, jsonContent, % keyName_, % valueName_

        if( jsonContent ) {
            data := JSON.Load( jsonContent )
            if( mergeData_) { ; add inexistant members ie key/value pairs
                objectMerge( this, data)
            } else {
                objectCopy( this, data)
            }
        }

         _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------------
    toRegistry( keyName_ , valueName_ )
    {
        _Logger.BEGIN( A_ThisFunc)

        jsonContent := JSON.Dump( this )
        RegWrite, REG_SZ, % keyName_, % valueName_,      % jsonContent

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------------
    fromJsonFile( jsonFile_, mergeData_ := false )
    {
        _Logger.BEGIN( A_ThisFunc)

        FileRead, jsonContent, % jsonFile_

        if( jsonContent ) {
            data := JSON.Load( jsonContent )
            if( mergeData_) { ; add inexistant members ie key/value pairs
                objectMerge( this, data)
            } else {
                objectCopy( this, data)
            }
        } else {
            _Logger.ERROR( A_ThisFunc , "Failed to load config file ", audioLibFile_ )
            return
        }
        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------------
    toJsonFile( jsonFile_ )
    {
        _Logger.BEGIN( A_ThisFunc)

        if( FileExist(jsonFile_)) {
            FileSetAttrib, -R, % jsonFile_
            FileDelete, % jsonFile_
        }

        jsonContent := JSON.Dump(this, replacer:="", space:= "`t" )
        FileAppend, % jsonContent, % jsonFile_

        _Logger.END( A_ThisFunc)
    }

}



