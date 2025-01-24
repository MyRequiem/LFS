#! /bin/bash

PRGNAME="python3-urlgrabber"
ARCH_NAME="urlgrabber"

### urlgrabber (python url-fetching module)
# Python2 модуль, который значительно упрощает выборку URL из файлов.
# Предназначен для использования в программах, которым нужны общие (но не
# обязательно простые) функции извлечения URL

# Required:    python3-six
#              python3-pycurl
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links=dist   \
    --no-cache-dir      \
    --no-user           \
    "${ARCH_NAME}" || exit 1

rm -rf "${TMP_DIR}/usr/share"

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды из ${TMP_DIR}/usr/bin/, если таковые
# имеются
PYCACHE="${TMP_DIR}/usr/bin/__pycache__"
[ -d "${PYCACHE}" ] && rm -rf "${PYCACHE}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (python url-fetching module)
#
# urlgrabber is a pure python package that drastically simplifies the fetching
# of files. It is designed to be used in programs that need common (but not
# necessarily simple) url-fetching features. It is extremely simple to drop
# into an existing program and provides a clean interface to
# protocol-independant file-access. Best of all, urlgrabber takes care of all
# those pesky file-fetching details, and lets you focus on whatever it is that
# your program is written to do!
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/u/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
