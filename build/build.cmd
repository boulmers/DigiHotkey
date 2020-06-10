@echo compiling ahk script to executable format...
Ahk2Exe /in "..\bin\DigiHotkey.ahk" /out "..\bin\DigiHotkey.exe" /icon "..\img\DigiHotkey.ico"

@echo compiling inno setup program
iscc InstallScript.iss
