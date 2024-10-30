#! /bin/bash

PRGNAME="sgml-common"

### sgml-common (SGML Common package)
# Общий пакет SGML содержит утилиту 'install-catalog', необходимую для создания
# и поддержки централизованных каталогов SGML и XML

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим синтаксис doc/man/Makefile.am для текущей версии Automake
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-manpage-1.patch" || exit 1

autoreconf -f -i &&
./configure       \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

make || exit 1
# пакет не содержит набора тестов
make docdir=/usr/share/doc install DESTDIR="${TMP_DIR}"

# перед обновлением пакета нужно удалить некоторые файлы
if command -v install-catalog &>/dev/null; then
    install-catalog --remove /etc/sgml/sgml-ent.cat \
        /usr/share/sgml/sgml-iso-entities-8879.1986/catalog

    install-catalog --remove /etc/sgml/sgml-docbook.cat \
        /etc/sgml/sgml-ent.cat
fi

SGML_CONF="/etc/sgml/sgml.conf"
if [ -f "${SGML_CONF}" ]; then
    mv "${SGML_CONF}" "${SGML_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${SGML_CONF}"

install-catalog --add /etc/sgml/sgml-ent.cat \
    /usr/share/sgml/sgml-iso-entities-8879.1986/catalog

install-catalog --add /etc/sgml/sgml-docbook.cat \
    /etc/sgml/sgml-ent.cat

cp -vR /etc/sgml/{catalog,sgml-docbook.cat,sgml-ent.cat} "${TMP_DIR}/etc/sgml/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (SGML Common package)
#
# The SGML Common package contains install-catalog. This is useful for creating
# and maintaining centralized SGML catalogs.
#
# Home page: https://sourceware.org/ftp/docbook-tools/
# Download:  https://sourceware.org/ftp/docbook-tools/new-trials/SOURCES/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
