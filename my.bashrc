# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

alias dls='dirs -v'
alias ll='ls -alF'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
set -o vi

#alias t32a="cd /home/kbg/t32 && ./bin/pc_linux64/t32marm -c config_usb.t32"
#2109
alias t32a="cd /home/kbg/t32_2109 && ./bin/pc_linux64/t32marm -c config_usb.t32"

export PATH=/home/kbg/bin:$PATH
export PATH=/opt/tools/gcc-arm-none-eabi-10.3-2021.10/bin:$PATH

upcie() {
	pushd ~/m1/outputs

	for devnum in "$@"; do
		./update_pcie.sh -d /dev/dx_dma"${devnum:-0}"_c2h_0 -f map_qspi.txt -t fwboot -r
	done

	popd
}

upciel() {
	pushd ~/m1/outputs

	for devnum in "$@"; do
		./update_pcie.sh -d /dev/dx_dma"${devnum:-0}"_c2h_0 -f map_qspi.txt -t spl0 spl1 spl2 spl3
	done

	popd
}

upcier() {
	pushd ~/m1/outputs

	for devnum in "$@"; do
		./update_pcie.sh -d /dev/dx_dma"${devnum:-0}"_c2h_0 -f map_qspi.txt -t fwboot_r0 fwboot_r1 -r
	done

	popd
}


alias upcie0="./update_pcie.sh -d /dev/dx_dma0_c2h_0 -f map_qspi.txt -t fwtest fwboot -r"

h1mon() {
	watch -n 1 /usr/bin/h1_scan.sh
}

alias vncs='vncserver -localhost no -geometry 2560x1440 :2'
alias gopcid='cd /home/kbg/m1/dx_rt/driver/DX_M1/pcie/driver'
#alias gofw='cd /home/kbg/m1/rt_fw/firmware'
#alias gort='cd /home/kbg/m1/dx_rt'
alias gofw='cd ~/m1a/rt_fw_m1a'
alias goos='cd ~/m1a/freertos'
alias gort='cd ~/deepx_runtime/dx_rt'
alias gomo='cd ~/deepx_runtime/rt_npu_linux_driver/modules'
alias gomyrt='cd /home/kbg/m1/my_dx_rt'
alias hws='sudo mount -t nfs 192.168.0.55:/volume1/hw_share /mnt/hw_share'
alias nas='sudo mount -t nfs -o nolock 192.168.0.7:/volume2/onnx_quantization /mnt/onnx_quantization'

aer() {
	lspci | grep acc | awk -F':' '{two=substr($1, 1, 2); path="/sys/bus/pci/devices/0000:" two ":00.0/aer_dev_correctable"; print path; system("cat " path)}'
}


export PATH=/home/kbg/m1/dx_rt/bin:$PATH

#alias armds='/usr/local/ArmCompilerforEmbedded6.20.1/bin/suite_exec bash'
alias armds='/opt/arm/developmentstudio-2022.0/bin/suite_exec bash'
export ARMLMD_LICENSE_FILE="7070@192.168.0.46"
alias h1h1='sudo sshfs -o allow_other kbg@192.168.0.12:/home/kbg /h1'
alias ch1='ssh -Y kbg@192.168.0.12'
alias csys='ssh -Y kbg@192.168.0.35'
alias chaps='ssh -X kbg@192.168.0.46'
alias cm1='ssh kbg@192.168.0.52'
# google-drive-ocamlfuse ~/GDrive

ulimit -n 8192

# git remote add upstream git@github.com:KOMOSYS/dx_rt.git
# git fetch upstream
# git checkout dev
# git rebase upstream/dev		# git merge upstream/dev
# git push -f origin dev
# git push --set-upstream origin dev

alias clis='~/m1/dx_rt/bin/dxrt-cli -s'
alias clii='~/m1/dx_rt/bin/dxrt-cli -i'
alias clip='~/m1/dx_rt/bin/dxrt-cli -p'

#alias m1_pc='sshfs -o reconnect,allow_other,IdentityFile=~/.ssh/id_ed25519 kbg@192.168.0.12:/home/kbg/m1 m1_pc'

function mnt_soc33() {
    mkdir -p ~/soc33
    sudo sshfs -p 16022 -o allow_other kbg@192.168.100.33:/home/kbg ~/soc33
}

function mnt_haps0() {
	mkdir -p ~/haps0
	sudo sshfs -p 22 -o allow_other kbg@192.168.0.46:/home/kbg ~/haps0
}

#alias gsu='git submodule update --recursive'
alias gsu='git submodule foreach git pull'
alias gss='git submodule status'
alias gsm='git submodule foreach git checkout main'
alias gpr='git pull --recurse-submodules'

alias mntzoo='sudo mount -t nfs -o nolock 192.168.100.206:/modelzoo /mnt/modelzoo_storage'
alias mntreg2='sudo mount -t nfs -o nolock 192.168.0.55:/volume1/regression /mnt/regression_storage'
alias mntreg3='sudo mount -t nfs -o nolock 192.168.30.201:/do/regression /mnt/regression'

#sudo iotop
#sudo iostat -d 2
#bmon
#sudo iftop

export PATH=/home/kbg/ArmCompilerforEmbeddedFuSa6.16.2/bin:$PATH


# sudo apt install -y x11vnc
alias vncm1='ssh kbg@192.168.0.52 -L 5900:localhost:5900 "x11vnc -display :0 -noxdamage"'
alias vnc155='ssh kbg@192.168.0.155 -L 5900:localhost:5900 "x11vnc -display :0 -noxdamage"'
alias gott='cd ~/m1a/tests/script/npu_stability'
alias goapp='cd ~/deepx_runtime/dx_app'
alias goval='cd ~/deepx_runtime/rt_npu_validation'
alias vncon='x11vnc -display :0 -noxdamage'
