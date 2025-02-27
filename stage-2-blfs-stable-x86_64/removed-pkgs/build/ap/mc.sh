#! /bin/bash

PRGNAME="mc"

### MC (Midnight Commander file manager)
# Полноэкранный текстовый файловый менеджер + Shell для UNIX-подобных
# операционных систем (клон Norton Commander). Имеется поддержка мыши через
# GPM.

# Required:    glib
# Recommended: slang
# Optional:    doxygen
#              gpm
#              libssh2
#              ruby
#              samba
#              unzip
#              Graphical Environments
#              zip

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# добавим поддержку кодировок при редактировании файлов в mcedit отличных от
# текущей локали
#    --enable-charset
./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --enable-charset     \
    --localstatedir=/var \
    --runstatedir=/run   \
    --disable-vfs-fish   \
    --disable-tests      \
    --disable-static     \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Midnight Commander file manager)
#
# The Midnight Commander is a text-mode full-screen file manager and visual
# shell (is a Norton Commander clone) that manipulates and manages files and
# directories. Useful, fast, and has color displays on the Linux console. It
# provides a clear, user-friendly, and somewhat protected interface to a Unix
# system while making many frequent file operations more efficient and
# preserving the full power of the command prompt. Mouse support is provided
# through the gpm mouse server.
#
# Home page: https://midnight-commander.org/
# Download:  http://ftp.midnight-commander.org/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
