Personal and keyboard oriented productivity tools.

### Getting Started

This project can be used both as productivity helper and as an educational project in Windows automation using [*AutoHotkey*](https://www.autohotkey.com/)

### Prerequisites

*AutoHotkey* (Unicode version 1.1.30 or later)

### Features

-   High performance keyboard typing sound simulator with sound profiles.
-   *JSON* user-friendly and customizable Hotkeys.
-   Define, enable/disable hotkey groups.
-   Included French diacritics hotkeys in bundled actions configuration file (diacritics group).
-   Informs user about CapsLock & NumLock state change.
-   Enable/disable *CapsLock*, *NumLock* and Insert keys.
-   Individual application volume control Hotkeys.
-   Timer.
-   Mindfulness reminder.
-   Insomnia mode (keeps *OS* form going to sleep)
-   Quickly switch power plan.
-   Easy localization
-   No backdoors or key loggers.

### Platform

*Windows XP* or later

### Configuration files

-   `config\actions.json` : Actions and hotkeys.
-   `config\audio.json`: Sound profiles.
-   `config\config.json`: General configuration file.
-   `config\hotstrings.json` : Hot strings.
-   `config\keyboard_US.json` ( read only configuration file)
-   `config\lang.json` : (read only localization file)

### Executing & Compiling

You can run the software by double clicking `bin\DigiHotkey.ahk`

You can compile *DigiHotkey* yourself by right clicking \`bin\DigiHotkey.ahk` script file in the Explorer then clicking *Compile*

Consult <https://www.autohotkey.com/docs/Scripts.htm#ahk2exe>

### TO DO

1.  User documentation.
2.  Config files documentation.
3.  Localize to French language.
4.  Add UI interface to Language selection.
5.  Display keyboard *CapsLock* and *NumLock* status icon in the notification area.
6.  Add robust error handling functionality.
7.  ...

### Credits & Copyrights

-   All included sounds are a copyrighted material. I did include them for an illustrative and educational purposes.
-   Many sounds have been recorded and processed by myself under CC license, I will list them if necessary. Many other CC licensed sounds have been heavily processed.
-   Ensure you have the rights to use proprietary sounds for other than educational purposes.
-   All third party libraries are open sourced and located in the `/lib` folder.
-   This project uses the [BASS audio library](https://www.un4seen.com/) for audio rendering.

License
-------

This project is licensed under the GPL License