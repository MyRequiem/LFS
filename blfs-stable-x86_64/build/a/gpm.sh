#! /bin/bash

PRGNAME="gpm"
LIBGPM_SO_VERSION="2.1.0"

### GPM (general purpose mouse server)
# Пакет GPM (Демон мыши общего назначения) содержит сервер мыши для виртуальной
# консоли и xterm. Обеспечивает поддержку вырезания/копирования/вставки текста.
# Так же его компоненты и библиотеки используются различным программным
# обеспечением, например links, Midnight Commander для обеспечения поддержки
# мыши в приложении.

# http://www.linuxfromscratch.org/blfs/view/stable/general/gpm.html

# Home page: http://freshmeat.sourceforge.net/projects/gpm/
# Download:  http://anduin.linuxfromscratch.org/BLFS/gpm/gpm-1.20.7.tar.bz2
# Patch:     http://www.linuxfromscratch.org/patches/blfs/9.1/gpm-1.20.7-glibc_2.26-1.patch

# Required: no
# Optional: no

### Kernel Configuration
#    CONFIG_INPUT=y
#    CONFIG_INPUT_MOUSEDEV=y|m

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
INFO_DIR="/usr/share/info"
mkdir -pv "${TMP_DIR}"{/etc,"${INFO_DIR}","${DOCS}/support"}

sed -i -e 's:<gpm.h>:"headers/gpm.h":' \
    src/prog/{display-buttons,display-coords,get-versions}.c || exit 1

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-glibc_2.26-1.patch" || exit 1

./autogen.sh &&
./configure       \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

make || exit 1

# пакет не имеет набора тестов

make install
make install DESTDIR="${TMP_DIR}"

# обновим /usr/share/info/dir
# (пакет устанавливает info-файл, но не обновляет базу)
install-info --dir-file="${INFO_DIR}/dir" "${INFO_DIR}/gpm.info"

# создадит ссылку /usr/lib/libgpm.so
ln -sfv "libgpm.so.${LIBGPM_SO_VERSION}" /usr/lib/libgpm.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv "libgpm.so.${LIBGPM_SO_VERSION}" libgpm.so
)

GPM_ROOT_CONF="/etc/gpm-root.conf"
if [ -f "${GPM_ROOT_CONF}" ]; then
    mv "${GPM_ROOT_CONF}" "${GPM_ROOT_CONF}.old"
fi

install -v -m644 conf/gpm-root.conf /etc
install -v -m644 conf/gpm-root.conf "${TMP_DIR}/etc"

config_file_processing "${GPM_ROOT_CONF}"

install -v -m755 -d "${DOCS}/support"
install -v -m644 doc/support/* "${DOCS}/support"
install -v -m644 doc/support/* "${TMP_DIR}${DOCS}/support"

install -v -m644 doc/{FAQ,HACK_GPM,README*} "${DOCS}"
install -v -m644 doc/{FAQ,HACK_GPM,README*} "${TMP_DIR}${DOCS}"

# для автозапуска gpm сервера при загрузке системы установим скрипт
# инициализации /etc/rc.d/init.d/gpm
(
    cd /root/blfs-bootscripts || exit 1
    make install-gpm
    make install-gpm DESTDIR="${TMP_DIR}"
)

### Конфигурация GPM
#    /etc/gpm-root.conf
#    ~/.gpm-root
#    /etc/sysconfig/mouse

MOUSE="/etc/sysconfig/mouse"
if [ -f "${MOUSE}" ]; then
    mv "${MOUSE}" "${MOUSE}.old"
fi

cat << EOF > "${MOUSE}"
# Begin "${MOUSE}"

# The MDEVICE setting depends on which type of mouse you have. For example:
#    /dev/ttyS0         - for a serial mouse (on Windows this is COM1)
#    /dev/psaux         - for PS2 mice
#    /dev/input/mice    - used for USB mice
#                          (or link /dev/mouse -> /dev/input/mice)
#
MDEVICE="/dev/mouse"

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

cp -v "${MOUSE}" "${TMP_DIR}/etc/sysconfig/"
config_file_processing "${MOUSE}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (general purpose mouse server)
#
# The GPM (General Purpose Mouse daemon) package contains a mouse server for
# the console and xterm. It not only provides cut and paste support generally,
# but its library component is used by various software such as Links to
# provide mouse support to the application.
#
# Home page: http://freshmeat.sourceforge.net/projects/${PRGNAME}/
# Download:  http://anduin.linuxfromscratch.org/BLFS/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

# echo -e "\n---------------\nRemoving *.la files..."
# remove-la-files.sh
# echo "---------------"
