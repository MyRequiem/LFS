#! /bin/bash

PRGNAME="mc"

### MC (Midnight Commander file manager)
# Полноэкранный текстовый файловый менеджер + Shell для UNIX-подобных
# операционных систем (клон Norton Commander). Имеется поддержка мыши через
# GPM.

# http://www.linuxfromscratch.org/blfs/view/stable/general/mc.html

# Home page: https://midnight-commander.org/
# Download:  http://ftp.midnight-commander.org/mc-4.8.24.tar.xz

# Required: glib
#           pcre
#           slang
# Optional: doxygen
#           gpm
#           samba
#           unzip
#           X Window System Environment
#           zip

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

SAMBA="--disable-vfs-smb"
GPM="--without-gpm-mouse"
DOXYGEN_DOC="--disable-doxygen-doc"
DOXYGEN_HTML="--disable-doxygen-html"
DOXYGEN_PDF="--disable-doxygen-pdf"

command -v samba    &>/dev/null && SAMBA="--enable-vfs-smb"
command -v gpm      &>/dev/null && GPM="--with-gpm-mouse"
command -v doxygen  &>/dev/null &&       \
    DOXYGEN_DOC="--enable-doxygen-doc"   \
    DOXYGEN_HTML="--enable-doxygen-html" \
    DOXYGEN_PDF="--enable-doxygen-pdf"

# добавим поддержку кодировок при редактировании файлов в mcedit отличных от
# текущей локали
#    --enable-charset
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    "${SAMBA}"        \
    "${GPM}"          \
    "${DOXYGEN_DOC}"  \
    "${DOXYGEN_HTML}" \
    "${DOXYGEN_PDF}"  \
    --enable-charset  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cp -v doc/keybind-migration.txt /usr/share/mc
cp -v doc/keybind-migration.txt "${TMP_DIR}/usr/share/mc"

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
