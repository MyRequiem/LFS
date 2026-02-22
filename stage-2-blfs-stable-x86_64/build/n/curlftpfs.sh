#! /bin/bash

PRGNAME="curlftpfs"

### CurlFtpFS (Mount FTP/SFTP via fuse)
# Файловая система для доступа к ftp-хостам, основанная на FUSE и libcurl

# Required:    curl
#              fuse2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# ===============================
### Apply patch from Gentoo
# https://sourceforge.net/p/curlftpfs/bugs/65/
# May also fix these:
# https://sourceforge.net/p/curlftpfs/bugs/34/
# https://sourceforge.net/p/curlftpfs/bugs/74/
patch -p1 -i \
    "${SOURCES}/curlftpfs-0.9.2-fix-escaping.patch"          || exit 1
# ===============================
### Apply patches from Fedora
# https://bugzilla.redhat.com/show_bug.cgi?id=962015
patch -p1 -i \
    "${SOURCES}/curlftpfs-0.9.2-create-fix.patch"            || exit 1
# https://sourceforge.net/p/curlftpfs/bugs/52/
patch -p1 -i \
    "${SOURCES}/curlftpfs-0.9.2-memleak-591298.patch"        || exit 1
# https://sourceforge.net/p/curlftpfs/bugs/58/
patch -p1 -i \
    "${SOURCES}/curlftpfs-0.9.2-memleak-cached-591299.patch" || exit 1
# https://sourceforge.net/p/curlftpfs/bugs/50/
patch -p1 -i \
    "${SOURCES}/curlftpfs-0.9.2-offset_64_another.patch"     || exit 1
# ===============================
### Apply patch from Arch
# https://bugs.archlinux.org/task/47906
# https://sourceforge.net/p/curlftpfs/bugs/67/
patch -p1 -i \
    "${SOURCES}/no-verify-hostname.patch"                    || exit 1
# ===============================
### Apply patches from Debian
# https://sources.debian.org/patches/curlftpfs/0.9.2-10/
patch -p1 -i \
    "${SOURCES}/consistent-feature-flag.patch"               || exit 1
patch -p1 -i \
    "${SOURCES}/fix_bashism_in_test_script.patch"            || exit 1
patch -p1 -i \
    "${SOURCES}/getpass-prototype.patch"                     || exit 1
# ===============================
### Apply patches from MyRequiem
patch -p1 -i \
    "${SOURCES}/fix_for_curl_8.17_and_later.patch"           || exit 1

# configure script may hangs on checking for mktime
# (for a very long time or indefinitely)
# ...
# ...
# checking for working mktime...
#
# we'll fix it
patch -p1 -i \
    "${SOURCES}/fix-check-mktime.patch"                      || exit 1

# для сборки с GCC-15
export CFLAGS="-Wno-implicit-function-declaration -Wno-int-conversion"
./configure           \
    --prefix=/usr     \
    --disable-static  \
    --sysconfdir=/etc \
    --localstatedir=/var || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Mount FTP/SFTP via fuse)
#
# CurlFtpFS is a filesystem for acessing ftp hosts based on FUSE and libcurl.
# It automatically reconnects if the server times out.
#
# Home page: https://${PRGNAME}.sourceforge.net/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
