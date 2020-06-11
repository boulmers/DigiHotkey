Personal and keyboard oriented productivity tools.

### Getting Started

This project can be used both as an educational project in windows automation and a base for personal productivity tools using [*AutoHotkey*](https://www.autohotkey.com/)

### Prerequisites

*AutoHotkey* (Unicode *32bits* )

### Features

-   High performance keyboard typing sound simulator with sound profiles.
-   *JSON* user-friendly and customizable Hotkeys.
-   Customizable Hotstrings
-   Define, enable/disable hotkey groups.
-   Included French diacritics hotkeys in bundled actions configuration file (diacritics group).
-   Informs user about CapsLock & NumLock state change.
-   Enable/disable *CapsLock*, *NumLock* and Insert keys.
-   Individual application volume control Hotkeys.
-   Timer.
-   Mindfulness reminder.
-   Insomnia mode (keeps *OS* form going to sleep)
-   Quickly switch power plan.
-   Customizable Languages
-   No backdoor or key logger.

### Platform

*Windows XP* or later

### Configuration files

-   `config\actions.json` : Actions and triggering Hotkeys
-   `config\audio.json`: Sound Profiles
-   `config\config.json`: General configuration file
-   `config\hotstrings.json` : Hot strings
-   `config\keyboard_US.json` ( mean to be read only configuration file)
-   `config\lang.json` : (read only localization configuration file)

### Executing & Compiling

You can run the software by double clicking `bin\DigiHotkey.ahk`

You can compile *DigiHotkey* yourself by right clicking \`bin\DigiHotkey.ahk` script file in the Explorer then clicking *Compile*
(Consult <https://www.autohotkey.com/docs/Scripts.htm#ahk2exe>)

You can also directly install *DigiHotkey* using the installer in the release tab.

### TO DO

1.  ~~Quick Guide~~.
2.  Config files documentation (in progress).
3.  ~~Localize to French language~~.
4.  ~~Add UI interface to Language selection~~.
5.  Display keyboard *CapsLock* and *NumLock* status icon in the notification area.
6.  Add robust error handling functionality.
7.  Fix sounds not properly playing after computer sleep recovery
8.  ...

### Known issues
1. Sounds not properly playing after computer sleep recovery
2. 

### Credits & Copyrights

-   All included sounds are a copyrighted material. I did include them for an illustrative and educational purposes.
-   Many sounds have been recorded and processed by myself under CC license, I will list them if necessary. Many other CC licensed sounds have been heavily processed.
-   Ensure you have the rights to use proprietary sounds for other than educational purposes.
-   All third party libraries are open sourced and located in the `/lib` folder
-   This project uses the [BASS audio library](https://www.un4seen.com/) for audio rendering

License
-------

This project is licensed under the MIT License
