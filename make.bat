@ECHO OFF

:: "Makefile" for Windows
set "installDir=.\lib"
set "inspy=0"
set "inseasy=0"
set "inspip=0"
set "ins=0"

if "%1" == "" GOTO check_python
if "%1" == "setup" GOTO check_python
if "%1" == "develop" GOTO setup_develop
if "%1" == "doc" GOTO doc
if "%1" == "test" GOTO test
if "%1" == "coverage" GOTO coverage
if "%1" == "clean" GOTO clean
GOTO help

:check_python
if %ins%==1 PAUSE
set "ins=0"
set "arch=False"
if not exist "C:\Python27\python.exe" (
    GOTO python
    set "arch=True"
) else (
    :: Check that python is 32bit
    for /f %%i in ('C:\Python27\python.exe -c "import platform;print bool(platform.architecture()[0] == '32bit')"') do (set "arch=%%i")
)
if %arch% == False GOTO arch_error
if not exist "C:\Python27\Scripts\pip.exe" GOTO pip
if not exist "C:\Python27\Scripts\easy_install.exe" GOTO easyinstall
GOTO check_path

:python
echo.
if %inspy% == 1 GOTO end
echo.Installing python...
%installDir%\python-2.7.5.msi
IF ERRORLEVEL 1 GOTO python_error
echo.python installed successfully.
set "inspy=1"
rem Windows XP does not have setx
if exist %SystemRoot%\system32\setx.exe GOTO check_python
echo.
echo.On Windows XP "C:\Python27;C:\Python27\Scripts;" has to be appended to the PATH environment variable.
GOTO check_python

:easyinstall
if %inseasy% == 1 GOTO end
echo.Adding python to environment variables...
echo.
echo.Installing setuptools...
call %installDir%\setuptools-0.6c11.win32-py2.7.exe
IF ERRORLEVEL 1 GOTO setup_error
echo.setuptools installed successfully.
echo.
set "inseasy=1"
set "ins=1"
GOTO check_python

:pip
if %inspip%==1 GOTO end
echo.
echo.Installing pip...
call %installDir%\pip-1.5.4.win32-py2.7.exe
IF ERRORLEVEL 1 GOTO pip_error
echo.pip installed successfully.
echo.
set "inspip=1"
set "ins=1"
GOTO check_python

:check_path
echo.
reg query HKEY_CURRENT_USER\Environment /v "path" > nul 2>&1
if errorlevel 1 goto nopath
set "test="
for /f "tokens=*" %%i in ('reg query HKEY_CURRENT_USER\Environment /v "path"') do (
    set "test=%test%%%i"
)
set "test=%test:~18%"
set "searchVal=python27"
@setlocal enableextensions enabledelayedexpansion
if not "x!test:%searchVal%=!"=="x%test%" GOTO setup
endlocal
echo.Adding python to environment variables...
echo.
setx PATH "C:\Python27;C:\Python27\Scripts;%test%;"
rem Backward compatibility for Windows XP
set "PATH=C:\Python27;C:\Python27\Scripts;%test%;"
echo.
GOTO setup

:nopath
echo.
echo.Adding python to environment variables...
setx PATH "C:\Python27;C:\Python27\Scripts;"
rem Backward compatibility for Windows XP
set "PATH=C:\Python27;C:\Python27\Scripts;"
echo.
GOTO setup

:setup
ECHO.
ECHO.Installing pyvxl...
ECHO.
call pip3 install .
IF ERRORLEVEL 1 GOTO setup_error
ECHO.
ECHO.pyvxl installed correctly
echo.
ECHO.
GOTO clean

:setup_develop
ECHO.
ECHO.Installing pyvxl for development...
ECHO.
call pip3 install -e .
IF ERRORLEVEL 1 GOTO setup_error
ECHO.
ECHO.pyvxl installed correctly
echo.
ECHO.
GOTO clean

:doc
ECHO.
ECHO.Generating documentation...
ECHO.
C:\Python27\python.exe C:\Python27\Scripts\epydoc.py -v --config setup.cfg
START ..\documentation\apidocs\index.html
IF ERRORLEVEL 1 GOTO error
GOTO end

:test
ECHO.
ECHO.Running unit and integration tests...
ECHO.
nosetests --stop
IF ERRORLEVEL 1 GOTO error
GOTO end

:coverage
ECHO.
ECHO.Opening coverage report...
ECHO.
START cover\index.html
GOTO end

:clean
DEL pyvxl\*.pyc 2>NUL
GOTO end

:help
echo.No rule to make target '%1'
goto error

:arch_error
echo.
echo.64bit Python installation found!
echo.Please uninstall python and rerun the batch file
echo.
PAUSE
goto error

:setup_error
echo.
echo.pyvxl did not install successfully.
echo.
echo.Try reruning the batch file.
echo.
PAUSE
GOTO error

:python_error
echo.
echo.python did not install successfully.
echo.
PAUSE
GOTO error

:setup_error
echo.
echo.setuptools did not install successfully.
echo.
PAUSE
GOTO error

:pip_error
echo.
echo.pip did not install successfully.
echo.
PAUSE
GOTO error

:error
exit /b 1


:end
exit /b 0
