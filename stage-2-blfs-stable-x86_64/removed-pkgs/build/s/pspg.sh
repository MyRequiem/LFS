#! /bin/bash

PRGNAME="pspg"

### pspg (Postgres pager)
# PAGER для PostgreSQL's psql client. По умолчанию используется less, который
# не совсем подходит для работы с табличными данными.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCDIR}"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="${DOCDIR}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# документация
cp -a LICENSE README.md ToDo "${TMP_DIR}${DOCDIR}/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Postgres pager)
#
# pspg is a pager for PostgreSQL's psql client
#
# Everybody who uses psql uses less pager. It is working well, but there is not
# any special support for tabular data. I found few projects, but no one was
# completed for this purpose. I decided to write some small specialized pager
# for usage as psql pager.
#
#
# Home page: https://github.com/okbob/${PRGNAME}
# Download:  https://github.com/okbob/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
