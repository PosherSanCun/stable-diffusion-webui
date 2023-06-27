@echo off

rem 检查PYTHON变量是否定义，如果未定义则将其设置为python
if not defined PYTHON (set PYTHON=python)
rem 检查VENV_DIR变量是否定义，如果未定义则将其设置为当前脚本所在目录下的venv目录
if not defined VENV_DIR (set "VENV_DIR=%~dp0%venv")

<<<<<<< Updated upstream

=======
rem 设置SD_WEBUI_RESTART变量为tmp/restart
set SD_WEBUI_RESTART=tmp/restart
rem 设置ERROR_REPORTING变量为FALSE，禁用错误报告
>>>>>>> Stashed changes
set ERROR_REPORTING=FALSE

rem 创建tmp目录，如果已存在则忽略错误
mkdir tmp 2>NUL

rem 检查Python可执行文件是否能正常运行
%PYTHON% -c "" >tmp/stdout.txt 2>tmp/stderr.txt
if %ERRORLEVEL% == 0 goto :check_pip
echo Couldn't launch python
goto :show_stdout_stderr

:check_pip
rem 检查pip是否可用
%PYTHON% -mpip --help >tmp/stdout.txt 2>tmp/stderr.txt
if %ERRORLEVEL% == 0 goto :start_venv
rem 如果PIP_INSTALLER_LOCATION变量未定义，则显示stdout和stderr的内容
if "%PIP_INSTALLER_LOCATION%" == "" goto :show_stdout_stderr
rem 安装pip
%PYTHON% "%PIP_INSTALLER_LOCATION%" >tmp/stdout.txt 2>tmp/stderr.txt
if %ERRORLEVEL% == 0 goto :start_venv
echo Couldn't install pip
goto :show_stdout_stderr

:start_venv
rem 如果VENV_DIR变量为"-"，则跳过创建venv环境
if ["%VENV_DIR%"] == ["-"] goto :skip_venv
rem 如果SKIP_VENV变量为1，则跳过创建venv环境
if ["%SKIP_VENV%"] == ["1"] goto :skip_venv

rem 检查是否存在venv环境，如果存在则激活该环境
dir "%VENV_DIR%\Scripts\Python.exe" >tmp/stdout.txt 2>tmp/stderr.txt
if %ERRORLEVEL% == 0 goto :activate_venv

rem 创建venv环境
for /f "delims=" %%i in ('CALL %PYTHON% -c "import sys; print(sys.executable)"') do set PYTHON_FULLNAME="%%i"
echo Creating venv in directory %VENV_DIR% using python %PYTHON_FULLNAME%
%PYTHON_FULLNAME% -m venv "%VENV_DIR%" >tmp/stdout.txt 2>tmp/stderr.txt
if %ERRORLEVEL% == 0 goto :activate_venv
echo Unable to create venv in directory "%VENV_DIR%"
goto :show_stdout_stderr

:activate_venv
rem 设置PYTHON变量为venv环境中的Python可执行文件路径
set PYTHON="%VENV_DIR%\Scripts\Python.exe"
echo venv %PYTHON%

:skip_venv
rem 如果ACCELERATE变量为"True"，则跳转到accelerate标签
if [%ACCELERATE%] == ["True"] goto :accelerate
goto :launch

:accelerate
echo Checking for accelerate
rem 设置ACCELERATE变量为venv环境中的accelerate可执行文件路径
set ACCELERATE="%VENV_DIR%\Scripts\accelerate.exe"
rem 如果ACCELERATE文件存在，则跳转到accelerate_launch标签
if EXIST %ACCELERATE% goto :accelerate_launch

:launch
rem 启动应用程序的入口脚本launch.py，并传递命令行参数
%PYTHON% launch.py %*
<<<<<<< Updated upstream
=======
rem 如果存在tmp/restart文件，则跳过创建venv环境
if EXIST tmp/restart goto :skip_venv
>>>>>>> Stashed changes
pause
exit /b

:accelerate_launch
echo Accelerating
rem 使用accelerate启动应用程序的入口脚本launch.py，并设置num_cpu_threads_per_process参数为6
%ACCELERATE% launch --num_cpu_threads_per_process=6 launch.py
<<<<<<< Updated upstream
=======
rem 如果存在tmp/restart文件，则跳过创建venv环境
if EXIST tmp/restart goto :skip_venv
>>>>>>> Stashed changes
pause
exit /b

:show_stdout_stderr

echo.
echo exit code: %errorlevel%

rem 检查stdout.txt文件的大小，如果为0，则不显示stdout内容
for /f %%i in ("tmp\stdout.txt") do set size=%%~zi
if %size% equ 0 goto :show_stderr
echo.
echo stdout:
type tmp\stdout.txt

:show_stderr
rem 检查stderr.txt文件的大小，如果为0，则不显示stderr内容
for /f %%i in ("tmp\stderr.txt") do set size=%%~zi
if %size% equ 0 goto :show_stderr
echo.
echo stderr:
type tmp\stderr.txt

:endofscript

echo.
echo Launch unsuccessful. Exiting.
pause