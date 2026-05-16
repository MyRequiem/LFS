#! /bin/bash

PRGNAME="gpm"
LIBGPM_SO_VERSION="2.1.0"

### GPM (general purpose mouse server)
# Пакет GPM (Демон мыши общего назначения) содержит сервер мыши для виртуальной
# консоли и xterm. Обеспечивает поддержку вырезания/копирования/вставки текста.
# Так же его компоненты и библиотеки используются различным программным
# обеспечением, например links, Midnight Commander для обеспечения поддержки
# мыши в приложении.

# Required:    no
# Recommended: no
# Optional:    texlive    (для документации)

### Kernel Configuration
#    CONFIG_INPUT=y
#    CONFIG_INPUT_MOUSEDEV=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-consolidated-1.patch" || exit 1
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-gcc15_fixes-1.patch" || exit 1

./autogen.sh &&
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    ac_cv_path_emacs=no || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# удалим статическую библиотеку
rm -f "${TMP_DIR}/usr/lib/libgpm.a"

# создадим ссылку в /usr/lib libgpm.so -> libgpm.so.${LIBGPM_SO_VERSION}
ln -sfv "libgpm.so.${LIBGPM_SO_VERSION}" "${TMP_DIR}/usr/lib/libgpm.so"

install -v -m644 conf/gpm-root.conf "${TMP_DIR}/etc"

# для автозапуска gpm сервера при загрузке системы установим скрипт
# инициализации /etc/rc.d/init.d/gpm
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-gpm DESTDIR="${TMP_DIR}"
)

### Конфигурация GPM
#    /etc/gpm-root.conf
#    ~/.gpm-root
#    /etc/sysconfig/mouse

MOUSE="/etc/sysconfig/mouse"
cat << EOF > "${TMP_DIR}${MOUSE}"
# Begin "${MOUSE}"

# The MDEVICE setting depends on which type of mouse you have. For example:
#    /dev/ttyS0         - for a serial mouse (on Windows this is COM1)
#    /dev/psaux         - for PS2 mice
#    /dev/input/mice    - used for USB mice
#                          (or link /dev/mouse -> /dev/input/mice)
#
MDEVICE="/dev/input/mice"

# A list of which protocol values are known can be found by running:
#    # gpm -m <device> -t -help
#       (where <device> is MDEVICE value)
#
PROTOCOL="imps2"

# GPMOPTS is the 'catch all' for any additional options that are needed for
# your hardware
#
GPMOPTS=""

# End "${MOUSE}"
EOF

GPM_ROOT_CONF="/etc/gpm-root.conf"
if [ -f "${GPM_ROOT_CONF}" ]; then
    mv "${GPM_ROOT_CONF}" "${GPM_ROOT_CONF}.old"
fi

if [ -f "${MOUSE}" ]; then
    mv "${MOUSE}" "${MOUSE}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${GPM_ROOT_CONF}"
config_file_processing "${MOUSE}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (general purpose mouse server)
#
# The GPM (General Purpose Mouse daemon) package contains a mouse server for
# the console and xterm. It not only provides cut and paste support generally,
# but its library component is used by various software such as Links to
# provide mouse support to the application.
#
# Home page: https://github.com/telmich/${PRGNAME}
# Download:  https://anduin.linuxfromscratch.org/BLFS/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
