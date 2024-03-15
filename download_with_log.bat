@echo off
setlocal enabledelayedexpansion

chcp 65001 >nul

:: Synchronization Options
set "sourceDir=server_path"
set "targetDir=down_path"

:: Path 7-Zip
set "sevenZipPath=C:\Program Files\7-Zip\7z.exe"

:: Synchronization of directories with percentage progress display
echo Синхронизация каталогов
robocopy "%sourceDir%" "%targetDir%" /E /Z /R:3 /W:1 /NP /ETA /XO /UNICODE /LOG+:"%targetDir%\sync_log.txt"

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
"%sevenZipPath%" a -tzip "%zipFilePath%" "%targetDir%\*" -mx=9 -mhe=on

echo Завершено.
pause