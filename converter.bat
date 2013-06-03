@echo off
::-----------------------------------------------------------
:: Converter
:: By Wizfrk
::
:: Usage: converter.bat "<file or folder>"
::
:: To add to utorrent: Options>Preferences>Advanced>Run Program:
:: cmd.exe /c start /min "<Path to Script>\conveter.bat" "%D\%F" ^& exit
::-----------------------------------------------------------

::-----------------------------------------------------------
:: Variables
::-----------------------------------------------------------

:: Queue file
set que="%APPDATA%\%~n0.queue"

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

::-----------------------------------------------------------
:: Initialize
::-----------------------------------------------------------

if "%~1"=="update" %hblci% -u

:: Make queue file if it dosn't exist.
if NOT exist %que% echo. 2>%que%
::-----------------------------------------------------------
:: Main Program
::-----------------------------------------------------------

:start

:: No input handler (used for queue resume and testing)
if "%~1"=="" ( 
echo No input.
goto checkqueue
)

:queue
:: If input is a file, add to the end of queue.
if exist "%~1" (
call :addline "%~1"
)
:: If Directory write all files to the end of queue.
if exist "%~1\*" (
echo Directory %~1\ exists.
echo Adding contents of %~1 to queue.
for /r "%~1" %%i in (*) do (
call :addline %%i
)
)

:checkqueue
:: Get first line.
echo Checking queue.

set /p line=<%que%

if "%line%"=="" (
echo Nothing in queue.
goto end
)

call :handleinput "%line%"
call :deleteline %que%

set line=

goto checkqueue

:end
echo Exiting.
goto:eof

::-----------------------------------------------------------
:: Functions
::-----------------------------------------------------------

:addline
:: Add line to end of queue file.
echo Adding %~1 to queue.
echo %~1>> %que%
goto:eof

:deleteline
:: Delete first line in queue file.
more +1 "%~1" > "%~1.tmp"
move "%~1.tmp" "%~1"
goto:eof

:handleinput
:: Check if exists and call apriopriate function to handle extension.
echo Trying to handle %~1
if exist "%~1" (
:: Compatible formats.
if "%~x1"==".mp3" echo Already proper format.
if "%~x1"==".mp4" echo Already proper format.

if "%~x1"==".m4v" do ren "%~1" "%~n1.mp4"
if "%~x1"==".mkv" call :convertmp4 "%~1" 
if "%~x1"==".avi" call :convertmp4 "%~1"
if "%~x1"==".m2ts" call :convertmp4 "%~1"
if "%~x1"==".wmv" call :convertmp4 "%~1"

if "%~x1"==".flac" call :convertmp3 "%~1"
if "%~x1"==".wav" call :convertmp3 "%~1"
if "%~x1"==".wma" call :convertmp3 "%~1"
if "%~x1"==".m4a" call :convertmp3 "%~1"

echo File format "%~x1" not handled by converter.
goto:eof
)
echo "%1" does not exist.

:convertmp4
echo Trying to convert file to MP4.
tasklist /FI "IMAGENAME eq HandBrakeCLI.exe" 2>NUL | find /I /N "HandbrakeCLI.exe">NUL
if "%ERRORLEVEL%"=="0" (
echo A Handbreake process detected, aborting.
exit
)
if exist "%~dpn1.mp4" (
echo %~n1.mp4 decected. Delete to re-encode.
goto:eof
)
echo %hblci% -i "%~1" -o "%~dpn1.mp4" %hbopt%
pause
%hblci% -i "%~1" -o "%~dpn1.mp4" %hbopt%
goto:eof

:convertmp3
echo Trying to convert file to MP3.
tasklist /FI "IMAGENAME eq lame.exe" 2>NUL | find /I /N "lame.exe">NUL
if "%ERRORLEVEL%"=="0" (
echo A lame.exe process detected, aborting.
exit
)
if exist "%~dpn1.mp3" (
echo %~dpn1.mp3 decected. Delete to re-encode.
goto:eof
)
%lame% %lameopt% "%~1" "%~dpn1.mp3"
goto:eof
