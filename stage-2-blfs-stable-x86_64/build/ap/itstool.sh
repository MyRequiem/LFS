#! /bin/bash

PRGNAME="itstool"

### ITS Tool (Translate XML documents with PO files)
# Позволяет переводить XML-документы с PO-файлами, используя правила из набора
# тегов интернационализации W3C (ITS) для определения того, что перевести и как
# разделить его на сообщения.

# Required:    docbook-xml
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим некоторые проблемы совместимости с Python-3.12
sed -i 's/re.sub(/re.sub(r/'         itstool.in || exit 1
sed -i 's/re.compile(/re.compile(r/' itstool.in || exit 1

PYTHON=/usr/bin/python3 \
./configure             \
    --prefix=/usr || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Translate XML documents with PO files)
#
# ITS Tool allows you to translate your XML documents with PO files, using
# rules from the W3C Internationalization Tag Set (ITS) to determine what to
# translate and how to separate it into PO file messages.
#
# Home page: https://itstool.org/
# Download:  https://files.itstool.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
