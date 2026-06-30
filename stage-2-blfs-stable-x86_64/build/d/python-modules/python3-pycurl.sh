#! /bin/bash

PRGNAME="python3-pycurl"
ARCH_NAME="pycurl"

### pycurl (Python interface to cURL library)
# Библиотека, которая позволяет Python-программам отправлять сетевые запросы,
# скачивать файлы и обмениваться данными с веб-сайтами. Она представляет собой
# быструю Python-обертку над мощной системной утилитой cURL (libcurl).

# Required:    curl
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
    --find-links dist   \
    --no-user           \
    "${ARCH_NAME}" || exit 1

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# если есть директория ${TMP_DIR}/usr/lib/pythonX.X/site-packages/bin/
# перемещаем ее в ${TMP_DIR}/usr/
PYTHON_MAJ_VER="$(python3 -V | cut -d ' ' -f 2 | cut -d . -f 1,2)"
TMP_SITE_PACKAGES="${TMP_DIR}/usr/lib/python${PYTHON_MAJ_VER}/site-packages"
[ -d "${TMP_SITE_PACKAGES}/bin" ] && \
    mv "${TMP_SITE_PACKAGES}/bin" "${TMP_DIR}/usr/"

# удаляем все скомпилированные байт-коды
rm -rf "${TMP_DIR}/usr/bin/__pycache__"
rm -rf "${TMP_SITE_PACKAGES}/__pycache__"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Python interface to cURL library)
#
# PycURL is a Python interface to libcurl. PycURL can be used to fetch objects
# identified by a URL from a Python program, similar to the urllib Python
# module. PycURL is mature, very fast, and supports a lot of features.
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/p/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
