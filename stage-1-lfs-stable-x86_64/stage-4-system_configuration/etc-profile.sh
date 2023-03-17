#! /bin/bash

PRGNAME="etc-profile"
LFS_VERSION="11.3"

### /etc/profile (system-wide defaults)
# Общесистемные настройки оболочки
#    /etc/profile
#    /etc/dircolors
#    /etc/bash_completion.d/
#    /etc/profile.d/i18n.sh
#    /etc/profile.d/umask.sh
#    /etc/profile.d/readline.sh
#    /etc/profile.d/dircolors.sh
#    /etc/profile.d/bash_completion.sh

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/etc/{profile.d,bash_completion.d}

# =============================== /etc/profile =================================
PROFILE="/etc/profile"
cat << EOF > "${TMP_DIR}${PROFILE}"
#! /bin/bash

# Begin ${PROFILE}

# This file contains system-wide defaults

export GLOBIGNORE='.'
export HISTFILESIZE=10000
export HISTSIZE=5000
export HISTCONTROL=ignoreboth:erasedups

# some defaults for graphical systems
export XDG_DATA_DIRS=/usr/share
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_CONFIG_HOME=\${HOME}/.config
export XDG_RUNTIME_DIR=/tmp/xdg-runtime-\${USER}

export MANPATH=/usr/share/man:/usr/local/share/man
export INFOPATH=/usr/share/info
export EDITOR=vim
export PAGER=less
HOSTNAME="\$(cat /etc/hostname)"
export HOSTNAME

# set the default system \$PATH
export PATH="/usr/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin"

# if exist \$HOME/bin directory add it to the \$PATH
if [ -d "\${HOME}/bin" ]; then
    PATH=\${PATH}:\${HOME}/bin
fi
export PATH

# set TERM to 'linux' for unknown type or unset variable
if [[ "\${TERM}" == "" || "\${TERM}" == "unknown" ]]; then
    TERM=linux
fi
export TERM

# bash prompt
if [[ "\${EUID}" == "0" ]]; then
    CYAN="\\[\\033[0;36m\\]"
    LBLUE="\\[\\033[1;34m\\]"
    LRED="\\[\\033[1;31m\\]"
    BROWN="\\[\\033[0;33m\\]"
    LMAGENTA="\\[\\033[1;35m\\]"
    COLORRESET="\\[\\033[0;0m\\]"

    USERNAME="\\u"
    HOST_NAME="\\h"
    TIME="\\A"
    CURR_DIR="\\w"

    PS1="\${USERNAME}\${CYAN}@\${BROWN}\${HOST_NAME}"
    PS1="\${PS1}\${LBLUE}[\${TIME}]\${COLORRESET}:"

    if [[ -n "\${SSH_CLIENT}" || -n "\${SSH_CONNECTION}" ]]; then
        PS1="\${PS1}\${LMAGENTA}[SSH]"
    fi

    export PS1="\${PS1}\${LRED}\${CURR_DIR}\\$\${COLORRESET} "
else
    PS1='\\u@\\h:\\w\\$ '
fi

PS2='> '
export PS1 PS2

PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/share/pkgconfig
[ -d  /usr/local/lib/pkgconfig ] &&
    PKG_CONFIG_PATH=\${PKG_CONFIG_PATH}:/usr/local/lib/pkgconfig
[ -d /usr/local/share/pkgconfig ] &&
    PKG_CONFIG_PATH=\${PKG_CONFIG_PATH}:/usr/local/share/pkgconfig
export PKG_CONFIG_PATH

# append any additional bash scripts found in /etc/profile.d directory
for PROFILE_SCRIPT in /etc/profile.d/*.sh; do
    if [ -x "\${PROFILE_SCRIPT}" ]; then
        source "\${PROFILE_SCRIPT}"
    fi
done

unset PROFILE_SCRIPT CYAN LBLUE LRED BROWN LMAGENTA COLORRESET USERNAME \\
HOST_NAME TIME CURR_DIR

# End ${PROFILE}
EOF

# ==================== /etc/profile.d/bash_completion.sh =======================
BASH_COMPLETION="/etc/profile.d/bash_completion.sh"
cat << EOF > "${TMP_DIR}${BASH_COMPLETION}"
#! /bin/bash

# Begin ${BASH_COMPLETION}

# Import bash completion scripts

# if bash-completion package is installed, use its configuration instead
if [ -r /usr/share/bash-completion/bash_completion ]; then
    # check for interactive bash and that we haven't already been sourced
    if [[ -n "\${BASH_VERSION}" && -n "\${PS1}" && \\
            -z "\${BASH_COMPLETION_VERSINFO}" ]]; then

        [ -r "\${XDG_CONFIG_HOME:-\$HOME/.config}/bash_completion" ] && \\
            source "\${XDG_CONFIG_HOME:-\$HOME/.config}/bash_completion"

        # source completion code
        source /usr/share/bash-completion/bash_completion
    fi
fi

for SCRIPT in /etc/bash_completion.d/*; do
    if [ -r "\${SCRIPT}" ] ; then
        source "\${SCRIPT}"
    fi
done

# End ${BASH_COMPLETION}
EOF

chmod 755 "${TMP_DIR}${BASH_COMPLETION}"

# ======================= /etc/profile.d/dircolors.sh ==========================
DIRCOLORS_SH="/etc/profile.d/dircolors.sh"
cat << EOF > "${TMP_DIR}${DIRCOLORS_SH}"
#! /bin/bash

# Begin ${DIRCOLORS_SH}

# Setup for /bin/ls and /bin/grep to support color

LS_OPTIONS="-F -b -T 0 --group-directories-first --color=auto"
export LS_OPTIONS

alias ls='ls \$LS_OPTIONS'
alias v='ls --format=long --time-style="+%d.%m.%y %H:%M:%S"'
alias vh='v --human-readable'
alias grep='grep --color=auto'

if [ -r /etc/dircolors ]; then
    eval "\$(dircolors -b /etc/dircolors)"
fi

if [ -r "\${HOME}/.dircolors" ]; then
    eval "\$(dircolors -b "\${HOME}/.dircolors")"
fi

# End ${DIRCOLORS_SH}
EOF

chmod 755 "${TMP_DIR}${DIRCOLORS_SH}"

# ============================== /etc/dircolors ================================
DIRCOLORS="/etc/dircolors"
cat << EOF > "${TMP_DIR}${DIRCOLORS}"
# Begin ${DIRCOLORS}

# Configuration file for dircolors, a utility to help you set the
# LS_COLORS environment variable used by GNU ls with the --color option

# below, there should be one TERM entry for each termtype that is colorizable
TERM konsole
TERM linux
TERM rxvt
TERM rxvt-256color
TERM rxvt-unicode
TERM rxvt-unicode-256color
TERM rxvt-unicode256
TERM screen
TERM screen-256color
TERM vt100
TERM xterm
TERM xterm-256color

# below are the color init strings for the basic file types
NORMAL                00
FILE                  00;37
RESET                 0
DIR                   0;33
LINK                  01;36
FIFO                  01;34
SOCK                  01;35
DOOR                  01;35
BLK                   01;33
CHR                   01;33
ORPHAN                01;31
SETUID                37;41
SETGID                30;43
CAPABILITY            30;41
STICKY_OTHER_WRITABLE 30;42
OTHER_WRITABLE        34;42
STICKY                37;44
EXEC                  01;32

# list any file extensions like '.gz' or '.tar' that you would like ls
# to colorize below

# docs
.lst    00
.meta   00
.asc    00
.md5    00
.sha1   00
.sha256 00
.sha512 00
.txt    00
.TXT    00
.rtf    00
.diz    00
.ctl    00
.me     00
.ps     00
.xsd    00
.xslt   00
.dtd    00
.mail   00
.msg    00
.lsm    00
.po     00
.nroff  00
.man    00
.tex    00
.sgml   00
.text   00
.letter 00
.chm    00
.doc    00
.docx   00
.docm   00
.xls    00
.xlsx   00
.ppt    00
.pptx   00
.pptm   00
.odt    00
.odp    00

# temporary files
.tmp  01;30
.\$\$\$  01;30
.bak  01;30
.back 01;30

# DOS-style executables
.bat  01;32
.btm  01;32
.cmd  01;32
.com  01;32
.dll  01;32
.exe  01;32

# archives or compressed
.7z   02;33
.ace  02;33
.arj  02;33
.bz   02;33
.bz2  02;33
.cpio 02;33
.deb  02;33
.dz   02;33
.gz   02;33
.jar  02;33
.lha  02;33
.lz   02;33
.lzh  02;33
.lzma 02;33
.rar  02;33
.rpm  02;33
.rz   02;33
.tar  02;33
.taz  02;33
.tb2  02;33
.tbz2 02;33
.tbz  02;33
.tgz  02;33
.tlz  00;33
.trz  02;33
.txz  00;36
.tz   02;33
.tz2  02;33
.tzst 02;33
.xz   02;33
.z    02;33
.Z    02;33
.zip  02;33
.cab  02;33
.zoo  02;33
.zst  02;33
.arc  02;33
.ark  02;33

# video/sound file formats
.aac  00;32
.anx  00;32
.asf  00;32
.au   00;32
.axa  00;32
.axv  00;32
.avi  00;32
.divx 00;32
.flac 00;32
.flv  00;32
.m2a  00;32
.m2t  00;32
.m2v  00;32
.m4a  00;32
.m4p  00;32
.m4v  00;32
.mid  00;32
.midi 00;32
.mka  00;32
.mkv  00;32
.mov  00;32
.mp2  00;32
.mp3  00;32
.mp4  00;32
.mp4v 00;32
.mpc  00;32
.mpeg 00;32
.mpg  00;32
.nuv  00;32
.oga  00;32
.ogv  00;32
.ogx  00;32
.ogg  00;32
.opus 00;32
.wav  00;32
.mol  00;32
.mpl  00;32
.xm   00;32
.mod  00;32
.it   00;32
.med  00;32
.s3m  00;32
.umx  00;32
.vob  00;32
.m3u  00;32
.ape  00;32
.wma  00;32
.wmv  00;32
.3gp  00;32
.webm 00;32
.webp 00;32
.xwd  00;32
.xvid 00;32

# image file formats
.png  01;36
.ppm  01;36
.qt   01;36
.ra   01;36
.ram  01;36
.rm   01;36
.spx  01;36
.svg  01;36
.svgz 01;36
.tga  01;36
.tif  01;36
.tiff 01;36
.ico  01;36
.bmp  01;36
.gif  01;36
.jpg  01;36
.jpeg 01;36
.pcx  01;36
.xbm  01;36
.xcf  01;36
.xpm  01;36
.xspf 01;36
.eps  01;36
.pic  01;36
.rle  01;36
.wmf  01;36
.omf  01;36
.ai   01;36
.cdr  01;36
.ora  01;36
.fits 01;36
.ppc  01;36
.pbm  01;36
.pgm  01;36
.psd  01;36
.rgb  01;36

# pdf,djvu
.pdf  01;34
.djvu 01;34

# iso, img
.iso  01;34
.img  01;34

# html
.htm   01;35
.html  01;35
.shtml 01;35

# css
.css   01;31

# xml
.xml   01;31

# sources/patches
.diff  00;36
.patch 00;36
.c     00;36
.cc    00;36
.cpp   00;36
.cxx   00;36
.h     00;36
.hh    00;36
.pas   00;36
.py    00;36
.js    00;36
.sh    00;36
.csh   00;36
.zsh   00;36
.bash  00;36
.fish  00;36
.vim   00;36
.vifm  00;36
.asm   00;36
.jasm  00;36
.hpp   00;36
.inc   00;36
.cgi   00;36
.php   00;36
.phps  00;36
.pl    00;36
.pm    00;36
.java  00;36
.jav   00;36
.tcl   00;36
.tk    00;36
.tm    00;36
.awk   00;36
.m4    00;36
.st    00;36
.mak   00;36
.sl    00;36
.ada   00;36
.caml  00;36
.ml    00;36
.mli   00;36
.mly   00;36
.mll   00;36
.mlp   00;36
.sas   00;36
.prg   00;36
.hs    00;36
.erl   00;36
.jsm   00;36
.el    00;36
.lisp  00;36
.md    00;36
.rst   00;36
.SlackBuild 00;36
.l     00;36
.lex   00;36
.y     00;36

# configs
.conf  01;35
.ini   01;35

# torrent
.torrent 0;32

# databases
.dbf   00;31
.mdn   00;31
.db    00;31
.mdb   00;31
.dat   00;31
.fox   00;31
.dbx   00;31
.mdx   00;31
.sql   00;31
.mssql 00;31
.msql  00;31
.ssql  00;31
.pgsql 00;31
.cdx   00;31
.dbi   00;31

# End ${DIRCOLORS}
EOF

# ======================== /etc/profile.d/readline.sh ==========================
READLINE="/etc/profile.d/readline.sh"
cat << EOF > "${TMP_DIR}${READLINE}"
#! /bin/bash

# Begin ${READLINE}

# Setup the INPUTRC environment variable

if [ -z "\${INPUTRC}" ]; then
    if ! [ -f "\${HOME}/.inputrc" ]; then
        INPUTRC=/etc/inputrc
    else
        INPUTRC="\${HOME}/.inputrc"
    fi
fi

export INPUTRC

# End ${READLINE}
EOF

chmod 755 "${TMP_DIR}${READLINE}"

# ========================= /etc/profile.d/umask.sh ============================
UMASK="/etc/profile.d/umask.sh"
cat << EOF > "${TMP_DIR}${UMASK}"
#! /bin/bash

# Begin ${UMASK}

# Setting the umask value is important for security. Here the default group
# write permissions are turned off for system users and when the user name and
# group name are not the same.

if [[ "\$(id -gn)" == "\$(id -un)" && "\${EUID}" -gt 99 ]]; then
    umask 002
else
    umask 022
fi

# End ${UMASK}
EOF

chmod 755 "${TMP_DIR}${UMASK}"

# ========================== /etc/profile.d/i18n.sh ============================
I18N="/etc/profile.d/i18n.sh"
cat << EOF > "${TMP_DIR}${I18N}"
#! /bin/bash

# Begin ${I18N}

# set up i18n variables

### Locale settings
# complete information about the current locale
#    $ locale
# list of all locales supported by Glibc
#    $ locale -a
# locale encoding
#    $ LC_ALL=ru_RU.UTF-8 locale charmap
# language
#    $ LC_ALL=ru_RU.UTF-8 locale language
# monetary units
#    $ LC_ALL=ru_RU.UTF-8 locale int_curr_symbol
# country code (code before dialing the phone number)
#    $ LC_ALL=ru_RU.UTF-8 locale int_prefix

export LANG="ru_RU.UTF-8"
export LC_CTYPE="ru_RU.UTF-8"
export LC_NUMERIC="ru_RU.UTF-8"
export LC_TIME="ru_RU.UTF-8"
export LC_COLLATE=C
export LC_MONETARY="ru_RU.UTF-8"
export LC_MESSAGES="ru_RU.UTF-8"
export LC_PAPER="ru_RU.UTF-8"
export LC_NAME="ru_RU.UTF-8"
export LC_ADDRESS="ru_RU.UTF-8"
export LC_TELEPHONE="ru_RU.UTF-8"
export LC_MEASUREMENT="ru_RU.UTF-8"
export LC_IDENTIFICATION="ru_RU.UTF-8"
export LC_ALL=

# End ${I18N}
EOF

chmod 755 "${TMP_DIR}${I18N}"

# ==============================================================================

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${LFS_VERSION}"
# Package: ${PRGNAME} (system-wide defaults)
#
# System-wide shell settings
#
# /etc/profile
# /etc/dircolors
# /etc/bash_completion.d/
# /etc/profile.d/i18n.sh
# /etc/profile.d/umask.sh
# /etc/profile.d/readline.sh
# /etc/profile.d/dircolors.sh
# /etc/profile.d/bash_completion.sh
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${LFS_VERSION}"
