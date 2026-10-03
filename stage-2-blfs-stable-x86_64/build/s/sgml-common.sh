#! /bin/bash

PRGNAME="sgml-common"

### sgml-common (SGML Common package)
# Базовый набор общих правил и файлов, которые нужны системе, чтобы правильно
# читать любые документы в формате SGML и XML. Он служит фундаментом
# (каталогом), без которого программы для обработки этих текстов просто не
# будут знать, как их расшифровать. Содержит утилиту 'install-catalog',
# необходимую для создания и поддержки централизованных каталогов SGML и XML.

# Required:    no
# Recommended: no
# Optional:    no

### NOTE:
# Перед переустановкой/обновлением пакет нужно удалить из системы.

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Исправим синтаксис doc/man/Makefile.am для текущей версии Automake.
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-manpage-1.patch" || exit 1

autoreconf -f -i || exit 1
./configure       \
    --prefix=/usr \
    --sysconfdir=/etc || exit 1

make || exit 1
# Пакет не содержит набора тестов.
make docdir=/usr/share/doc install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

install-catalog --add /etc/sgml/sgml-ent.cat \
    /usr/share/sgml/sgml-iso-entities-8879.1986/catalog || exit 1

install-catalog --add /etc/sgml/sgml-docbook.cat \
    /etc/sgml/sgml-ent.cat                              || exit 1

cp -vR /etc/sgml/{catalog,sgml-docbook.cat,sgml-ent.cat} "${TMP_DIR}/etc/sgml/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (SGML Common package)
#
# The SGML Common package contains install-catalog. This is useful for creating
# and maintaining centralized SGML catalogs.
#
# Home page: https://sourceware.org/ftp/docbook-tools/
# Download:  https://mirror-hk.koddos.net/blfs/conglomeration/${PRGNAME}/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
