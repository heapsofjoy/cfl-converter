@echo off
title CFL Converter Product ID and Output Name Input

:: Set the directory for the executables
set "baseDir=DO NOT DELETE"
set "converterExe=%baseDir%\cfl-converter-win.exe"
set "sevenZipExe=%baseDir%\7z\7z.exe"

:: Create the CHKN folder if it doesn't exist
if not exist "CHKN" (
    mkdir "CHKN"
)

:: Function to display the main menu
:menu
echo 1. Convert and extract with 7-Zip
echo 2. Convert only
echo 3. Exit
set /p choice=Please select an option (1-3): 

if "%choice%"=="1" goto convert_and_extract
if "%choice%"=="2" goto convert_only
if "%choice%"=="3" exit
echo Invalid choice, please try again.
goto menu

:convert_and_extract
:: Get the Product ID from the user
echo Please enter the Product ID:
set /p productId=Product ID: 

:: Get the output file name from the user
echo Please enter the desired output file name (without extension):
set /p outputName=Output Name: 

:: Ask user if they want to delete the .chkn file after extraction
set /p deleteChoice=Do you want to delete the .chkn file after extraction? (Y/N): 

cls

:: Run the cfl-converter program
echo Running the cfl-converter program...
"%converterExe%" --products %productId%

:: Check if the conversion was successful by looking for the original .chkn file
if not exist "%productId%.chkn" (
    echo The file "%productId%.chkn" was not created. Please check the Product ID.
    pause
    goto end
)

:: Rename the output file from "productId.chkn" to "outputName - productId.chkn"
set "renamedChknFile=%outputName% - %productId%.chkn"
ren "%productId%.chkn" "%renamedChknFile%"

:: Check if renaming was successful before proceeding
if errorlevel 1 (
    echo Failed to rename the file to "%renamedChknFile%". Please check if "%productId%.chkn" exists.
    pause
    goto end
)

:: Move the renamed .chkn file to the CHKN folder
move "%renamedChknFile%" "CHKN\"

:: Check if the move was successful
if errorlevel 1 (
    echo Failed to move "%renamedChknFile%" to the CHKN folder.
    pause
    goto end
)

:: Extract the renamed .chkn file into a folder with the same name using 7-Zip
echo Extracting "CHKN\%renamedChknFile%" into a folder with the same name...
"%sevenZipExe%" x "CHKN\%renamedChknFile%" -o"%outputName%"

:: Check if extraction was successful
if errorlevel 1 (
    echo Extraction failed. Please ensure that "CHKN\%renamedChknFile%" exists.
    pause
    goto end
)

:: Delete the .chkn file if the user chose to do so
if /i "%deleteChoice%"=="Y" (
    del "CHKN\%renamedChknFile%"
    echo CHKN\%renamedChknFile% has been deleted.
) else (
    echo CHKN\%renamedChknFile% has not been deleted.
)

:: Ask user if they want to open the extracted directory in Explorer
set /p openChoice=Do you want to open the extracted directory in Explorer? (Y/N): 
if /i "%openChoice%"=="Y" (
    start "" "%outputName%"
)

:: Pause to keep the command window open after completion
pause
goto ask_restart

:convert_only
:: Get the Product ID from the user
echo Please enter the Product ID:
set /p productId=Product ID: 

:: Get the output file name from the user
echo Please enter the desired output file name (without extension):
set /p outputName=Output Name: 

:: Ask user if they want to delete the .chkn file after conversion
set /p deleteChoice=Do you want to delete the .chkn file after conversion? (Y/N): 

cls

:: Run the cfl-converter program
echo Running the cfl-converter program...
"%converterExe%" --products %productId%

:: Check if the conversion was successful by looking for the original .chkn file
if not exist "%productId%.chkn" (
    echo The file "%productId%.chkn" was not created. Please check the Product ID.
    pause
    goto end
)

:: Rename the output file from "productId.chkn" to "outputName - productId.chkn"
set "renamedChknFile=%outputName% - %productId%.chkn"
ren "%productId%.chkn" "%renamedChknFile%"

:: Check if renaming was successful before proceeding
if errorlevel 1 (
    echo Failed to rename the file to "%renamedChknFile%". Please check if "%productId%.chkn" exists.
    pause
    goto end
)

:: Move the renamed .chkn file to the CHKN folder
move "%renamedChknFile%" "CHKN\"

:: Check if the move was successful
if errorlevel 1 (
    echo Failed to move "%renamedChknFile%" to the CHKN folder.
    pause
    goto end
)

:: Delete the .chkn file if the user chose to do so
if /i "%deleteChoice%"=="Y" (
    del "CHKN\%renamedChknFile%"
    echo CHKN\%renamedChknFile% has been deleted.
) else (
    echo CHKN\%renamedChknFile% has not been deleted.
)

:: Notify the user that the conversion is complete
echo Conversion completed. CHKN\%renamedChknFile% is ready.

:: Ask user if they want to open the directory in Explorer
set /p openChoice=Do you want to open the directory in Explorer? (Y/N): 
if /i "%openChoice%"=="Y" (
    start "" "%outputName%"
)

pause
goto ask_restart

:ask_restart
:: Ask the user if they want to run the script again
set /p runAgain=Do you want to run the script again? (Y/N): 
if /i "%runAgain%"=="Y" goto menu
exit

:end
exit
