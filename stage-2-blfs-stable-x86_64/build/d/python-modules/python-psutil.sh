#! /bin/bash

PRGNAME="python-psutil"
ARCH_NAME="psutil"

### psutil (python interface for process and system info)
# Python модуль, предоставляющий интерфейс для получения информации обо всех
# запущенных процессах и загрузке системы (процессор, память, диски, сеть,
# пользователи) средствами командной строки, такими как: ps, top, df, kill,
# free, lsof, netstat, ifconfig, nice, ionice, iostat, iotop, uptime, pidof,
# tty, who, taskset, pmap

# Required:    python2
#              python3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python2 setup.py build || exit 1
python2 setup.py install --optimize=1 --root="${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
# Download:  https://files.pythonhosted.org/packages/47/b6/ea8a7728f096a597f0032564e8013b705aa992a0990becd773dcc4d7b4a7/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
