#! /bin/bash

PRGNAME="fuse"

### Fuse (Filesystem in Userspace)
# FUSE (File system in userspace, файловая система в пространстве пользователя)
# это механизм, позволяющий обычному пользователю подключать различные объекты
# как специфичные файловые системы в собственном пространстве, например на
# жёстком диске.

# Required:    no
# Recommended: no
# Optional:    doxygen         (для сборки API документации)
#              python3-pytest  (для тестов)

### Конфигурация ядра
#    CONFIG_FUSE_FS=y|m
#    CONFIG_CUSE=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-3*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

DOCS="false"
DOXYGEN="false"
# command -v doxygen &>/dev/null && DOXYGEN="true"

# отключим установку ненужного загрузочного скрипта и правила udev
sed -i '/^udev/,$ s/^/#/' util/meson.build || exit 1

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1

if [ "${DOCS}" == "true" ]; then
    if [ "${DOXYGEN}" == "true" ]; then
        doxygen doc/Doxyfile || exit 1
    fi
fi

# тесты (требуется модуль 'pytest')
# python3 -m pytest test/

DESTDIR="${TMP_DIR}" ninja install

chmod u+s "${TMP_DIR}/usr/bin/fusermount3"

# документация
if [ "${DOCS}" == "true" ]; then
    DOC_DIR="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -d -m755 "${TMP_DIR}${DOC_DIR}"
    install -v -m644 ../doc/{README.NFS,kernel.txt} "${TMP_DIR}${DOC_DIR}"
    cp -Rv ../doc/html "${TMP_DIR}${DOC_DIR}"
fi

### Конфигурация Fuse
# некоторые параметры политики монтирования могут быть установлены в файле
# /etc/fuse.conf
FUSE_CONF="/etc/${PRGNAME}.conf"
if [ -f "${FUSE_CONF}" ]; then
    mv "${FUSE_CONF}" "${FUSE_CONF}.old"
fi

cat << EOF > "${TMP_DIR}${FUSE_CONF}"
# Begin ${FUSE_CONF}

# The config file ${FUSE_CONF} allows for the following parameters:

### user_allow_other
# using the allow_other mount option works fine as root, in order to have it
# work as user you need user_allow_other in /etc/fuse.conf as well. This option
# allows users to use the allow_other option. You need allow_other if you want
# users other than the owner to access a mounted fuse. This option must appear
# on a line by itself. There is no value, just the presence of the option.

# user_allow_other

### mount_max
# set the maximum number of FUSE mounts allowed to non-root users. The default
# is 1000.

# mount_max = 1000

# End ${FUSE_CONF}
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${FUSE_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Filesystem in Userspace)
#
# FUSE is a simple interface for userspace programs to export a virtual
# filesystem to the Linux kernel. FUSE also aims to provide a secure method for
# non privileged users to create and mount their own filesystem
# implementations.
#
# Home page: https://github.com/libfuse/libfuse
# Download:  https://github.com/libfuse/libfuse/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
