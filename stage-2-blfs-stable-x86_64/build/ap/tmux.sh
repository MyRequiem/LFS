#! /bin/bash

PRGNAME="tmux"

### Tmux (terminal multiplexer)
# Терминальный мультиплексор, предоставляющий пользователю доступ к нескольким
# терминалам в рамках одного экрана. Является более современной альтернативой
# утилиты GNU screen

# Required:    libevent
#              ncurses
#              yasm или bison (для сборки)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"{/etc,"${DOCS}"}

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-systemd \
    --disable-static  \
    --docdir="${DOCS}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# документация
cp -a README CHANGES example_tmux.conf "${TMP_DIR}${DOCS}"

TMUX_CONFIG="/etc/tmux.conf"
cat << EOF > "${TMP_DIR}${TMUX_CONFIG}"
# System-wide tmux config file.
#
# As installed, this serves only to set the default terminal type. For a more
# complete example, see: /usr/share/doc/tmux-*/example_tmux.conf

# Change the default \$TERM to tmux-256color
set -g default-terminal "tmux-256color"
EOF

if [ -f "${TMUX_CONFIG}" ]; then
    mv "${TMUX_CONFIG}" "${TMUX_CONFIG}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${TMUX_CONFIG}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (terminal multiplexer)
#
# tmux is a terminal multiplexer. It enables a number of terminals (or windows)
# to be accessed and controlled from a single terminal. tmux is intended to be
# a simple, modern, BSD-licensed alternative to programs such as GNU screen.
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/wiki
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
