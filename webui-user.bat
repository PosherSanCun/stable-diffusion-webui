
@echo off

rem 清空PYTHON变量，用于指定Python可执行文件的路径
set PYTHON=

rem 清空GIT变量，用于指定Git可执行文件的路径
set GIT=

rem 清空VENV_DIR变量，用于指定venv环境的目录路径
set VENV_DIR=

rem 清空COMMANDLINE_ARGS变量，用于指定webui.py的命令行参数
set COMMANDLINE_ARGS=

rem 调用webui.bat脚本
call webui.bat