;BOOL w32FlashWindow(HWND hWnd,BOOL bInvert);
w32FlashWindow( hWnd, bInvert)
{
    DllCall( "FlashWindow", UInt, hWnd, Int, bInvert )
}
;==============================================================================
/*
    typedef struct {
    UINT  cbSize;
    HWND  hwnd;
    DWORD dwFlags;
    UINT  uCount;
    DWORD dwTimeout;
    } FLASHWINFO, *PFLASHWINFO;
*/
w32FlashWindowEx( hWnd , Flags :=0 , TI := 0, TO := 0 )
{
    Static FWI="0123456789ABCDEF01234" ; FLASHWINFO Structure
    NumPut(20,      FWI)
    NumPut(hWnd,    FWI, 4)
    NumPut(Flags,   FWI, 8)
    NumPut(TI,      FWI, 12)
    NumPut(TO,      FWI, 16)

    Return DllCall( "FlashWindowEx", UInt, &FWI )
}
;==============================================================================
w32IsWindowVisible( hWnd )
{
    DetectHiddenWindows On
        ret := DllCall("IsWindowVisible", "UInt", hWnd) ; WinExist() returns an HWND.
    DetectHiddenWindows Off
    return ret
}
;==============================================================================
w32AnimateWin( hWnd, fadeDelayTick, Flag )
{
    ; _Logger.TRACE( A_ThisFunc, "fadeDelayTick", fadeDelayTick, "hWnd", hWnd)
    DllCall("AnimateWindow","UInt",hWnd,"Int", fadeDelayTick,"UInt",Flag)
}
;==============================================================================
/*
Determines whether a key is up or down at the time the function is called, and whether the key was pressed after a previous call to GetAsyncKeyState.

SHORT GetAsyncKeyState(
  int vKey
);
*/
w32GetAsyncKeyState( vKey )
{
    return DllCall("GetAsyncKeyState", "UInt", vKey)
}
;==============================================================================
/*
Sends the specified message to a window or windows. The SendMessage function calls the window procedure for the specified window and does not return until the window procedure has processed the message.

LRESULT SendMessage(
  HWND   hWnd,
  UINT   Msg,
  WPARAM wParam,
  LPARAM lParam
);
*/
w32SendMessage( hWnd,  Msg, wParam, lParam)
{
    DllCall("User32.dll\SendMessage", "Ptr", hWnd, "Int", Msg, "Ptr", wParam, "Ptr", lParam)
}
;==============================================================================
