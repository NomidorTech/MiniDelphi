@echo off
:: Executa o Sudoku com o runtime genérico
:: Runs Sudoku using the generic runtime
:: Requer pyrun.exe na mesma pasta / Requires pyrun.exe in the same folder

cd /d "%~dp0"

if not exist "pyrun.exe" (
    echo.
    echo ERRO: pyrun.exe nao encontrado nesta pasta.
    echo ERROR: pyrun.exe not found in this folder.
    echo.
    echo Compile PyRun.dpr no Delphi primeiro.
    echo Compile PyRun.dpr in Delphi first.
    pause
    exit /b 1
)

if not exist "sudoku.mdp" (
    echo.
    echo ERRO: sudoku.mdp nao encontrado nesta pasta.
    echo ERROR: sudoku.mdp not found in this folder.
    pause
    exit /b 1
)

pyrun.exe sudoku.mdp
