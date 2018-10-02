@echo off
rem Progress OpenEdge Watcher

rem Insert a point where installers can set a fixed CATALINA_HOME location
set CATALINA_HOME=C:\Progress\OpenEdge\servers\pasoe

rem Allow tailoring of CATALINA_BASE
set CATALINA_BASE=C:\PASOE\SportsDemo

:TESTHOME
if exist "%CATALINA_HOME%" goto TESTBASE
echo CATALINA_HOME refers to an invalid directory path
exit /b 1

:TESTBASE
if exist "%CATALINA_BASE%" goto TESTPS
echo CATALINA_BASE refers to an invalid directory path
exit /b 1

:TESTPS
for %%X in (Powershell.exe) do (set pwrshell=%%~$PATH:X)
if defined pwrshell goto MKPATH
echo Powershell.exe cannot be found in the process PATH 
exit /b 1

:MKPATH
if exist "%CATALINA_HOME%\bin\%~n0.ps1" goto GETPID
echo Cannot find "%CATALINA_HOME%\bin\%~n0.ps1" needed to run this program
exit /b 1

rem get PASOE Process Id
:GETPID
if exist "%CATALINA_BASE%\bin\tcman.bat" goto GETPID1
echo Cannot find "%CATALINA_BASE%\bin\tcman.bat" needed to get PASOE PID
exit /b 1
:GETPID1
rem logging configuration file path
set LOGBACK=%CATALINA_BASE%\conf\watcher-logging.xml
if exist "%LOGBACK%" goto START
echo WARNING. Logging file %LOGBACK% doesn't exist

:START
PowerShell.exe -NoProfile -ExecutionPolicy Bypass  "%CATALINA_HOME%\bin\%~n0.ps1" %* 

:END
