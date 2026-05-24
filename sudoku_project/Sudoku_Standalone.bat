@echo off
:: Executa o Sudoku com o executável standalone dedicado
:: Runs Sudoku using the dedicated standalone executable

cd /d "%~dp0"

if not exist "Sudoku.exe" (
    echo.
    echo ERRO: Sudoku.exe nao encontrado nesta pasta.
    echo ERROR: Sudoku.exe not found in this folder.
    echo.
    echo Compile Sudoku.dpr no Delphi primeiro.
    echo Compile Sudoku.dpr in Delphi first.
    pause
    exit /b 1
)

Sudoku.exe
