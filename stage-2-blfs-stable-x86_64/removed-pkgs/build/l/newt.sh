#! /bin/bash

PRGNAME="newt"

### newt (Not Erik's Windowing Toolkit)
# Набор инструментов (toolkit) для создания графических интерфейсов в текстовом
# режиме. Newt позволяет разработчикам добавлять в свои программы окна,
# текстовые поля, кнопки, метки и флажки и т.п.

# Required:    popt
#              slang
# Recommended: gpm
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# отключим установку статической библиотеки
# shellcheck disable=SC2016
sed -e '/install -m 644 $(LIBNEWT)/ s/^/#/' \
    -e '/$(LIBNEWT):/,/rv/ s/^/#/'          \
    -e 's/$(LIBNEWT)/$(LIBNEWTSH)/g'        \
    -i Makefile.in || exit 1

PYTHON_VER="$(python3 -V | cut -d " " -f 2 | cut -d . -f 1,2)"
./configure            \
    --prefix=/usr      \
    --with-gpm-support \
    --with-python="python${PYTHON_VER}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Not Erik's Windowing Toolkit)
#
# Newt is a programming library for color text mode, widget based user
# interfaces. It can be used to add stacked windows, entry widgets, checkboxes,
# radio buttons, labels, plain text fields, scrollbars, etc., to text mode user
# interfaces. Newt is based on the S-Lang library.
#
# Home page: https://pagure.io/${PRGNAME}
# Download:  https://releases.pagure.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
