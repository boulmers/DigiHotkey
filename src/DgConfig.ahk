class DgConfig extends DgPersistent
{
    __New( configFile_ )
    {
        _Logger.BEGIN( A_ThisFunc)

        this.configFile            := configFile_
        this.timerMaxSnoozeCount   := 5                     ; maximum number of timer Sonoozes

        this.timerSnoozePeriodSec  := 10
        this.timerNotifyTimeoutSec := 5

        this.notifyTipTimeoutSec   := 2
        this.volumeTipTimeoutSec   := 2                     ; Tick suffix is supposed to be MilliSeconds
        this.infoTipTimeoutSec     := 2

        this.insomniaPeriodSec     := 10

        ; Keyboard members
        this.capsLockBehaviour     := enumLockBehaviour.Free
        this.numLockBehaviour      := enumLockBehaviour.Free

        this.capsLockAlertEnabled  := true
        this.numLockAlertEnabled   := true

        this.insKeyEnabled         := true

        ; DgAudio member
        this.volume                := 10
        this.soundProfile          := "Default"
        this.languageName          := "English"
        
        this.beepOnInsomnia        := false

        this.actionGroups          := {}
        ; note that actionGroups here is a map strucure holding objects with enbabled as the only property

        _Logger.END( A_ThisFunc)

    }
    ;------------------------------------------------------------------------------
    load()
    {
        _Logger.BEGIN( A_ThisFunc)

        this.fromJsonFile( this.configFile , mergeData := true ) ; mergeData : copy destination data whom keys doesnt exist in source
        this.validate()

        _App.audio.soundProfile             := this.soundProfile
        _App.audio.volume                   := this.volume

        _App.keyboard.capsLockBehaviour     := this.capsLockBehaviour
        _App.keyboard.numLockBehaviour      := this.numLockBehaviour
        _App.keyboard.insKeyEnabled         := this.insKeyEnabled

        _App.ui.capsLockAlertEnabled        := this.capsLockAlertEnabled
        _App.ui.numLockAlertEnabled         := this.numLockAlertEnabled
        _App.ui.languageName                := this.languageName

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------------
    save()
    {
        _Logger.BEGIN( A_ThisFunc)
        
        this.soundProfile         := _App.audio.soundProfile
        this.volume               := _App.audio.volume

        this.capsLockBehaviour    := _App.keyboard.capsLockBehaviour
        this.numLockBehaviour     := _App.keyboard.numLockBehaviour
        this.insKeyEnabled        := _App.keyboard.insKeyEnabled

        this.capsLockAlertEnabled := _App.ui.capsLockAlertEnabled
        this.numLockAlertEnabled  := _App.ui.numLockAlertEnabled
        this.languageName         := _App.ui.languageName
        
        _Logger.TRACE( A_ThisFunc, this.languageName)

        ;save action groups enabled/disabled sates to config file, see description in the constructor.
        for _, actionGroup in  _App.keyboard.actionGroups {

            this.actionGroups[ actionGroup.name] := {  enabled: actionGroup.enabled }

        }

        this.toJsonFile( this.configFile )

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------------
    validate() ; check and validate data : assigne default value if data are invalid
    {
        _Logger.BEGIN( A_ThisFunc)

        this.timerMaxSnoozeCount        := this.timerMaxSnoozeCount   ? this.timerMaxSnoozeCount    : 5                 ; maximum number of timer Sonoozes

        this.timerSnoozePeriodSec       := this.timerSnoozePeriodSec  ? this.timerSnoozePeriodSec   : 10
        this.timerNotifyTimeoutSec      := this.timerNotifyTimeoutSec ? this.timerNotifyTimeoutSec  : 5

        this.notifyTipTimeoutSec        := this.notifyTipTimeoutSec   ? this.notifyTipTimeoutSec    : 2
        this.volumeTipTimeoutSec        := this.volumeTipTimeoutSec   ? this.volumeTipTimeoutSec    : 2                 ; Tick suffix is supposed to be MilliSeconds
        this.infoTipTimeoutSec          := this.infoTipTimeoutSec     ? this.infoTipTimeoutSec      : 2

        ; Keyboard members
        this.capsLockBehaviour          := this.capsLockBehaviour     ? this.capsLockBehaviour :enumLockBehaviour.Free
        this.numLockBehaviour           := this.numLockBehaviour      ? this.numLockBehaviour :enumLockBehaviour.Free

        this.capsLockAlertEnabled       := this.capsLockAlertEnabled  ? this.capsLockAlertEnabled : true
        this.numLockAlertEnabled        := this.numLockAlertEnabled   ? this.numLockAlertEnabled : true
        this.insKeyEnabled              := this.insKeyEnabled         ? this.insKeyEnabled      : true

        ; DgAudio member
        this.volume                     := this.volume                ? this.volume : 10
        this.soundProfile               := this.soundProfile          ? this.soundProfile : enumSoundProfile.Modern

        this.beepOnInsomnia             := this.beepOnInsomnia        ? this.beepOnInsomnia : false

        _Logger.END( A_ThisFunc)
    }
    ;------------------------------------------------------------------------------

}