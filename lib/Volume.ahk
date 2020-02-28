﻿
; ISimpleAudioVolume : {87CE5498-68D6-44E5-9215-6DA47EF883D8}
ISimpleAudioVolume_GetMasterVolume(this, ByRef fLevel) 
{
	return DllCall(NumGet(NumGet(this+0)+4*A_PtrSize), "ptr", this, "float*", fLevel)
}
ISimpleAudioVolume_SetMasterVolume(this, ByRef fLevel, GuidEventContext="") 
{
	return DllCall(NumGet(NumGet(this+0)+3*A_PtrSize), "ptr", this, "float", fLevel, "ptr", VA_GUID(GuidEventContext))
}
ISimpleAudioVolume_GetMute(this, ByRef muted) 
{
	return DllCall(NumGet(NumGet(this+0)+6*A_PtrSize), "ptr", this, "int*", muted)
}
ISimpleAudioVolume_SetMute(this, ByRef muted, GuidEventContext="") 
{
	return DllCall(NumGet(NumGet(this+0)+5*A_PtrSize), "ptr", this, "int", muted, "ptr", VA_GUID(GuidEventContext))
}
GetISimpleAudioVolume(Param)
{
	static IID_IASM2 := "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}"
	, IID_IASC2 := "{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}"
	, IID_ISAV := "{87CE5498-68D6-44E5-9215-6DA47EF883D8}"

	; Turn empty into integer
	if !Param
		Param := 0

	; Get PID from process name
	if Param is not Integer
	{
		Process, Exist, %Param%
		Param := ErrorLevel
	}

	; GetDefaultAudioEndpoint
	DAE := VA_GetDevice()

	; activate the session manager
	VA_IMMDevice_Activate(DAE, IID_IASM2, 0, 0, IASM2)

	; enumerate sessions for on this device
	VA_IAudioSessionManager2_GetSessionEnumerator(IASM2, IASE)
	VA_IAudioSessionEnumerator_GetCount(IASE, Count)

	; search for an audio session with the required name
	Loop, % Count
	{
		; Get the IAudioSessionControl object
		VA_IAudioSessionEnumerator_GetSession(IASE, A_Index-1, IASC)

		; Query the IAudioSessionControl for an IAudioSessionControl2 object
		IASC2 := ComObjQuery(IASC, IID_IASC2)
		ObjRelease(IASC)

		; Get the session's process ID
		VA_IAudioSessionControl2_GetProcessID(IASC2, SPID)

		; If the process name is the one we are looking for
		if (SPID == Param)
		{
			; Query for the ISimpleAudioVolume
			ISAV := ComObjQuery(IASC2, IID_ISAV)

			ObjRelease(IASC2)
			break
		}
		ObjRelease(IASC2)
	}
	ObjRelease(IASE)
	ObjRelease(IASM2)
	ObjRelease(DAE)
	return ISAV
}