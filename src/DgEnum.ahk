
/*
; BEGIN EXAMPLE

#include DgLogger.ahk

logFile             := A_ScriptName ".log"
global _Logger           := new DgLogger( A_ScriptDir , logFile)

start:
_Logger.TRACE( A_ThisLabel, "Start")
;global t := new DgLockStateEnum()

a := LockStateEnum.On
b := LockStateEnum.AlwaysOn
c := LockStateEnum.AlwaysOn1
d := LockStateEnum.AlwaysOff
e := LockStateEnum.Off
f := LockStateEnum.Off1

return

;END EXAMPLE
*/
;==============================================================================
class DgEnum
{
    __Get( key ) ; protect against wrong key access
    {
        _Logger.ERROR( this.__Class, key " : key not found")
    }
}
;==============================================================================
class enumProgress extends DgEnum
{
    static PBM_SETMARQUEE        := WM_USER + 10
    static PBM_SETSTATE          := WM_USER + 16
    static PBST_ERROR            := "0x00000002"
    static PBST_NORMAL           := "0x00000001"
    static PBST_PAUSE            := "0x00000003"
    static PBS_MARQUEE           := "0x00000008"
    static PBS_SMOOTH            := "0x00000001"
    static PBS_VERTICAL          := "0x00000004"
    static STAP_ALLOW_CONTROLS   := "0x00000002"
    static STAP_ALLOW_NONCLIENT  := "0x00000001"
    static STAP_ALLOW_WEBCONTENT := "0x00000004"
    static WM_THEMECHANGED       := "0x0000031A"
    static WM_USER               := "0x00000400"
}
;==============================================================================
class enumWinMsg extends DgEnum
{
    static WM_INPUTLANGCHANGE := 0x0051
}
;==============================================================================
class enumClipBloard extends DgEnum
{
    static WM_CUT   := 0x0300
    static WM_COPY  := 0x0301
    static WM_PASTE := 0x0302
    static WM_CLEAR := 0x0303
    static WM_UNDO  := 0x0304
    static EM_UNDO  := 0x00C7
}
;==============================================================================
class enumFlashWin extends DgEnum
{
    static FLASHW_ALL 		:= 3        ; Flash both the window caption and taskbar button. This is equivalent to setting FLASHW_CAPTION|FLASHW_TRAY flags.
    static FLASHW_CAPTION 	:= 1    ; Flash the window caption.
    static FLASHW_STOP 		:= 0       ; Stop flashing. The system restores the window to its orig. state.
    static FLASHW_TIMER 	:= 4      ; Flash continuously, until the FLASHW_STOP flag is set.
    static FLASHW_TIMERNOFG := 12 ; Flash continuously until the window comes to foreground.
    static FLASHW_TRAY 		:= 2       ; Flash the taskbar button.
}
;==============================================================================
class enumLockBehaviour extends DgEnum
{
    static AlwaysOn  := "AlwaysOn"
    static AlwaysOff := "AlwaysOff"
    static Free	  	 := "Free"
}
;==============================================================================
class enumNotifyLock  extends DgEnum
{
    static On		 := "On"
    static Off  	 := "Off"
    static Free		 := "Free"
    static AlwaysOn  := "AlwaysOn"
    static AlwaysOff := "AlwaysOff"
}
;==============================================================================
class enumTaskType extends DgEnum
{
    static Timer 	:= "Timer"
    static Reminder	:= "Reminder"
    static Insomnia := "Insomnia"
}
;==============================================================================
class enumTimeType extends DgEnum
{
    static Absolute := "Absolute"
    static Relative := "Relative"
}
;==============================================================================
class enumUnicode extends DgEnum
{
    static Pause  		:= Chr(0x3B) ;Chr(0x23F8)
    static Stop  		:= Chr(0x3C) ; Chr(0x25fc)
    static Play 		:= Chr(0x34) ; Chr(0x25b6)

    static Mute     	:= Chr(0x1f507) ; 🔇
    static Forbidden 	:= Chr(0x1f6ab) ; 🚫
    static FullRect  	:= Chr(0x2588)  ; full bloc rect for testing
}
;==============================================================================
class enumColor extends DgEnum
{
    ;from https://www.color-hex.com/color-names.html

    ; named colors
    static FloralWhite		:= "0xfffaf0"
    static Gainsboro		:= "0xdcdcdc"
    static Red1 			:= "0xFF0000"
    static LightGray    	:= "0xC0C0C0"
    static Gray		        := "0xbebebe"
    static SteelBlue4 		:= "0x36648b"
    static DimGray			:= "0x696969"

    static LightSlateGray	:= "0x778899"
    static LightSteelBlue4	:= "0x6e7b8b"

    static SlateGray		:= "0x708090"
    static SlateGray1		:= "0xc6e2ff"
    static SlateGray2		:= "0xb9d3ee"
    static SlateGray3		:= "0x9fb6cd"
    static SlateGray4		:= "0x6c7b8b"

    static Green 			:= "0x00FF00"
    static GreenYellow  	:= "0xADFF2F"
    static DarkSlateGray 	:= "0x2f4f4f"



    static Azure1			:= "0xf0ffff"
    static Azure2			:= "0xe0eeee"
    static Azure3			:= "0xc1cdcd"
    static Azure4			:= "0x838b8b"

    static Chartreuse1		:= "0x7fff00"
    static Chartreuse2		:= "0x76ee00"
    static Chartreuse3		:= "0x66cd00"
    static Chartreuse4		:= "0x458b00"

    static Green1		    := "0x00ff00"
    static Green2		    := "0x00ee00"
    static Green3		    := "0x00cd00"
    static Green4		    := "0x008b00"
    static DarkGreen		:= "0x006400"
    static PaleGreen4		:= "0x548b54"
    static DarkOliveGreen	:= "0x556b2f"
    ;------------------------------------------------------------------------------
    ; UI Color Aliases
    static LedWarn     		:= enumColor.Red1

    static LedOff     		:= enumColor.DarkSlateGray
    static LedOffBack     	:= enumColor.Azure4

    static LedOn      		:= enumColor.Green ; "0x00FF00" ;enumColor.Green1

    static DigiHotkeyVolTip := "0x229954"
    static AppVolTip    	:= "0x01B9FF"
    static MasterVolTip 	:= "0xE74C3C"
    static NotifyCloseBtn   := "0x808080"

}

;==============================================================================
class enumAnim extends DgEnum
{
    static ROLL_LEFT_TO_RIGHT  := 0x20001
    static ROLL_RIGHT_TO_LEFT  := 0x20002
    static ROLL_TOP_TO_BOTTOM  := 0x20004
    static ROLL_BOTTOM_TO_TOP  := 0x20008
    static ROLL_DIAG_TL_TO_BR  := 0x20005
    static ROLL_DIAG_TR_TO_BL  := 0x20006
    static ROLL_DIAG_BL_TO_TR  := 0x20009
    static ROLL_DIAG_BR_TO_TL  := 0x2000a
    static SLIDE_LEFT_TO_RIGHT := 0x40001
    static SLIDE_RIGHT_TO_LEFT := 0x40002
    static SLIDE_TOP_TO_BOTTOM := 0x40004
    static SLIDE_BOTTOM_TO_TOP := 0x40008
    static SLIDE_DIAG_TL_TO_BR := 0x40005
    static SLIDE_DIAG_TR_TO_BL := 0x40006
    static SLIDE_DIAG_BL_TO_TR := 0x40009
    static SLIDE_DIAG_BR_TO_TL := 0x40010
    static ZOOM_IN             := 0x00016
    static ZOOM_OUT            := 0x10010
    static FADE_IN             := 0xa0000
    static FADE_OUT            := 0x90000

    static AW_HIDE			   :=  0x00010000

    static AW_BLEND 		   := 0x00080000
}
