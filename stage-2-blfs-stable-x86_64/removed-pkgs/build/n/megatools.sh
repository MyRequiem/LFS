#! /bin/bash

PRGNAME="megatools"

### Megatools (access Mega.co.nz on the command line)
# Набор утилит для доступа к сервису Mega из командная строки. Megatools
# позволяет копировать как отдельные файлы, так и целые деревья каталогов в
# облако и из него.

# Required:    curl
#              glib
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (access Mega.co.nz on the command line)
#
# Megatools is a collection of programs for accessing Mega service from a
# command line. Megatools allow you to copy individual files as well as entire
# directory trees to and from the cloud. You can also perform streaming
# downloads for example to preview videos and audio files, without needing to
# download the entire file.
#
# Home page: https://${PRGNAME}.megous.com/
# Download:  https://${PRGNAME}.megous.com/builds/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
