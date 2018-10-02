@echo off
rem
rem Script to deploy a SOAP descriptor to a given OEABL Application
rem

set _exitstatus=1

if ""%2"" == """" goto doUsage

rem Read the cmdLine Arguments
:doSetArgs
set DESCLOC=%~1
set APPNAME=%~2
set OPT_UNDEP=%~3

rem Determine the correct directory where OpenEdge is installed	
:checkDLC
if not defined DLC (
set DLC=C:\Progress\OpenEdge
)
if exist "%DLC%\version" goto checkCatalina
   echo.
   echo DLC environment variable not set correctly - Please set DLC variable
   echo.
   goto ERR
   
rem Check for the tailored CATALINA_HOME environment variable
rem CATALINA_HOME environment variable is tailored during the PAS install process
rem CATALINA_BASE is tailored during PAS instance creation process   
:checkCatalina
set CATALINA_HOME=C:\Progress\OpenEdge\servers\pasoe
set CATALINA_BASE=C:\PASOE\SportsDemo

if not defined CATALINA_HOME (
    echo Tomcat installation directory ^(CATALINA_HOME^) is defined as ""
    goto ERR
)
if not defined CATALINA_BASE (
set CATALINA_BASE=C:\PASOE\SportsDemo
    set _removeCatBase=y
)
if exist "%CATALINA_BASE%" ( 
    set CATALINA_WEBAPPS=%CATALINA_BASE%\webapps
    goto checkJAVA
)
echo Cannot find a Tomcat installation in directory: "%CATALINA_BASE%"
goto ERR

rem Check if Java enviornment is available
:checkJAVA
if not defined JRE_HOME set JRE_HOME=%DLC%\jre
if not defined JAVA_HOME set JAVA_HOME=%DLC%\jdk

rem Load the current system's hostname and full dns name for use by the
rem internal web applications and server configuration
:loadDNSInfo
    if defined CATALINA_DEBUG echo dbg: loading host DNS name for %COMPUTERNAME%

    if exist "%CATALINA_BASE%\temp\nslookup.dat" del "%CATALINA_BASE%\temp\nslookup.dat"
    nslookup %COMPUTERNAME% 1> "%CATALINA_BASE%\temp\nslookup.dat" 2>&1
    if exist "%CATALINA_BASE%\temp\nslookup.dat" goto doLookup
    echo ERROR: Could not find required file "%CATALINA_BASE%\temp\nslookup.dat"
exit /b 1

:doLookup
    for /f "tokens=2 delims=: " %%i in ('type "%CATALINA_BASE%\temp\nslookup.dat" ^| findstr "Name:"') do set _dnsinfo=%%i
    if "%_dnsinfo%" neq "" set DNS_OPTS=-Dpsc.as.dns.name=%_dnsinfo% -Dpsc.as.host.name=%COMPUTERNAME%
    if "%_dnsinfo%" neq "" goto endDNSInfo

    for /f "tokens=1-2 delims=:" %%a in ('ipconfig^|findstr "IPv4"') do set _rawdns=%%b
    for /f "tokens=* delims= " %%t in ("%_rawdns%") do set _dnsinfo=%%t
    if "%_dnsinfo%" neq "" set DNS_OPTS=-Dpsc.as.dns.name=%_dnsinfo% -Dpsc.as.host.name=%COMPUTERNAME%
    if "%_dnsinfo%" neq "" goto endDNSInfo

    set DNS_OPTS=-Dpsc.as.dns.name=127.0.0.1 -Dpsc.as.host.name=%COMPUTERNAME%
    if defined CATALINA_DEBUG echo dbg: no DNS name found - using default 127.0.0.1

:endDNSInfo
	
rem Read catalina.properties and appserver.properties for current instance
rem and read psc.as.http.port and psc.as.https.port properties
set _propFiles="%CATALINA_BASE%\conf\catalina.properties" "%CATALINA_BASE%\conf\appserver.properties"
if defined CATALINA_DEBUG echo dbg: loading HTTP and HTTPS ports from %_propFiles% 
:getHTTPPort
    for /f "tokens=*" %%a in ('findstr /C:psc.as.http.port= %_propFiles%') do set _temp=%%a
	for /f "tokens=3 delims=:" %%a in ("%_temp%") do set _propStr=%%a
	for /f "tokens=2 delims==" %%a in ("%_propStr%") do set PSC_HTTP_PORT=%%a

:getHTTPSPort
    for /f "tokens=*" %%a in ('findstr /C:psc.as.https.port= %_propFiles%') do set _temp=%%a
	for /f "tokens=3 delims=:" %%a in ("%_temp%") do set _propStr=%%a
	for /f "tokens=2 delims==" %%a in ("%_propStr%") do set PSC_HTTPS_PORT=%%a	
	
rem Determine if the Service Directory exists or else create
echo Using DLC:                 "%DLC%"
echo Using CATALINA_HOME:       ""%CATALINA_HOME%"
echo Using CATALINA_WEBAPPS:    "%CATALINA_WEBAPPS%"
echo Using JDK_HOME:            "%JAVA_HOME%"
echo Using JRE_HOME:            "%JRE_HOME%"
echo Using INSTANCE_HOST_NAME:  "%COMPUTERNAME%"
echo Using INSTANCE_HTTP_PORT:  "%PSC_HTTP_PORT%"
echo Using INSTANCE_HTTPS_PORT: "%PSC_HTTPS_PORT%"


set DEPLOYMGRCLASS=com.progress.appserv.manager.util.deploySOAP
set CLASSPATH=%CATALINA_HOME%\common\lib\*
set APPDIR=%CATALINA_WEBAPPS%\%APPNAME%
set SCHEMADIR=%CATALINA_BASE%

rem Begin Splitting FilePath to Extract name and extenstion
:doExtractFileName
    setlocal ENABLEDELAYEDEXPANSION
    set FILE_PATH=%DESCLOC%

:loopForDelimiter
    if "!FILE_PATH!" EQU "" goto getFileName

    REM Tokenize Full Path based on \ "Seperator". Set the first Token to FNAME_WEXT
    for /f "delims=\" %%a in ("!FILE_PATH!") do set substring=%%a
        set FNAME_WEXT=!substring!

:loopEachSubstring
    REM Get Lead Character from the Input Full Path
    set LEAD_CHAR=!FILE_PATH:~0,1!
    REM Remove Lead Character from the Input Full Path
    set FILE_PATH=!FILE_PATH:~1!
    REM If remaining string is empty we reached END of Input Full Path. Go Back.
    if "!FILE_PATH!" EQU "" goto loopForDelimiter
    REM If Lead Character is \ give back the remaining string to First Loop for Tokenization.
    if "!LEAD_CHAR!" NEQ "\" goto loopEachSubstring
    goto loopForDelimiter

:getFileName
    set fileName=!FNAME_WEXT!
    REM Tokenize the FNAME_WEXT based on '.'. Seperate out file Name and Extension
    for /f "tokens=1,2 delims=." %%a in ("!FNAME_WEXT!") do (
		set PAARNAME=%%a
		set EXTNAME=%%b
	)
    goto checkService
endlocal
rem End Splitting FilePath to Extract name and extenstion

rem Check whether the target OEABL WebApp directory exists
:checkService
    if exist "%APPDIR%" goto checkOpt
    echo "%APPDIR%"
    echo No services deployed with name %APPNAME%
    echo.
    goto ERR

rem Check whether this request is deploy/undeploy/invalid 
:checkOpt
    if "%OPT_UNDEP%" == "-undeploy" (
        echo Undeploying
        goto undeployService
    ) else (
	    if "%OPT_UNDEP%" == "" (
	    echo Deploying
	    ) else (
	      echo "Unknown option: %OPT_UNDEP%"
	      goto ERR
	    )
    )

rem Determine if the Source Descriptor File exists
:checkSrcDesc
if %EXTNAME%==wsm (
        if exist "%DESCLOC%" goto deployService
        ) else (
                echo Please provide a valid .wsm file to deploy
                goto ERR
)
echo.
echo Unable to locate file "%DESCLOC%"
echo.
goto ERR

rem Start deploying WSM using the SOAP Admin Web Call
:deployService
        "%JAVA_HOME%\bin\java.exe" -Dorg.apache.cxf.Logger=org.apache.commons.logging.impl.NoOpLog -DInstall.Dir="%SCHEMADIR%" -cp "%CLASSPATH%" %DNS_OPTS% -Dcatalina.home="%CATALINA_HOME%" -Dcatalina.base="%CATALINA_BASE%" -Dpsc.as.http.port=%PSC_HTTP_PORT% -Dpsc.as.https.port=%PSC_HTTPS_PORT% %DEPLOYMGRCLASS% -artifact "%DESCLOC%"  -service %APPNAME% -deploy
        set _exitstatus=%errorlevel%
        goto end

        
rem Start undeploying Service using the SOAP Admin Web Call
:undeployService
    "%JAVA_HOME%\bin\java.exe" -Dorg.apache.cxf.Logger=org.apache.commons.logging.impl.NoOpLog -DInstall.Dir="%SCHEMADIR%" -cp "%CLASSPATH%" %DNS_OPTS% -Dcatalina.home="%CATALINA_HOME%" -Dcatalina.base="%CATALINA_BASE%" -Dpsc.as.http.port=%PSC_HTTP_PORT% -Dpsc.as.https.port=%PSC_HTTPS_PORT% %DEPLOYMGRCLASS% -artifact "%PAARNAME%"  -service %APPNAME% -undeploy
    set _exitstatus=%errorlevel%
    goto end

rem List out the correct options to run the utility
:doUsage
    echo Utility to deploy or undeploy a SOAP service from an OEABL WebApp
    echo.
    echo Usage:  deploySOAP [Descriptor or ServiceName] [OEABL WebApp Name] [Options]
    echo.
    echo Source Descriptor           Path of the Source Descriptor [.wsm] OR
    echo                             Soap Service Name when used with -undeploy
    echo OEABL WebApp Name           Name of the OEABL Web Application
    echo Options                     -undeploy
    echo.
    echo Examples:
    echo Deploy 'test.wsm' to OEABL WebApp named 'ROOT'
    echo     "deploySOAP C:\temp\test.wsm ROOT"
    echo.
    echo Undeploy an existing SOAP service named 'test' from OEABL WebApp 'ROOT'
    echo     "deploySOAP test ROOT -undeploy"
    goto end

:ERR
  set _exitstatus=1

:end
    if defined _removeCatBase (
set CATALINA_BASE=C:\PASOE\SportsDemo
        set _removeCatBase=
    )

exit /b %_exitstatus%
