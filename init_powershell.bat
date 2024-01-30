@echo off

::%~dp0 : Current path of script. Example: D:\project\main.ps1

::powershell -Command "&{ Start-Process powershell -ArgumentList '-ExecutionPolicy Unrestricted -File %~dp0main.ps1' -Verb RunAs}"

powershell -executionpolicy unrestricted -noexit -file "%~dp0main.ps1"