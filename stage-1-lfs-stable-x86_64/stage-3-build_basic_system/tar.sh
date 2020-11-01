#! /bin/bash

PRGNAME="tar"

### Tar (archiving utility)
# Пакет предоставляет возможность создания/распаковки tar-архивов, а так же
# извлечения, обновления, вывода списка файлов в архивах.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# заставляет тест для mknod запускаться от имени пользователя root. Вообще
# считается опасным запускать этот тест от имени root, но в данный момент он
# запускается в системе, которая построена частично и работает только в chroot
# окружении
#    FORCE_UNSAFE_CONFIGURE=1
FORCE_UNSAFE_CONFIGURE=1 \
./configure              \
    --prefix=/usr        \
    --bindir=/bin || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# установим документацию
make -C doc install-html docdir="/usr/share/doc/${PRGNAME}-${VERSION}" \
    DESTDIR="${TMP_DIR}"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (archiving utility)
#
# This is the GNU version of tar, an archiving program designed to store and
# extract files from an archive file known as a tarfile. A tarfile may be made
# on a tape drive, however, it is also common to write a tarfile to a normal
# file.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
