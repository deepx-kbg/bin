#!/bin/python3

# Copyright (C) 2024  DeepX Co., Ltd.

import os
import subprocess
import sys

GH_FW_REPO = "git@gh.deepx.ai:deepx/rt_fw_m1a_repo.git"
GH_DRIVER_REPO = "git@gh.deepx.ai:deepx/dx_rt_npu_linux_driver.git"
GH_RT_REPO = "git@gh.deepx.ai:deepx/dx_rt.git"
GH_APP_REPO = "git@gh.deepx.ai:deepx/dx_app.git"

home_dir = ""

def run_command(command, cwd=None):
    """Run a shell command and handle errors."""
    try:
        result = subprocess.run(command, check=True, shell=True, cwd=cwd)
        return result
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {command}\n{e}")
        sys.exit(1)

def clone_or_update_repo(repo_url, target_dir):
    """Clone or update a Git repository."""
    if not os.path.exists(target_dir):
        os.makedirs(target_dir, exist_ok=True)
        os.chdir(target_dir)
        run_command(f"git clone --recurse-submodules {repo_url} .")
    else:
        os.chdir(target_dir)
        run_command("git pull --recurse-submodules")

def build_firmware(board):
    """Build the firmware."""
    run_command(f"./m1a_setup.py -t asic -o {board}")

def build_runtime():
    """Build the runtime."""
    run_command("./build.sh --clean")
    os.chdir('python_package')
    run_command("pip install .")

def build_driver():
    """Build the NPU Linux driver."""
    run_command("./build.sh -c clean")
    run_command("./build.sh -f debugfs")
    run_command("sudo ./build.sh -c install")
    run_command("sudo ./module_insert.sh")

def build_app():
    """Build the App. """
    run_command("./install.sh --opencv")
    run_command("./build.sh --clean")

def main(package, board='mdot2'):
    global home_dir
    home_dir = os.path.expanduser("~/sdk")

    os.chdir(home_dir)

    if package == 'firmware':
        clone_or_update_repo(GH_FW_REPO, 'deepx_firmware')
        os.chdir(f'{home_dir}/deepx_firmware')
        build_firmware(board)

    elif package == 'runtime':
        clone_or_update_repo(GH_RT_REPO, 'deepx_runtime')
        os.chdir(f'{home_dir}/deepx_runtime')
        build_runtime()

    elif package == 'driver':
        clone_or_update_repo(GH_DRIVER_REPO, 'deepx_host_driver')
        os.chdir(f'{home_dir}/deepx_host_driver/modules')
        build_driver()

    elif package == 'app':
        clone_or_update_repo(GH_APP_REPO, 'deepx_app')
        os.chdir(f'{home_dir}/deepx_app')
        build_app()
    else:
        print("Invalid package specified. Use 'firmware', 'runtime', 'driver' or 'app'.")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python sdk.py <package> [<board>]")
        sys.exit(1)

    package_name = sys.argv[1]
    board_name = sys.argv[2] if len(sys.argv) > 2 else 'mdot2'
    main(package_name, board_name)
