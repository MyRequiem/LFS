#! /bin/bash

PRGNAME="libiscsi"

### Libiscsi (iSCSI client-side library)
# Клиентская библиотека для реализации протокола iSCSI, которую можно
# использовать для доступа к iSCSI ресурсам.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./autogen.sh &&        \
./configure            \
  --prefix=/usr        \
  --sysconfdir=/etc    \
  --disable-static     \
  --localstatedir=/var \
  --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (iSCSI client-side library)
#
# Libiscsi is a client-side library to implement the iSCSI protocol that can be
# used to access the resources of an iSCSI target.
#
# Home page: https://github.com/sahlberg/${PRGNAME}
# Download:  https://github.com/sahlberg/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
