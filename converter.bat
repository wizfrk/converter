@echo off

::-----------------------------------------------------------
:: Converter
:: By Wizfrk
::
:: Usage: converter.bat "<files and/or folders>"
::
:: 
:: Program log and queue files are stored in "<user folder>\AppData\Roaming\"
::
::-----------------------------------------------------------

::-----------------------------------------------------------
:: Variables
::-----------------------------------------------------------

:: Queue file
set que=%APPDATA%\%~n0.queue.txt

:: Hanbrake
::-----------------------------------------------------------
:: Location of HandbrakeCLI.exe (https://build.handbrake.fr/view/Nightlies/job/Windows/)
:: 32 bit
set hblci="%~dp0lib\HanBrakeCLI\HandBrakeCLI.exe"
:: 64 bit
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set hblci="%~dp0lib64\HandBrakeCLI\HandBrakeCLI.exe"

:: Handbrake options (https://trac.handbrake.fr/wiki/CLIGuide 
set hbopt=--preset "Normal" -s 1  --subtitle-default --subtitle-burn --optimize

:: Lame
::-----------------------------------------------------------
:: Location of lame.exe
:: 32 bit
set lame="%~dp0lib\lame\lame.exe"
:: 64 bit
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set lame="%~dp0lib64\lame\lame.exe"

:: Lame options (http://lame.cvs.sourceforge.net/viewvc/lame/lame/USAGE)
set lameopt=

:: Proper Formats (extensions)
set gdx=.mp3 .mp4
:: Video Formats (extensions)
set vidx=.mkv .avi .m2ts .wmv .m4v
:: Audio Formats (extensions)
set audx=.flac .wav .wma .m4a

::-----------------------------------------------------------
:: Initialize
::-----------------------------------------------------------

:: Make program files if they don't exist.
if NOT exist "%que%" echo. 2>"%que%"

::-----------------------------------------------------------
:: Main Program
::-----------------------------------------------------------

:start

if "%~1"=="update" (
call :print "Updating binaries."
%hblci% -u
goto end
)

if "%~1"=="" ( 
call :print "No input."
goto check
)

:dragdroploop
call :handleinput "%~1"
shift
if not "%~1"=="" goto dragdroploop

:check
call :checkqueue

:end 
call :print "Exiting."
goto:eof

::-----------------------------------------------------------
:: Functions
::-----------------------------------------------------------

:checkqueue
:: Get first line.
call :print "Checking queue."

for /f "delims=" %%f in (%que%) do (

call :print "Found queued item: %%~f"
call :handleinput "%%~f"
call :deleteline %que%
)
call :print "Nothing in que."
goto:eof


:handleinput
:: Check if exists and call apriopriate function to handle extension.
call :print "Checking if %~1 exists."

if exist "%~1" (
call :print "It does!"

call :print "Checking %~1 type."

if exist "%~1\*" (
goto :isdirectory
)

for %%i in (%gdx%) do ( 
if "%~x1"=="%%i" goto properformat
)
for %%i in (%vidx%) do ( 
if "%~x1"=="%%i" goto isvideo
)
for %%i in (%audx%) do (
if "%~x1"=="%%i" goto isaudio
)

:isdirectory
call :print "Input is a directory."
call :queue "%~1"
goto:eof

:badformat 
call :print "File type %~x1 not compatible with script."
goto:eof

:properformat
call :print "File type %~x1 is already the proper format."
goto:eof

:isvideo 
call :print "File is video."
call :convertmp4 "%~1"
goto:eof

:isaudio 
call :print "File is audio."
call :convertmp3 "%~1"
goto:eof
)

call :print "%~1 does not exist."
goto:eof

:convertmp4
:: Convert input file to mp4 format.
call :print "Trying to convert %~1 to %~n1.mp4."

if exist "%~dpn1.mp4" (
call :print "%~n1.mp4 decected. Delete to re-encode."
goto:eof
)

if "%~x1"==".m4v" (
ren "%~1" "%~n1.mp4"
call :print "%~1 renamed %~n1.mp4"
goto:eof
)

tasklist /FI "IMAGENAME eq HandBrakeCLI.exe" 2>NUL | find /I /N "HandbrakeCLI.exe">NUL
if "%ERRORLEVEL%"=="0" (
call :print "A Handbreake process detected, adding %~1 to queue."
call :queue "%~1"
goto:eof
)
call :print "Using Handbrake with: %hbopt%"
%hblci% -i "%~1" -o "%~dpn1.mp4" %hbopt%
goto:eof

:convertmp3
:: Convert input file to mp3 format.
call :print "Trying to convert %~1 to %~dpn1.mp3."

if exist "%~dpn1.mp3" (
call :print "%~dpn1.mp3 decected. Delete to re-encode."
goto:eof
)

tasklist /FI "IMAGENAME eq lame.exe" 2>NUL | find /I /N "lame.exe">NUL
if "%ERRORLEVEL%"=="0" (
call :print "A lame.exe process detected, adding %~1 to queue."
call :queue "%~1"
goto:eof
)

call :print "Using Lame with: %lameopt%"
%lame% %lameopt% "%~1" "%~dpn1.mp3"
goto:eof

:print
echo [%date% %time%] %~1
goto:eof

:addline
:: Add line to end of queue file.
call :print "Adding %~1 to the end of %~2"
echo "%~1">> "%~2"
goto:eof

:deleteline
:: Delete first line in queue file.
call :print "Removing first line from %~1"
more +1 "%~1" > "%~1.tmp"
move "%~1.tmp" "%~1"
goto:eof


:queue
:: If Directory write all files to the end of queue.
call :print "Attempting to queue %~1"

if exist "%~1\*" (
call :print "%~1 is directory. Adding its contents to queue."
for /R "%~1" %%i in (*.*) do (
call :print "Adding %%~i to queue."
call :addline "%%~i" "%que%"
))

:: If input is a file, add to the end of queue.
if exist "%~1" (
call :print "Adding %~1 to queue."
call :addline "%~1" "%que%" 
)

goto:eof
