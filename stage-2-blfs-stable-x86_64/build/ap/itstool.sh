#! /bin/bash

PRGNAME="itstool"

### ITS Tool (Translate XML documents with PO files)
# Специальный инструмент, который помогает переводить XML-документы (например,
# документацию к программам) на разные языки. Он извлекает текст из файлов
# разметки в стандартные файлы перевода (.po) и вставляет переведенный текст
# обратно, сохраняя всю структуру документа нетронутой.

# Required:    docbook-xml
#              python3-lxml
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# применим патч, чтобы использовать python3-lxml для обработки файлов XML
# вместо устаревшего (отключенного по умолчанию) модуля Python из libxml2
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-lxml-1.patch" || exit 1

PYTHON=/usr/bin/python3 \
./autogen.sh \
    --prefix=/usr || exit 1

make || exit 1
# python3 tests/run_tests.py
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Translate XML documents with PO files)
#
# ITS Tool allows you to translate your XML documents with PO files, using
# rules from the W3C Internationalization Tag Set (ITS) to determine what to
# translate and how to separate it into PO file messages.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
