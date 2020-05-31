
IsAhk64bit()
{
    Return A_PtrSize = 8 ? 1 : 0
}
;==============================================================================
GetTimeFromNow( delaySec )
{
    dueTime := A_Now
    dueTime += % delaySec, Seconds
    return dueTime
}
;==============================================================================
myFileExist( fileName_)
{
    attrib := FileExist( fileName_ )
    if attrib in % "R,A,S,H,N,C,T,X"
        return true
    else
        return false

}
;==============================================================================
IndexOf( hayStack, needle ) ; index of atomic needle in an object/array hayStack
{
    for idx, val in hayStack {
        if (val = needle) {
            return idx
        }
    }

    if( !(IsObject(hayStack)) ) {
        throw Exception("Bad hayStack!", -1, hayStack)
    }

    return 0
}
;==============================================================================
Sort( String, Options:="")
{
    Sort String, %Options%
    return String
}
;==============================================================================
StrLower(String)
{
    StringLower String, String
    return String
}
;==============================================================================
StrUpper(String)
{
    StringUpper String, String
    return String
}
;==============================================================================
GetTaskbarHeight(default := 0)
{
    ABM_GETTASKBARPOS := 0x00000005

    VarSetCapacity( AppBarData , 36, 0 )

    ret :=	DllCall("Shell32\SHAppBarMessage", "UInt", ABM_GETTASKBARPOS, "UInt", &AppBarData )

    if( ret == 1)
    {
        ;cbSize           := NumGet(AppBarData, 0, "UInt")
        ;hWnd             := NumGet(AppBarData, 4, "UInt")
        ;uCallbackMessage := NumGet(AppBarData, 8, "UInt")
        ;uEdge            := NumGet(AppBarData, 12,"UInt")

        rc_left          := NumGet(AppBarData, 16, "Int")
        rc_top           := NumGet(AppBarData, 20, "Int")
        rc_right         := NumGet(AppBarData, 24, "Int")
        rc_bottom        := NumGet(AppBarData, 28, "Int")

        ;lParam           := NumGet(AppBarData, 32, "UInt")

        return ( height := rc_bottom - rc_top )
    }

    return  default
}
;==============================================================================
GetCurrentMonitorIndex()
{
    CoordMode, Mouse, Screen
    MouseGetPos, mx, my
    SysGet, monitorsCount, 80

    Loop %monitorsCount%
    {
        SysGet, monitor, Monitor, %A_Index%
        if (monitorLeft <= mx && mx <= monitorRight && monitorTop <= my && my <= monitorBottom)
        {
            Return A_Index
        }
    }
    Return 1
}
;==============================================================================
CoordXCenterScreen(WidthOfGUI, ScreenNumber)
{
    SysGet, Mon1, Monitor, %ScreenNumber%
    return (( Mon1Right-Mon1Left - WidthOfGUI ) / 2) + Mon1Left
}
;==============================================================================
CoordYCenterScreen( HeightofGUI, ScreenNumber)
{
    SysGet, Mon1, Monitor, %ScreenNumber%
    return (Mon1Bottom - 30 - HeightofGUI ) / 2
}
;==============================================================================
GetClientSize(hwnd, ByRef w, ByRef h)
{
    VarSetCapacity(rc, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
    w := NumGet(rc, 8, "int")
    h := NumGet(rc, 12, "int")
}
;==============================================================================
ScreenToClient(hwnd, ByRef x, ByRef y)
{
    WinGetPos, wx, wy,,, ahk_id %hwnd%
    VarSetCapacity(pt, 8)
    NumPut(x + wx, pt, 0)
    NumPut(y + wy, pt, 4)
    DllCall("ScreenToClient", "uint", hwnd, "uint", &pt)
    x := NumGet(pt, 0, "int")
    y := NumGet(pt, 4, "int")
}
;==============================================================================
ClientToScreen(hwnd, ByRef x, ByRef y)
{

    VarSetCapacity(pt, 8)
    NumPut(x, pt, 0)
    NumPut(y, pt, 4)
    DllCall("ClientToScreen", "uint", hwnd, "uint", &pt)
    WinGetPos, wx, wy,,, ahk_id %hwnd%
    x := NumGet(pt, 0, "int") - wx
    y := NumGet(pt, 4, "int") - wy

}

;==============================================================================
;    T H I R D     P A R T Y   T O O L S
;==============================================================================
BufferCompare(ByRef a, Byref b, n=0)   ; compare buffers
{                                      ; a <,=,> b: Return <,=,> 0
   u := VarSetCapacity(a)
   v := VarSetCapacity(b)
   IfLess n, 1,  SetEnv n,0xffffffff   ; n = 0: compare all allocated
   IfLess u,%n%, SetEnv n,%u%          ; use at most the capacity of a
   IfLess v,%n%, SetEnv n,%v%          ; use at most the capacity of b
   Return DllCall("msvcrt\memcmp", "UInt", &a, "UInt", &b, "UInt", n, "CDecl Int")
}
;==============================================================================
;https://stackoverflow.com/questions/29783202/combine-absolute-path-with-a-relative-path-with-ahk/29804586
PathCombine( abs, rel) {
    VarSetCapacity(dest, (A_IsUnicode ? 2 : 1) * 260, 1) ; MAX_PATH
    DllCall("Shlwapi.dll\PathCombine", "UInt", &dest, "UInt", &abs, "UInt", &rel)
    Return, dest
}
;==============================================================================
FormatSeconds( s_ )
{
    sec  := 1,    min  := 60*sec,  hour := 60*min

    h := s_ // hour		, s_ := Mod( s_, hour )
    m := s_ // min	    , s_ := Mod( s_, min  )
    s := Round( s_, 0)

    time :=  Format("{:02} : {:02} : {:02}", h, m, s)

    return time
}
;==============================================================================
;https://autohotkey.com/board/topic/34188-calculating-time-difference/
FormatSeconds2( seconds_ )    ; Convert the specified number of seconds to hh:mm:ss format.
{
    time = 19990101         ; *Midnight* of an arbitrary date.
    time += %seconds_%, seconds
    FormatTime, mmss, %time%, mm:ss
    return seconds_//3600 ":" mmss  ; This method is used to support more than 24 hours worth of sections.
}
;==============================================================================
LengthenStr( str_ , minLength_ )
{
    ; add additional spaces to reach minimum length
    count :=  minLength_ - StrLen( str_ )

    Loop, % count {
        str_ .= " "
    }

    ;_Logger.TRACE( A_ThisFunc, "count", count, "minLength_",minLength_ , "str_",str_)
    return str_
}
;==============================================================================
BobMD5( ByRef bob, len := 0 )
{
    ; edited from www.autohotkey.com/forum/viewtopic.php?p=275910#275910

    VarSetCapacity( MD5_CTX , 104 , 0 )
    DllCall( "advapi32\MD5Init"   , Str,MD5_CTX )
    DllCall( "advapi32\MD5Update" , Str,MD5_CTX, Str,bob, UInt, len ? len : StrLen(bob) )
    DllCall( "advapi32\MD5Final"  , Str,MD5_CTX )
    Loop % StrLen( Hex:="123456789ABCDEF0" )
    {
        N   := NumGet( MD5_CTX,87+A_Index,"Char")
        MD5 .= SubStr(Hex,N>>4,1) SubStr(Hex,N&15,1)
    }
    Return MD5
}
;==============================================================================
;https://autohotkey.com/boards/viewtopic.php?t=3607 by HotKeyIt
HexToDec(str)
{
    static _0:=0,_1:=1,_2:=2,_3:=3,_4:=4,_5:=5,_6:=6,_7:=7,_8:=8,_9:=9,_a:=10,_b:=11,_c:=12,_d:=13,_e:=14,_f:=15
    str:=ltrim(str,"0x `t`n`r"),   len := StrLen(str),  ret:=0
    Loop,Parse,str
      ret +=  _%A_LoopField%*(16**(len-A_Index))
    return ret
}
;------------------------------------------------------------------------------
;https://autohotkey.com/boards/viewtopic.php?t=3607 by HotKeyIt
DecToHex(dec)
{
    static U := A_IsUnicode ? "w" : "a"
    VarSetCapacity(S,65,0)
    DllCall("msvcrt\_i64to" U, "Int64",dec, "Str",S, "Int", 16) ;; 16 = hex base
    StringUpper, S, S
    return S
}
;==============================================================================
; https://www.autohotkey.com/boards/viewtopic.php?t=791;
; Function .....: StdoutToVar_CreateProcess
; Description ..: Runs a command line program and returns its output.
; Parameters ...: sCmd      - Commandline to execute.
; ..............: sEncoding - Encoding used by the target process. Look at StrGet() for possible values.
; ..............: sDir      - Working directory.
; ..............: nExitCode - Process exit code, receive it as a byref parameter.
; Return .......: Command output as a string on success, empty string on error.
; AHK Version ..: AHK_L x32/64 Unicode/ANSI
; Author .......: Sean (http://goo.gl/o3VCO8), modified by nfl and by Cyruz
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Feb. 20, 2007 - Sean version.
; ..............: Sep. 21, 2011 - nfl version.
; ..............: Nov. 27, 2013 - Cyruz version (code refactored and exit code).
; ..............: Mar. 09, 2014 - Removed input, doesn't seem reliable. Some code improvements.
; ..............: Mar. 16, 2014 - Added encoding parameter as pointed out by lexikos.
; ..............: Jun. 02, 2014 - Corrected exit code error.
; ..............: Nov. 02, 2016 - Fixed blocking behavior due to ReadFile thanks to PeekNamedPipe.
StdoutToVar_CreateProcess(sCmd, sEncoding:="CP0", sDir:="", ByRef nExitCode:=0)
{
    DllCall( "CreatePipe",           PtrP,hStdOutRd, PtrP,hStdOutWr, Ptr,0, UInt,0 )
    DllCall( "SetHandleInformation", Ptr,hStdOutWr, UInt,1, UInt,1                 )

            VarSetCapacity( pi, (A_PtrSize == 4) ? 16 : 24,  0 )
    siSz := VarSetCapacity( si, (A_PtrSize == 4) ? 68 : 104, 0 )
    NumPut( siSz,      si,  0,                          "UInt" )
    NumPut( 0x100,     si,  (A_PtrSize == 4) ? 44 : 60, "UInt" )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 60 : 88, "Ptr"  )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 64 : 96, "Ptr"  )

    If ( !DllCall( "CreateProcess", Ptr,0, Ptr,&sCmd, Ptr,0, Ptr,0, Int,True, UInt,0x08000000
                                  , Ptr,0, Ptr,sDir?&sDir:0, Ptr,&si, Ptr,&pi ) )
        Return ""
      , DllCall( "CloseHandle", Ptr,hStdOutWr )
      , DllCall( "CloseHandle", Ptr,hStdOutRd )

    DllCall( "CloseHandle", Ptr,hStdOutWr ) ; The write pipe must be closed before reading the stdout.
    While ( 1 )
    { ; Before reading, we check if the pipe has been written to, so we avoid freezings.
        If ( !DllCall( "PeekNamedPipe", Ptr,hStdOutRd, Ptr,0, UInt,0, Ptr,0, UIntP,nTot, Ptr,0 ) )
            Break
        If ( !nTot )
        { ; If the pipe buffer is empty, sleep and continue checking.
            Sleep, 100
            Continue
        } ; Pipe buffer is not empty, so we can read it.
        VarSetCapacity(sTemp, nTot+1)
        DllCall( "ReadFile", Ptr,hStdOutRd, Ptr,&sTemp, UInt,nTot, PtrP,nSize, Ptr,0 )
        sOutput .= StrGet(&sTemp, nSize, sEncoding)
    }

    ; * SKAN has managed the exit code through SetLastError.
    DllCall( "GetExitCodeProcess", Ptr,NumGet(pi,0), UIntP,nExitCode )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,0)                  )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,A_PtrSize)          )
    DllCall( "CloseHandle",        Ptr,hStdOutRd                     )
    Return sOutput
}
;==============================================================================
;https://autohotkey.com/boards/viewtopic.php?t=23286
FlashActiveWindows( delayTick )
{
    WinGet, Trans0, Transparent , A
    Trans1 := Round(Trans0/2 ,0)
    WinSet, Transparent , %Trans1%, A
    Sleep, delayTick
    WinSet, Transparent , %Trans0%, A
}

;https://autohotkey.com/board/topic/92043-problems-with-flashwindowex/
;https://docs.microsoft.com/fr-fr/windows/win32/api/winuser/ns-winuser-flashwinfo
; example : FlashWindowEx(hWnd, 1, 3, 0) 
FlashWindowEx(hWnd := 0, dwFlags := 0, uCount := 0, dwTimeout := 0) {
   Static A64 := (A_PtrSize = 8 ? 4 : 0) ; alignment for pointers in 64-bit environment
   Static cbSize := 4 + A64 + A_PtrSize + 4 + 4 + 4 + A64
   VarSetCapacity(FLASHWINFO, cbSize, 0) ; FLASHWINFO structure
   Addr := &FLASHWINFO
   Addr := NumPut(cbSize,    Addr + 0, 0,   "UInt")
   Addr := NumPut(hWnd,      Addr + 0, A64, "Ptr")
   Addr := NumPut(dwFlags,   Addr + 0, 0,   "UInt")
   Addr := NumPut(uCount,    Addr + 0, 0,   "UInt")
   Addr := NumPut(dwTimeout, Addr + 0, 0,   "Uint")
   Return DllCall("User32.dll\FlashWindowEx", "Ptr", &FLASHWINFO, "UInt")
}