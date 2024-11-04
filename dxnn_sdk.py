#!/bin/python3

# Copyright (C) 2024  DeepX Co., Ltd.
# v0.1

import os
import glob
import subprocess
import sys
import stat
import shutil
import datetime
import re
import argparse

GH_FW_REPO = "git@gh.deepx.ai:deepx/rt_fw_m1a_repo.git"
GH_DRIVER_REPO = "git@gh.deepx.ai:deepx/dx_rt_npu_linux_driver.git"
GH_RT_REPO = "git@gh.deepx.ai:deepx/dx_rt.git"
GH_APP_REPO = "git@gh.deepx.ai:deepx/dx_app.git"
GH_DOCKER_REPO = "git@gh.deepx.ai:deepx/rt_release_docker.git"


COLORS = {
    'red': '\033[91m',
    'green' : '\033[92m',
    'yellow': '\033[93m',
    'white': '\033[97m',
    'blue': '\033[94m',
    'reset': '\033[0m'
}

def WARN(text):
    color_code = COLORS['yellow']
    print(f"{color_code}{text}{COLORS['reset']}")

def INFO(text):
    color_code = COLORS['white']
    print(f"{color_code}{text}{COLORS['reset']}")

def CRIT(text):
    color_code = COLORS['red']
    print(f"{color_code}{text}{COLORS['reset']}")

def DONE(text):
    color_code = COLORS['green']
    print(f"{color_code}{text}{COLORS['reset']}")

def DEBUG(text):
    color_code = COLORS['blue']
    print(f"{color_code}{text}{COLORS['reset']}")


# --------------------
# start of ChangelogUpdater
# --------------------

class ChangelogUpdater:
    def __init__(self, package_path):
        self.package_path = package_path
        self.version_file = os.path.join(package_path, 'release.ver')
        self.notes_file = os.path.join(package_path, 'RELEASE_NOTES.md')
        self.control_file = os.path.join(package_path, 'debian/control')
        self.changelog_file = os.path.join(package_path, 'debian/changelog')
        self.current_version = self.get_current_version()
        self.new_version = self.get_new_version()

    def get_current_version(self):
        # Read the current version from the changelog file.
        with open(self.changelog_file, 'r') as f:
            first_line = f.readline().strip()
            version = re.search(r'\((.*?)\)', first_line)
            if version:
                return version.group(1)
        return None

    def get_new_version(self):
        # Read the version from the release.ver file.
        try:
            with open(self.version_file, 'r') as f:
                version = f.readline().strip()
                return version.lstrip('v')
        except FileNotFoundError:
            print("Error: release.ver file not found.")
            exit(1)

    def extract_notes(self):
        # Extract the notes for the current version from RELEASE_NOTES.md.
        try:
            with open(self.notes_file, 'r') as f:
                notes = f.read()
        except FileNotFoundError:
            print("Error: RELEASE_NOTES.md file not found.")
            exit(1)

        # Find the section for the current version.
        version_pattern = re.compile(rf'## \[{self.new_version}\] - (\d{{4}}-\d{{2}}-\d{{2}})', re.MULTILINE)
        match = version_pattern.search(notes)

        if match:
            start_index = match.start()
            end_index = notes.find('## [', start_index + 1)

            # If there's no next version section, get until the end of the document.
            end_index = end_index if end_index != -1 else len(notes)

            return notes[start_index:end_index].strip().replace('##', '').replace('###', '').strip()
        else:
            print(f"Warning: No notes found for version {self.new_version}.")
            return ""

    def get_maintainer_info(self):
        # Read the Maintainer information from the debian/control file.
        try:
            with open(self.control_file, 'r') as f:
                for line in f:
                    if line.startswith("Maintainer:"):
                        return line[len("Maintainer:"):].strip()
        except FileNotFoundError:
            print("Error: debian/control file not found.")
            exit(1)

        print("Warning: Maintainer information not found.")
        return "Unknown Maintainer <unknown@example.com>"

    # --------------------
    # Get package name from debian/control
    # --------------------
    def get_package_name(self):
        try:
            with open(self.control_file, 'r') as f:
                for line in f:
                    if line.startswith("Package:"):
                        return line[len("Package:"):].strip()
        except FileNotFoundError:
            print("Error: debian/control file not found.")
            exit(1)

        print("Warning: Package information not found.")
        return "UnknownPackage"

    # --------------------
    # Generate the changelog content
    # --------------------
    def generate_changelog(self, notes, maintainer):
        date = datetime.datetime.now().strftime("%a, %d %b %Y %H:%M:%S %z")
        package_name = self.get_package_name()

        changelog = f"{package_name} ({self.new_version}) unstable; urgency=medium\n\n"
        changelog += "\n".join(f"  * {line.strip()}" for line in notes.splitlines() if line.strip()) + "\n\n"
        changelog += f" -- {maintainer}  {date}\n"

        return changelog

    def update_changelog(self):
        if self.current_version < self.new_version:
            notes = self.extract_notes()
            maintainer = self.get_maintainer_info()
            changelog = self.generate_changelog(notes, maintainer)

            with open(self.changelog_file, "w") as f:
                f.write(changelog)

            print("Changelog updated successfully!")
        else:
            print("No update needed. Current version is up to date.")

# --------------------
# end of ChangelogUpdater
# --------------------

def run_command(command, cwd=None):
    """Run a shell command and handle errors."""
    try:
        result = subprocess.run(command, check=True, shell=True, cwd=cwd)
        return result
    except subprocess.CalledProcessError as e:
        CRIT(f"Error executing command: {command}\n{e}")
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
    """Build the App."""
    run_command("./install.sh --opencv")
    run_command("./build.sh --clean")

def install_docker():
    """Install Docker if not installed."""
    if subprocess.call("command -v docker", shell=True) != 0:
        DEBUG("Installing Docker...")
        run_command("sudo apt update -y")
        run_command("sudo apt-get install -y curl")
        run_command("curl -fsSL https://get.docker.com -o get-docker.sh")
        run_command("sh get-docker.sh")
        run_command(f"sudo usermod -aG docker {os.getenv('USER')}")
        DEBUG("Docker installation complete. Please reboot.")

def make_sdk_debs(sdk_dir, runtime_dir, driver_dir, app_dir):
    """Make debian packages."""
    build_dir = os.path.join(sdk_dir, "build")

    build_deb(runtime_dir, build_dir)
    build_deb(driver_dir, build_dir)
    build_deb(app_dir, build_dir)
    
def get_latest_deb_file(pattern):
    """Return the latest .deb file matching the given pattern."""
    files = glob.glob(pattern)
    if not files:
        return None

    version_pattern = re.compile(r'_(\d+\.\d+\.\d+)_.*\.deb$')

    latest_file = None
    latest_version = None

    for file in files:
        match = version_pattern.search(file)
        if match:
            version = match.group(1)
            if latest_version is None or version > latest_version:
                latest_version = version
                latest_file = file

    return latest_file

def build_deb(package_dir, build_dir):
    """Build the package and place the result in a specified 'packages' directory."""

    if not os.path.exists(package_dir):
        WARN(f"The directory '{package_dir}' does not exist.")
        return
    os.chdir(package_dir)  # change to package directory

    updater = ChangelogUpdater(package_dir)
    updater.update_changelog()

    run_command(f"dpkg-buildpackage -us -uc -b")

    deb_files = glob.glob("../*.deb")
    for deb_file in deb_files:
        target_file = os.path.join(build_dir, os.path.basename(deb_file))

        if os.path.exists(target_file):
            os.remove(target_file)

        shutil.move(deb_file, build_dir)
        DEBUG(f" Moved {deb_file} to {build_dir}")

    # Optionally remove .buildinfo and .changes files
    for file in glob.glob("../*.buildinfo") + glob.glob("../*.changes"):
        os.remove(file)

def copy_latest_deb_file(pattern, target_dir):
    """Copy the latest .deb file to the target directory and create a symlink."""
    # find latest .deb
    files = glob.glob(pattern)
    if not files:
        print("No .deb files found.")
        return None

    latest_file = max(files, key=os.path.getctime)
    target_file = os.path.join(target_dir, os.path.basename(latest_file))

    shutil.copy2(latest_file, target_file)  # file copy
    DEBUG(f"Copied {latest_file} to {target_file}")

    # create symbolic link
    base_name = os.path.splitext(os.path.basename(latest_file))[0]
    symlink_name = os.path.join(target_dir, f"{base_name.split('_')[0]}_latest.deb")  # Change this line

    if os.path.islink(symlink_name) or os.path.exists(symlink_name):
        os.remove(symlink_name)
    os.symlink(os.path.basename(target_file), symlink_name)
    DEBUG(f"Created symlink {symlink_name} -> {os.path.basename(target_file)}")

    return target_file

def build_packages(packages, board, sdk_dir, firmware_dir, runtime_dir, driver_dir, app_dir):
    """Handle building of specified packages."""
    build_dir = os.path.join(sdk_dir, 'build')

    if "firmware" in packages or "all" in packages:
        INFO("Building firmware...")
        clone_or_update_repo(GH_FW_REPO, firmware_dir)
        os.chdir(firmware_dir)
        build_firmware(board)

        firmware_build = os.path.join(firmware_dir, "outputs", "fw.bin")
        firmware_file = os.path.join(build_dir, os.path.basename(f"fw_{board}.bin"))
        shutil.copy2(firmware_build, firmware_file)

    if "runtime" in packages or "rt" in packages or "all" in packages:
        INFO("Building runtime...")
        clone_or_update_repo(GH_RT_REPO, runtime_dir)
        os.chdir(runtime_dir)
        build_runtime()

    if "driver" in packages or "rt" in packages or "all" in packages:
        INFO("Building driver...")
        clone_or_update_repo(GH_DRIVER_REPO, driver_dir)
        os.chdir(os.path.join(sdk_dir, "deepx_host_driver/modules"))
        build_driver()

    if "app" in packages or "rt" in packages or "all" in packages:
        INFO("Building app...")
        clone_or_update_repo(GH_APP_REPO, app_dir)
        os.chdir(app_dir)
        build_app()

def prepare_docker_recipes(sdk_dir, release_dir):
    build_dir = os.path.join(sdk_dir, 'build')

    clone_or_update_repo(GH_DOCKER_REPO, release_dir)
    package_dxrt = os.path.join(release_dir, "packages.dxrt")

    for filename in os.listdir(build_dir):
        if filename.endswith('.bin'):
            source_file = os.path.join(build_dir, filename)
            destination_file = os.path.join(package_dxrt, filename)
            shutil.copy(source_file, destination_file)
            DEBUG(f'Copied: {source_file} to {destination_file}')

    copy_latest_deb_file(os.path.join(build_dir, "libdxrt_*.deb"), package_dxrt)
    copy_latest_deb_file(os.path.join(build_dir, "dx-app_*.deb"), package_dxrt)
    copy_latest_deb_file(os.path.join(build_dir, "dxrt-driver_*.deb"), package_dxrt)

def set_project_home(directory=None):
    if directory:
        sdk_home = os.path.abspath(directory)
    else:
        sdk_home = os.getcwd()

    INFO(f"make project directory under {sdk_home}")
    return sdk_home

def create_env_script(directory):
    env_script_path = os.path.join(directory, 'dxnn_sdk_env.sh')
    with open(env_script_path, 'w') as f:
        f.write(f"#!/bin/bash\n")
        f.write(f"# SDK Environment Variables\n")
        f.write(f"export DXNN_SDK_HOME={directory}\n")
        f.write(f"export PATH=$DXNN_SDK_HOME/bin:$PATH\n")
        f.write(f"export PS1='[{directory}] \\u@\\h:\\w$ '\n")  # Change shell prompt
        INFO(f"Environment script created at: {env_script_path}")

    os.chmod(env_script_path, stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH)

def main():
    parser = argparse.ArgumentParser(description='SDK Setup Script')
    parser.add_argument('--sdk_home', type=str, help='Specify DXNN SDK home directory')
    parser.add_argument('--package', action='append', choices=['firmware', 'runtime', 'driver', 'app', 'all', 'rt'],
            help='Packages to build (can be specified multiple times)')
    parser.add_argument('--board', type=str, default='mdot2', help='Board type (default: mdot2)')
    parser.add_argument('--docker', action='store_true', help='Install Docker if not installed')


    args = parser.parse_args()

    if args.package is None:
        args.package = ['all']
    packages = args.package

    global sdk_dir
    sdk_dir = os.path.join(set_project_home(args.sdk_home), "dxnn_sdk")
    release_dir = os.path.realpath(os.path.join(sdk_dir, "release_docker"))
    runtime_dir = os.path.realpath(os.path.join(sdk_dir, "deepx_runtime"))
    driver_dir = os.path.realpath(os.path.join(sdk_dir, "deepx_host_driver"))
    app_dir = os.path.realpath(os.path.join(sdk_dir, "deepx_app"))
    firmware_dir = os.path.realpath(os.path.join(sdk_dir, "deepx_firmware"))

    build_dir = os.path.join(sdk_dir, 'build')
    os.makedirs(build_dir, exist_ok=True)

    os.environ['DEEPX_FIRMWARE_PATH'] = firmware_dir

    build_packages(packages, args.board, sdk_dir, firmware_dir, runtime_dir, driver_dir, app_dir)
    make_sdk_debs(sdk_dir, runtime_dir, driver_dir, app_dir)
    if args.docker:
        install_docker()
        prepare_docker_recipes(sdk_dir, release_dir)

    create_env_script(sdk_dir)
    DONE("Done.")

if __name__ == "__main__":
    main()
