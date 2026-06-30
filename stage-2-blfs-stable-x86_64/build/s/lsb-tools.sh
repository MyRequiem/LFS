#! /bin/bash

PRGNAME="lsb-tools"
ARCH_NAME="LSB-Tools"

### LSB-Tools (tools for Linux Standards Base conformance)
# Инструменты для обеспечения соответствия системы стандарту LSB, что помогает
# сторонним программам корректно работать в Linux.
#
# Выводит определенную информацию о LSB (Linux Standards Base) и дистрибутиве
#    /usr/bin/lsb_release
#
# Например:
#    $ lsb_release -a
#       Distributor ID: Linux From Scratch
#       Description:    Linux From Scratch
#       Release:        13.0
#       Codename:       MyRequiem
#
# Утилиты для активации/деактивации скриптов автозапуска в /etc/rc.d/init.d/
#    /usr/sbin/install_initd -> /usr/lib/lsb/install_initd
#    /usr/sbin/remove_initd  -> /usr/lib/lsb/remove_initd

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -p "${TMP_DIR}"

# по DESTDIR пакет устанавливает директорию ${DESTDIR}/usr/lib/lsb/, но в LFS
# системе /usr/lib/lsb это ссылка на /usr/lib/services/
#    /usr/lib/lsb -> services/
# и при копировании $TMP_DIR в корень системы произойдет ошибка, поэтому
# изменим путь установки:
sed "s|/lsb/|/services/|" -i Makefile || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# удалим ссылку:
#    /usr/sbin/lsbinstall -> /usr/lib/services/lsbinstall
# которую не нужно устанавливать
rm -f "${TMP_DIR}/usr/sbin/lsbinstall"

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tools for Linux Standards Base conformance)
#
# The LSB-Tools package includes tools for Linux Standards Base (LSB)
# conformance.
#
# Home page: https://github.com/lfs-book/${ARCH_NAME}/
# Download:  https://github.com/lfs-book/${ARCH_NAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
