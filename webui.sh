#!/usr/bin/env bash
#################################################
# 请不要对此文件进行任何更改，请改变webui-user.sh中的变量 #
#################################################

# 如果在 macOS 上运行，请从webui-macos-env.sh加载默认值
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [[ -f webui-macos-env.sh ]]
        then
        source ./webui-macos-env.sh
    fi
fi

# 从webui-user.sh文件中读取变量
# shellcheck source=/dev/null
if [[ -f webui-user.sh ]]
then
    source ./webui-user.sh
fi

# 设置默认值

# 安装目录，不包含尾部斜杠
if [[ -z "${install_dir}" ]]
then
    install_dir="$(pwd)"
fi

# 子目录的名称（默认为stable-diffusion-webui）
if [[ -z "${clone_dir}" ]]
then
    clone_dir="stable-diffusion-webui"
fi

# python3可执行文件
if [[ -z "${python_cmd}" ]]
then
    python_cmd="python3"
fi

# git可执行文件
if [[ -z "${GIT}" ]]
then
    export GIT="git"
fi

# python3虚拟环境的路径，不包含尾部斜杠（默认为${install_dir}/${clone_dir}/venv）
if [[ -z "${venv_dir}" ]]
then
    venv_dir="venv"
fi

if [[ -z "${LAUNCH_SCRIPT}" ]]
then
    LAUNCH_SCRIPT="launch.py"
fi

# 默认情况下，此脚本不能以root身份运行
can_run_as_root=0

# 读取webui.sh脚本的命令行标志
while getopts "f" flag > /dev/null 2>&1
do
    case ${flag} in
        f) can_run_as_root=1;;
        *) break;;
    esac
done

# 禁用Sentry日志记录
export ERROR_REPORTING=FALSE

# 在Debian/Ubuntu上不重新安装已存在的pip软件包
export PIP_IGNORE_INSTALLED=0

# 美观的打印分隔线
delimiter="################################################################"

printf "\n%s\n" "${delimiter}"
printf "\e[1m\e[32mstable-diffusion + Web UI安装脚本\n"
printf "\e[1m\e[34m在Debian 11 (Bullseye)上测试通过\e[0m"
printf "\n%s\n" "${delimiter}"

# 禁止以root身份运行
if [[ $(id -u) -eq 0 && can_run_as_root -eq 0 ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "\e[1m\e[31m错误：此脚本不能以root身份运行，正在中止...\e[0m"
    printf "\n%s\n" "${delimiter}"
    exit 1
else
    printf "\n%s\n" "${delimiter}"
    printf "运行在 \e[1m\e[32m%s\e[0m 用户" "$(whoami)"
    printf "\n%s\n" "${delimiter}"
fi

if [[ $(getconf LONG_BIT) = 32 ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "\e[1m\e[31m错误：不支持运行在32位操作系统上\e[0m"
    printf "\n%s\n" "${delimiter}"
    exit 1
fi

if [[ -d .git ]]
then
    printf "\n%s\n" "${delimiter}"
    printf "已经克隆仓库，使用它作为安装目录"
    printf "\n%s\n" "${delimiter}"
    install_dir="${PWD}/../"
    clone_dir="${PWD##*/}"
fi

<<<<<<< Updated upstream
# Check prerequisites
=======
# 检查先决条件
>>>>>>> Stashed changes
gpu_info=$(lspci 2>/dev/null | grep VGA)
case "$gpu_info" in
    *"Navi 1"*|*"Navi 2"*) export HSA_OVERRIDE_GFX_VERSION=10.3.0
    ;;
    *"Renoir"*) export HSA_OVERRIDE_GFX_VERSION=9.0.0
        printf "\n%s\n" "${delimiter}"
        printf "实验性支持Renoir：确保至少有4GB的VRAM和10GB的内存，或者启用CPU模式：--use-cpu all --no-half"
        printf "\n%s\n" "${delimiter}"
    ;;
    *)
    ;;
esac
if echo "$gpu_info" | grep -q "AMD" && [[ -z "${TORCH_COMMAND}" ]]
then
    export TORCH_COMMAND="pip install torch==2.0.1+rocm5.4.2 torchvision==0.15.2+rocm5.4.2 --index-url https://download.pytorch.org/whl/rocm5.4.2"
fi

for preq in "${GIT}" "${python_cmd}"
do
    if ! hash "${preq}" &>/dev/null
    then
        printf "\n%s\n" "${delimiter}"
        printf "\e[1m\e[31m错误：%s未安装，正在中止...\e[0m" "${preq}"
        printf "\n%s\n" "${delimiter}"
        exit 1
    fi
done

if ! "${python_cmd}" -c "import venv" &>/dev/null
then
    printf "\n%s\n" "${delimiter}"
    printf "\e[1m\e[31m错误：未安装python3-venv，正在中止...\e[0m"
    printf "\n%s\n" "${delimiter}"
    exit 1
fi

cd "${install_dir}"/ || { printf "\e[1m\e[31m错误：无法切换到 %s/ 目录，正在中止...\e[0m" "${install_dir}"; exit 1; }
if [[ -d "${clone_dir}" ]]
then
    cd "${clone_dir}"/ || { printf "\e[1m\e[31m错误：无法切换到 %s/%s/ 目录，正在中止...\e[0m" "${install_dir}" "${clone_dir}"; exit 1; }
else
    printf "\n%s\n" "${delimiter}"
    printf "克隆stable-diffusion-webui仓库"
    printf "\n%s\n" "${delimiter}"
    "${GIT}" clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "${clone_dir}"
    cd "${clone_dir}"/ || { printf "\e[1m\e[31m错误：无法切换到 %s/%s/ 目录，正在中止...\e[0m" "${install_dir}" "${clone_dir}"; exit 1; }
fi

if [[ -z "${VIRTUAL_ENV}" ]];
then
    printf "\n%s\n" "${delimiter}"
    printf "创建并激活Python虚拟环境"
    printf "\n%s\n" "${delimiter}"
    cd "${install_dir}"/"${clone_dir}"/ || { printf "\e[1m\e[31m错误：无法切换到 %s/%s/ 目录，正在中止...\e[0m" "${install_dir}" "${clone_dir}"; exit 1; }
    if [[ ! -d "${venv_dir}" ]]
    then
        "${python_cmd}" -m venv "${venv_dir}"
        first_launch=1
    fi
    # shellcheck source=/dev/null
    if [[ -f "${venv_dir}"/bin/activate ]]
    then
        source "${venv_dir}"/bin/activate
    else
        printf "\n%s\n" "${delimiter}"
        printf "\e[1m\e[31m错误：无法激活Python虚拟环境，正在中止...\e[0m"
        printf "\n%s\n" "${delimiter}"
        exit 1
    fi
else
    printf "\n%s\n" "${delimiter}"
    printf "已经激活Python虚拟环境：%s" "${VIRTUAL_ENV}"
    printf "\n%s\n" "${delimiter}"
fi

# 尝试在Linux上使用TCMalloc
prepare_tcmalloc() {
    if [[ "${OSTYPE}" == "linux"* ]] && [[ -z "${NO_TCMALLOC}" ]] && [[ -z "${LD_PRELOAD}" ]]; then
        TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
        if [[ ! -z "${TCMALLOC}" ]]; then
            echo "正在使用TCMalloc：%s" "${TCMALLOC}"
            export LD_PRELOAD="${TCMALLOC}"
        else
            printf "\e[1m\e[31m无法找到TCMalloc（改善CPU内存使用情况）\e[0m\n"
        fi
    fi
}

if [[ ! -z "${ACCELERATE}" ]] && [ ${ACCELERATE}="True" ] && [ -x "$(command -v accelerate)" ]
then
    printf "\n%s\n" "${delimiter}"
<<<<<<< Updated upstream
    printf "Accelerating launch.py..."
=======
    printf "正在加速launch.py..."
>>>>>>> Stashed changes
    printf "\n%s\n" "${delimiter}"
    prepare_tcmalloc
    exec accelerate launch --num_cpu_threads_per_process=6 "${LAUNCH_SCRIPT}" "$@"
else
    printf "\n%s\n" "${delimiter}"
<<<<<<< Updated upstream
    printf "Launching launch.py..."
=======
    printf "正在启动launch.py..."
>>>>>>> Stashed changes
    printf "\n%s\n" "${delimiter}"
    prepare_tcmalloc
    exec "${python_cmd}" "${LAUNCH_SCRIPT}" "$@"
fi
