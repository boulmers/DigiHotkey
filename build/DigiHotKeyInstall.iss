
[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{EAB38D07-0CDF-4821-9E71-71EBECE16EAF}
AppName=DigiHotKey
AppVersion=0.1.0
;AppVerName=DigiHotKey 0.1.0
AppPublisher=Med Boulmers
DefaultDirName={pf}\DigiHotKey
DefaultGroupName=DigiHotKey
AllowNoIcons=yes
OutputDir=D:\My\dev\AHK\DigiHotkey\output
OutputBaseFilename=DigiHotKeySetup
Compression=lzma
SolidCompression=yes

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

;Name: startup; Description: "Automatically start on login"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\bin\DigiHotkey.exe"; DestDir: "{app}\bin"; Flags: ignoreversion
Source: "..\bin\bass.dll"; DestDir: "{app}\bin"; Flags: ignoreversion
Source: "..\config\*"; DestDir: "{userappdata}"; Flags: ignoreversion recursesubdirs createallsubdirs
;Source: "..\bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\audio\*"; DestDir: "{app}\audio"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\img\*"; DestDir: "{app}\img"; Flags: ignoreversion recursesubdirs createallsubdirs

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\DigiHotKey"; Filename: "{app}\bin\DigiHotkey.exe"
Name: "{commondesktop}\DigiHotKey"; Filename: "{app}\bin\DigiHotkey.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\DigiHotKey"; Filename: "{app}\bin\DigiHotkey.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\bin\DigiHotkey.exe"; Description: "{cm:LaunchProgram,DigiHotKey}"; Flags: nowait postinstall skipifsilent
