@echo off
Setlocal EnableDelayedExpansion EnableExtensions
Echo.

echo Перечень съемных накопителей:
echo.
For /F "Skip=2 Tokens=2-4 delims=," %%i In (
 'WMIC DiskDrive Where InterfaceType^="USB" Get Name^,PNPDeviceID^,Model /Value /format:csv 2^>nul'
) do (
    Set AtLeastOneDevice=true
    Call :Get_USB_SN "%%k" Device_SN
    Call :GetPartition "%%j" Drives
    Echo Model: %%i
    Echo %%j
    Echo Disk^(s^):     !Drives!
    Echo Device S/N:         "!Device_SN!"
    Echo.
)
if not defined AtLeastOneDevice Echo Съемных USB накопителей не обнаружено.
Echo.
Echo Перечень жестких дисков:
Echo.
For /F "Skip=2 Tokens=2-4 delims=," %%i In (
 'WMIC DiskDrive Where "InterfaceType^!^='USB'" Get Name^,PNPDeviceID^,Model /Value /format:csv'
) do (
    Call :GetPartition "%%j" Drives
    Call :Get_HDD_SN "%%j" Device_SN
    Echo Model: %%i
    Echo %%j
    Echo Disk^(s^):     !Drives!
    Echo Device S/N:         "!Device_SN!"
    Echo "!Device_SN!">>%~dp0file.txt
    Echo.
)
pause>nul
Goto :eof
Endlocal

:Get_USB_SN
Setlocal
Set "%~2="
Set "PNP=%~1"
Set "PNP=%PNP:\=" "%"
Set "PNP=%PNP:;=" "%"
Set "PNP=%PNP:&=" "%"
Set _Prev=
For %%i in ("%PNP%") do (
 if "!_Prev:~0,4!"=="REV_" (Set "%~2=%%~i"& Exit /B)
 Set "_Prev=%%~i"
)
Endlocal
Exit /B

:Get_HDD_SN
Setlocal
Set "tag=%~1"
Set "tag=%tag:\=\\%"
For /F "UseBackQ skip=2 tokens=2 delims=," %%i In (
 `wmic path Win32_PhysicalMedia where "tag='%tag%'" Get SerialNumber /format:csv`
) do call set "_serial=%%i"
set "_serial=%_serial: =%"
if "%_serial:~39,1%" neq "" Call :Hex_To_String "%_serial%" "_serial"
set "%~2=%_serial%"
Endlocal
Exit /B

:Hex_To_String
SetLocal
Set "x16=%~1"
set n=45
for %%A in (- . / 0 1 2 3 4 5 6 7 8 9) do set s.!n!=%%A& set /a n+=1
set n=65
for %%A in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set s.!n!=%%A& set /a n+=1
set n=97
for %%A in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set s.!n!=%%A& set /a n+=1
set xs=
for /L %%C in (0,4,8184) do (
 if "!x16:~%%C,1!"=="" goto _ex_Hex
 set /A cplus=%%C+2
 call set /A x10=0x%%x16:~!cplus!,2%%
 call set xs=!xs!%%s.!x10!%%
 set /A x10=0x!x16:~%%C,2!
 call set xs=!xs!%%s.!x10!%%
)
:_ex_Hex
EndLocal& set "%~2=%xs%"& Exit /B

:GetPartition
Setlocal
Set "%~2="
For /F "skip=2 delims==, tokens=3,6-7" %%i In (
 'WMIC path Win32_DiskDriveToDiskPartition get /format:csv'
) do (
 if %%i=="%~1" (
    For /F "skip=2 delims==, tokens=3-4,7" %%I In (
      'WMIC path Win32_LogicalDiskToPartition get Antecedent^,Dependent /format:csv'
    ) do (
      if "%%I,%%J"=="%%j,%%k" Set "%~2=!%~2! %%K"
  )))
Endlocal
Exit /B
