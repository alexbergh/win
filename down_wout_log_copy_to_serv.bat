echo off
setlocal enabledelayedexpansion

chcp 65001 >nul

:: Synchronization Options
set "sourceDir=\\"
set "targetDir=C:"

:: Path 7-Zip
set "sevenZipPath=C:\Program Files\7-Zip\7z.exe"

:: Synchronization of directories with percentage progress display
echo Синхронизация каталогов
robocopy "%sourceDir%" "%targetDir%" /E /Z /R:3 /W:1 /ETA /XO

:: Creating a zip archive with the date
echo Создание zip-архива
set "dateStamp=%date:~6,4%-%date:~3,2%-%date:~0,2%"
set "zipFileName=KUU_%dateStamp%.zip"
set "zipFilePath=%targetDir%\%zipFileName%"

:: Checking for an old archive and deleting it
if exist "%zipFilePath%" (
    echo Удаление старого архива
    del "%zipFilePath%"
)

:: Creating a new archive using Zip
echo Создание нового архива
"%sevenZipPath%" a -t7z "%zipFilePath%" "%targetDir%\*" -mx=9 -mhe=on

:: Server path
set "serverPath=\\"

:: Checking for an old archive on the server and deleting it
set "serverZipFilePath=%serverPath%\%zipFileName%"
if exist "%serverZipFilePath%" (
    echo Удаление старого архива на сервере
    del "%serverZipFilePath%"
)

:: Copying the archive to the server
echo Копирование архива на сервер
robocopy "%targetDir%" "%serverPath%" "%zipFileName%" /Z /R:3 /W:1 /NP

echo Завершено.
pause