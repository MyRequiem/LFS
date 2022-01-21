#! /bin/bash

PRGNAME="tidy-html5"

### tidy-html5 (correct and clean up HTML and XML documents)
# Инструменты командной строки и библиотеки, используемые для обнаружения и
# исправления распостраненных ошибок кодирования HTML, XHTML и XML в
# соответствии с требованиями W3C (World Wide Web Consortium) для совместимости
# с большинством браузеров.

# Required:    cmake
# Recommended: libxslt
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd build/cmake || exit 1

# создаем библиотеки Release-версий без какой-либо отладочной информации
#    -DCMAKE_BUILD_TYPE=Release
# собираем утилиту tab2space
#    -DBUILD_TAB2SPACE=ON
cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release  \
    -DBUILD_TAB2SPACE=ON        \
    ../.. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

install -v -m755 tab2space "${TMP_DIR}/usr/bin"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (correct and clean up HTML and XML documents)
#
# The Tidy HTML5 package contains a command line tool and libraries used to
# read HTML, XHTML and XML files and write cleaned up markup. It detects and
# corrects many common coding errors and strives to produce visually equivalent
# markup that is both W3C compliant and compatible with most browsers.
#
# Home page: https://github.com/htacg/${PRGNAME}
# Download:  https://github.com/htacg/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
