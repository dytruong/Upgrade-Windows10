SET ThisScriptsDirectory=%~dp0
SET PowerShellScriptPath=%ThisScriptsDirectory%upgradew10-ver10.ps1
powershell.exe -noprofile -executionpolicy Bypass -file "%PowerShellScriptPath%" -Verb RunAs
pause