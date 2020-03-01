;==============================================================================
class DgObject
{
    ;------------------------------------------------------------------------------
    __Get( key ) ; protect against wrong key access for debug, until release
    {
        if( key != "IsArray" ) {
            _Logger.ERROR( this.__Class, key " : key not found")
        }

    }
    ;------------------------------------------------------------------------------
    __Call( fun ) ; protect against wrong method call for debug, until release
    {
        if( fun == "_NewEnum")
            return ObjNewEnum(this)

        if( fun != "HasKey")  { ; builtin function
            _Logger.ERROR( this.__Class, fun " : function not found")
        }
    }
}
;==============================================================================
ObjectCopy( dest , source) ; copy only common members ( a form of Intersection)
{
    if( !IsObject(dest) || !IsObject(source) ) {
        return false
    }

    for sourceKey, sourceVal in source {
        if( dest.HasKey(sourceKey) ) {
            destVal := dest[sourceKey]
            if( isObject(destVal) && isObject(sourceVal) )   { ; deep copy
                ObjectCopy( destVal, sourceVal )
            } else {
                dest[sourceKey] := sourceVal
            }
        }
    }
}
;==============================================================================
ObjectMerge(dest, source)
{
    if( !isObject(dest) || !isObject(source) ) {
        return false
    }

    for sourceKey, sourceVal in source {
        ObjRawSet(dest, sourceKey, sourceVal)
    }

    if( isObject(source.base) ) {  ; base merge
        if( !isObject(dest.base) )
            dest.base := []
        for sourceKey, sourceVal in source.base
            ObjRawSet(dest.base, sourceKey, sourceVal)
    }

    return true
}