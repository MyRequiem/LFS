#! /bin/bash

PRGNAME="python3-psutil"
ARCH_NAME="psutil"

### psutil (python interface for process and system info)
# Python библиотека, позволяющая программам получать всю информацию о системе:
# загрузку процессора, использование памяти, активные диски, запущенные
# процессы, пользователи и т.д.

# Required:    no
# Recommended: no
# Optional:    --- для тестов ---
#              python3-pytest
#              python3-colorama             (https://pypi.org/project/colorama/)
#              python3-pyleak               (https://pypi.org/project/pyleak/)
#              python3-pyperf               (https://pypi.org/project/pyperf/)
#              python3-pypinfo              (https://pypi.org/project/pyinfo/)
#              python3-pytest-instafail     (https://pypi.org/project/pytest-instafail/)
#              python3-pytest-subtests      (https://pypi.org/project/pytest-subtests/)
#              python3-pytest-xdist         (https://pypi.org/project/pytest-xdist/)

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
# Package: ${PRGNAME} (python interface for process and system info)
#
# psutil is a module providing an interface for retrieving information on all
# running processes and system utilization (CPU, memory, disks, network, users)
# in a portable way by using Python, implementing many functionalities offered
# by command line tools such as: ps, top, df, kill, free, lsof, netstat,
# ifconfig, nice, ionice, iostat, iotop, uptime, pidof, tty, who, taskset, and
# pmap
#
# Home page: https://pypi.org/project/${ARCH_NAME}/
# Download:  https://files.pythonhosted.org/packages/source/p/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
