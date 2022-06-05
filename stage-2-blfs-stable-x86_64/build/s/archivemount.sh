#! /bin/bash

PRGNAME="archivemount"

### archivemount (mounts an archive for access as a file system)
# Виртуальная файловая система, основанная на FUSE для файловых архивов tar,
# pax, cpio, образы iso9660 (CD-ROM), zip, shar, rar 7z

# Required:    autoconf213
#              libarchive
#              fuse2        (https://github.com/libfuse/libfuse)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

patch --verbose -p1 -i "${SOURCES}/manpage.diff" || exit 1
rm -f "${PRGNAME}.1"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (mounts an archive for access as a file system)
#
# archivemount is a FUSE based file system. Its purpose is to mount an archive
# on a mount point where it can be read from or written to as with any other
# file system. This makes accessing the contents of the archive, which may be
# compressed, transparent to other programs, without decompressing them.
# Supported archive formats: tar, pax, cpio, iso9660 (CD-ROM) images, zip,
# shar. Other archive types such as rar and 7z may also work.
#
# Home page: https://www.cybernoia.de/software/${PRGNAME}.html
# Download:  https://www.cybernoia.de/software/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
