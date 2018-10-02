@echo off 
rem Starts oejmx.ps1, a monitoring tool, which uses jmx services to access Tomcat beans:
rem  - generates a list of bean operations and attributes exposed to jmx
rem  - invokes bean operations and reads bean attributes.
rem Accepts four optional attributes
rem -C - signales to generate a list of bean operations/attributes 
rem -Q <file name> - file name (with path) having a set of bean opertion/attribute requests. 
rem    This parameter is ignored if -C attribute present. Default value: <PASOE Base Dir>\bin\queries\queries.txt. 
rem    Users have to pouplate this file with queries.
rem -O <file name> - output file name (with path). 
rem    The file name may include timestamp template: {TIMESTAMP} or {TIMESTAMP:<java type datetime format>}
rem    Default values:
rem      If -C argumet presents: <PASOE Temp Dir>\beanInfo{TIMESTAMP:yyMMdd-HHmm}.txt
rem      If no -C argumet:  <PASOE Temp Dir>\queries-out-{TIMESTAMP:yyMMdd-HHmmss}.txt
rem -R - signals write into output file results only. Oterhwise output file also includes queriy texts. 
rem      It ignored if -C argumet presents

rem Insert a point where installers can set a fixed CATALINA_HOME location
set CATALINA_HOME=C:\Progress\OpenEdge\servers\pasoe

rem Allow an tcman create command tailor CATALINA_BASE
set CATALINA_BASE=C:\PASOE\SportsDemo

rem Allow tailoring of where temp files are accessed, but
rem allow the individual's environment to supercede tailoring
rem if not "%CATALINA_TMPDIR%" == "" goto gottmp
set CATALINA_TMPDIR=%CATALINA_BASE%\temp

:gottmp

if defined CATALINA_HOME goto testexist
echo CATALINA_HOME is not defined or points to an invalid server installation
exit /b 1

:testexist
if exist "%CATALINA_HOME%" goto testps
echo CATALINA_HOME refers to an invalid directory path
exit /b 1

:testps
rem The Powershell.exe program must be accessible for any tailoring
rem to run, so test it now and exit with an error if it cannot
rem be found.
for %%X in (Powershell.exe) do (set pwrshell=%%~$PATH:X)
if defined pwrshell goto mkpath
echo Powershell.exe cannot be found in the process PATH
exit /b 1

:mkpath
set PRGDIR=%CATALINA_HOME%\bin\oejmx.ps1
set EXECUTABLE=PowerShell.exe -executionpolicy bypass -File "%PRGDIR%"

if exist "%PRGDIR%" goto javacfg
echo Cannot find %PRGDIR% that is needed to run this program
exit /b 1

:javacfg
rem Define a place where the JAVA_HOME and/or JRE_HOME process environment
rem variables can be customized before executing JAVA related operations.
rem This script will call out to the javacfg.bat script in the CATALINA_HOME
rem directory to do the work so that it is in sync with the tcmanager utility
rem version.
if exist "%CATALINA_HOME%\bin\javacfg.bat" (
    call "%CATALINA_HOME%\bin\javacfg.bat"
)

:doexec
rem execute oejmx.ps1
rem gather all arguments into a single variable, prefixed with a static
rem value 'tcman' (which is required) so that none of the remaining
rem variable substitutions fail due to an empty variable in an 'if' test
rem note: DOS auto removes quotes if the value does not have a space in it
set args=tcman %*

rem powershell escape double-quotes to get past DOS argument passing
set args=%args:"=`"%

rem powershell does not accept DOS escape characters, so substitute
rem with powershell escape characters
set args=%args:^=`%

rem If we end up with double powershell escapes, reduce back to one
set args=%args:``=`%

rem echo args: %args%

%EXECUTABLE% %args%

:end
set PRGDIR=
set EXECUTABLE=

exit /b %errorlevel%



