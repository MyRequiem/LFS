#! /bin/bash

PRGNAME="xterm"

### xterm (terminal emulator for X Window System)
# Эмулятор терминала для X Window System

# Required:    luit
#              dejavu-fonts-ttf (runtime)
# Recommended: no
# Optional:    emacs
#              pcre2
#              valgrind
#              man2html         (http://www.nongnu.org/man2html/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
APP_DEFAULTS="/etc/X11/app-defaults"
APPLICATIONS="/usr/share/applications"
mkdir -pv "${TMP_DIR}"{${APP_DEFAULTS},${APPLICATIONS}}

# для согласованностью с консолью Linux клавиша Backspace должна отправлять
# символ с кодом 127
sed -i '/v0/{n;s/new:/new:kb=^?:/}' termcap || exit 1
printf '\tkbs=\\177,\n' >> terminfo         || exit 1

# файл xterm terminfo должен быть установлен в системную базу данных terminfo
export TERMINFO=/usr/share/terminfo
# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} \
    --with-app-defaults="${APP_DEFAULTS}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

cp -v ./*.desktop "${TMP_DIR}${APPLICATIONS}/"

# общесистемная конфигурация xterm
# (конфиги для каждого пользователя находятся в ~/.Xresources)
cat << EOF > "${TMP_DIR}${APP_DEFAULTS}/XTerm"
*VT100*locale:        true
*VT100*faceName:      Monospace
*VT100*faceSize:      10
*backarrowKeyIsErase: true
*ptyInitialErase:     true
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (terminal emulator for X Window System)
#
# The xterm program is a terminal emulator for the X Window System. It provides
# DEC VT102/VT220 (VTxxx) and Tektronix 4014 compatible terminals for programs
# that cannot use the window system directly.
#
# Home page: https://invisible-island.net/${PRGNAME}/${PRGNAME}.html
# Download:  https://invisible-mirror.net/archives/${PRGNAME}/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
